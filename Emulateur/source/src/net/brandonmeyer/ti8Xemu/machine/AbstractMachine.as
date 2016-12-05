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
package net.brandonmeyer.ti8Xemu.machine
{
	import flash.utils.ByteArray;
	
	public class AbstractMachine implements IMachine
	{
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		public function AbstractMachine()
		{
			//
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		
		public function get rom():ByteArray
		{
			return null;
		}
		
		public function get ram():ByteArray
		{
			return null;
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Methods
		//
		//----------------------------------------------------------------------
		
		//------------------------------
		//  IMachine methods
		//------------------------------
		
		public function init(rom:ByteArray):void
		{
			throw new Error("AbstractMachine.init() is an abstract method " + 
					"and must be overridden!");
		}
		
		public function halt():void
		{
			throw new Error("AbstractMachine.halt() is an abstract method " + 
					"and must be overridden!");
		}
		
		public function reset():void
		{
			throw new Error("AbstractMachine.reset() is an abstract method " + 
					"and must be overridden!");
		}
		
		public function get vidRAM():ByteArray
		{
			throw new Error("AbstractMachine.vidRAM is an abstract property " + 
					"and must be overridden!");
			
			return null;
		}
		
		public function get knownRoms():Array
		{
			throw new Error("AbstractMachine.knownRoms is an abstract " + 
					"property and must be overridden!");
			
			return null;
		}
		
		public function get name():String
		{
			throw new Error("AbstractMachine.name is an abstract property " + 
					"and must be overridden!");
			
			return null;
		}
		
		public function get mhz():uint
		{
			throw new Error("AbstractMachine.mhz is an abstract property " + 
					"and must be overridden!");
			
			return null;
		}
		
		public function get lcdHeight():int
		{
			throw new Error("AbstractMachine.lcdHeight is an abstract " + 
					"property and must be overridden!");
			
			return 0;
		}
		
		public function get lcdWidth():int
		{
			throw new Error("AbstractMachine.lcdWidth is an abstract " + 
					"property and must be overridden!");
			
			return 0;
		}
		
		public function keyDown(row:int, col:int):void
		{
			throw new Error("AbstractMachine.keyDown() is an abstract method " + 
					"and must be overridden!");
		}
		
		public function keyUp(row:int, col:int):void
		{
			throw new Error("AbstractMachine.keyUp() is an abstract method " + 
					"and must be overridden!");
		}
	}
}