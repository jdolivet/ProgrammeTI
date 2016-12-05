/*
	TI8XEmu - A Flex/ActionScript 3 Texas Instruments graphing calculator emulator
    Copyright (C) 2008  Brandon A. Meyer

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package net.brandonmeyer.ti8Xemu.core
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.utils.ObjectUtil;
	
	import net.brandonmeyer.ti8Xemu.events.CalculatorEvent;
	import net.brandonmeyer.ti8Xemu.machine.*;
	import net.brandonmeyer.ti8Xemu.utils.MachineUtil;
	
	import nochump.util.zip.ZipEntry;
	import nochump.util.zip.ZipFile;
	
	
	// Events
	[Event(name="invalidRom", type="net.brandonmeyer.ti8Xemu.CalculatorEvent")]
	
	
	/**
	 *  The <code>Calculator</code> class is the main hardware class for the
	 *  application.
	 * 
	 *  It requires the <code>calcType</code> and <code>rom</code> properties
	 *  to be defined in order to run.
	 * 
	 *  @see net.brandonmeyer.ti8Xemu.machine.IMachine IMachine
	 *  @see net.brandonmeyer.ti8Xemu.core.Screen Screen
	 */
	public class Calculator extends EventDispatcher
	{
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		public function Calculator()
		{
			//
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _calcType:Class;
		
		/**
		 * 	Type of <code>IMachine</code> to emulate.
		 */
		[Bindable]
		public function set calcType(value:Class):void
		{
			if (_calcType == value)
				return;
			
			_calcType = value;
			
			if (machine)
				machine.halt();
			
			_rom = null;
			
			if (_calcType)
			{
				machine = new _calcType();
				
				init();
			}
			else
			{
				machine = null;
			}
		}
		
		/**
		 *  @private
		 */
		public function get calcType():Class
		{
			return _calcType;
		}
		
		
		/**
		 *  @private
		 */
		private var _rom:ByteArray;
		
		/**
		 *  The Calculator's ROM. 
		 * 
		 *  Can be a <code>ByteArray</code>, <code>FileReference</code> 
		 *  or a URL String. The URL or FileReference may target a .Zip file.
		 */
		[Bindable]
		public function set rom(value:*):void
		{
			if (_rom == value)
				return;
			
			if (value is ByteArray)
			{
				_rom = ObjectUtil.copy(value) as ByteArray;
				
				init();
			}
			else if (value is FileReference)
			{
				value.addEventListener(Event.COMPLETE, 
									   romFileRef_completeHandler, 
									   false, 
									   0, 
									   true);
				value.load();
			}
			else if (value is String)
			{
				loadROM(value);
			}
		}
		
		/**
		 *  @private
		 */
		public function get rom():*
		{
			return _rom;
		}
		
		
		protected var machine:IMachine;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Variables
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _romLoader:URLLoader;
		
		/**
		 *  @private
		 */
		private var _romLoaderURL:String;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Accessors
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Get the <code>Calculator</code>'s IMachine.
		 *  
		 *  @return The IMachine.
		 */
		public function getMachine():IMachine
		{
			return machine;
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Event handlers
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function romLoader_completeHandler(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			var romData:ByteArray;
			
			if (_romLoaderURL.substr(_romLoaderURL.length - 4, 4) == ".zip")
			{
				processZipFile(loader.data);
			}
			else
			{
				processLoadedData(loader.data);
			}
			
			_romLoaderURL = null;
		}
		
		/**
		 *  @private
		 */
		private function romFileRef_completeHandler(event:Event):void
		{
			var fileRef:FileReference = (event.target as FileReference);
			
			var romData:ByteArray;
			
			if (fileRef.name.substr(fileRef.name.length - 4, 4) == ".zip")
			{
				processZipFile(fileRef.data);
			}
			else
			{
				processLoadedData(fileRef.data);
			}
		}
		
		/**
		 *  @private
		 */
		private function romLoader_ioErrorHandler(event:IOErrorEvent):void
		{
			trace("ROM Loader: " + event.text);
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Methods
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Initialize the <code>Calculator</code>'s CPU, memory and begins
		 *  the execution loop timer.
		 */
		protected function init():void
		{
			if (!machine || !_rom)
				return;
			
			if (MachineUtil.checkROM(_rom, machine))
			{
				MachineUtil.addRom(machine, _rom);
			}
			else
			{
				var event:CalculatorEvent = new CalculatorEvent(CalculatorEvent.INVALID_ROM);
				dispatchEvent(event);
				
				_rom = null;
				
				return;
			}
			
			machine.init(_rom);
			
			MachineUtil.logInfo(machine);
		}
		
		/**
		 *  Reset the <code>Calculator</code>.
		 */
		public function reset():void
		{
			if (machine)
				machine.reset();
		}
		
		/**
		 *  Attempt to find the ROM file within a .zip archive and hand off
		 *  that file for further processing in processLoadedData().
		 *  
		 *  @private
		 */
		private function processZipFile(data:ByteArray):void
		{
			var zip:ZipFile = new ZipFile(data);
			var romData:ByteArray;
			
			for (var i:int = 0; i < zip.entries.length; i++) 
			{
			    var entry:ZipEntry = zip.entries[i];
			    
			    // 128k is the smallest ROM size
			    if (entry.size >= 20000) // TODO: Get appropriate length
			    {
				    romData = zip.getInput(entry);
				    processLoadedData(romData);
					return;
				}
			}
			
			dispatchEvent(new CalculatorEvent(CalculatorEvent.INVALID_ROM));
		}
		
		/**
		 *  Attempt to write the loaded data into memory and initialize
		 *  the Calculator.
		 *  
		 *  @private
		 */
		private function processLoadedData(data:ByteArray):void
		{
			if (data && data.length >= 20000) // TODO: Get appropriate length
			{
				_rom = new ByteArray();
				_rom.writeBytes(data, 0);

				init();
			}
			else
			{
				trace("ROM file corrupt!");
			}
		}
		
		/**
		 *  Begin loading of the specified ROM file.
		 *  
		 *  @private
		 */
		private function loadROM(romPath:String):void
		{
			// Sanity check
			if (!romPath || romPath == "")
				return;
			
			_romLoaderURL = romPath;
			_romLoader = new URLLoader();
			_romLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_romLoader.addEventListener(Event.COMPLETE, romLoader_completeHandler, false, 0, true);
			_romLoader.addEventListener(IOErrorEvent.IO_ERROR, romLoader_ioErrorHandler, false, 0, true);
			_romLoader.load(new URLRequest(_romLoaderURL));
		}
		
		/**
		 *  Send the keyDown command to the IMachine.
		 *  
		 *  @param row Row of the key.
		 *  @param col Column of the key.
		 */
		public function keyDown(row:uint, column:uint):void
		{
			if (machine)
				machine.keyDown(row, column);
		}
		
		/**
		 *  Send the keyUp command to the IMachine.
		 *  
		 *  @param row Row of the key.
		 *  @param col Column of the key.
		 */
		public function keyUp(row:uint, column:uint):void
		{
			if (machine)
				machine.keyUp(row, column);
		}
	}
}