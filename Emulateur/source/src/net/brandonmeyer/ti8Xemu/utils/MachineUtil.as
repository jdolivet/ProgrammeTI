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
package net.brandonmeyer.ti8Xemu.utils
{
	import com.hurlant.crypto.hash.MD5;
	
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	
	import mx.utils.ObjectUtil;
	
	import net.brandonmeyer.ti8Xemu.machine.IMachine;
	import net.brandonmeyer.ti8Xemu.vo.RomVO;
	
	public class MachineUtil
	{
		/**
		 *  Logs an overview of the machine through trace().
		 * 
		 *  @param machine The IMachine to log the info of.
		 */
		static public function logInfo(machine:IMachine):void
		{
			var vidRAM:String;
			
			if (machine.vidRAM.length < 1024)
				vidRAM = machine.vidRAM.length + " bytes"
			else
				vidRAM = (machine.vidRAM.length / 1024) + " KB";
			
			trace("\n************* " + machine.name + " *************");
			trace("RAM size:\t\t\t" +   (machine.ram.length / 1024) + " KB");
			trace("ROM size:\t\t" +     (machine.rom.length / 1024) + " KB");
			trace("Video RAM Size:\t" + vidRAM);
			trace("CPU Speed:\t\t" +    machine.mhz + " mhz");
			trace("Screen size:\t\t" +  machine.lcdWidth + " x " + machine.lcdHeight);
			trace("*********************************\n");
		}
		
		/**
		 *  Checks the MD5 of the ROM to that of known MD5s for the machine
		 *  and returns a true value if it's a known ROM.
		 * 
		 *  @param rom The ROM to check.
		 *  @param machine The IMachine containing the MD5 data.
		 * 
		 *  @return The result.
		 */
		static public function checkROM(rom:ByteArray, machine:IMachine):Boolean
		{
			var knownRoms:Array = machine.knownRoms;
			
			// Sanity check
			if (!knownRoms || knownRoms.length == 0)
				return false;
			
			var hashString:String = getMD5(rom);
			
			for (var i:int = 0; i < knownRoms.length; i++)
			{
				if (knownRoms[i].md5 == hashString)
					return true;
			}
			
			return false;
		}
		
		/**
		 *  Get the MD5 for a loaded ROM.
		 *  
		 *  @param rom The loaded ROM data.
		 * 
		 *  @return The MD5 string.
		 */
		static public function getMD5(rom:ByteArray):String
		{
			var md5:MD5 = new MD5();
			var hash:ByteArray = md5.hash(rom);
			
			var hashString:String = "";
			for (var i:int = 0; i < hash.length; i++)
			{
				hash.position = i;
				var val:String = hash.readUnsignedByte().toString(16);
				
				if (val.length == 1)
					val = "0" + val;
				
				hashString += val;
			}
			
			return hashString;
		}
		
		/**
		 *  Caches the loaded ROM data in the <code>IMachine</code>'s known
		 *  <code>RomVO</code> objects for later use.
		 * 
		 *  @param machine The machine to save the ROM data to.
		 *  @param rom The loaded ROM data.
		 * 
		 *  @return A boolean value indicating success of the operation.
		 */
		static public function addRom(machine:IMachine, rom:ByteArray):Boolean
		{
			if (!checkROM(rom, machine))
				return false;
			
			var hashString:String = getMD5(rom);
			
			for (var s:String in machine.knownRoms)
			{
				if (machine.knownRoms[s].md5 == hashString)
				{
					// Does not have data for the ROM
					if (machine.knownRoms[s].data == null)
					{
						machine.knownRoms[s].data = ObjectUtil.copy(rom) as ByteArray;
						
						return true;
					}
					else
					// Already contains ROM data
					{
						return false;
					}
				}
			}
			
			return false;
		}
		
		/**
		 *  Return an array of <code>RomVO</code> objects that contain data.
		 * 
		 * 	@param machine The machine
		 * 
		 *  @return The Array.
		 */
		static public function getRoms(machine:IMachine):Array
		{
			if (!machine)
				return [];
			
			var retArray:Array = [];
			for (var s:String in machine.knownRoms)
			{
				if (machine.knownRoms[s].data)
					retArray.push(machine.knownRoms[s]);
			}
			
			return retArray;
		}
		/* BROKEN
		static public function loadLocalRoms(machine:IMachine):void
		{
			try
			{
				var lso:SharedObject = SharedObject.getLocal("TI8XEmu");
				//lso.clear();
				//lso.flush();
				//return;
				//trace(ObjectUtil.toString(lso.data));
				
				for (var i:int = 0; i < machine.knownRoms.length; i++)
				{
					var rom:RomVO = machine.knownRoms[i] as RomVO;
					
					if (lso.data[rom.md5])
						rom.data = lso.data[rom.md5];
				}
				
				lso = null;
			}
			catch (e:Error) {trace(e.message);}
		}
		
		static public function saveLocalRoms(machine:IMachine):void
		{
			try
			{
				var lso:SharedObject = SharedObject.getLocal("TI8XEmu");
				
				var size:int = 0;
				
				for (var i:int = 0; i < machine.knownRoms.length; i++)
				{
					var rom:RomVO = machine.knownRoms[i] as RomVO;
					if (rom.data != null)
					{
						lso.data[rom.md5] = rom.data;
						
						size += rom.data.length;
						lso.flush(size);
					}
				}
				
				lso = null;
			}
			catch (e:Error) {}
		}
		*/
	}
}