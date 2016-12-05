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
package net.brandonmeyer.ti8Xemu.machine.ti85
{
	import flash.utils.ByteArray;
	
	import net.brandonmeyer.core.cpu.Z80;
	import net.brandonmeyer.core.cpuboard.CpuDriver;
	import net.brandonmeyer.core.memory.MemoryMap;
	import net.brandonmeyer.core.memory.MemoryType;
	import net.brandonmeyer.ti8Xemu.machine.BaseCpuBoard;

	public class TI85CpuBoard extends BaseCpuBoard
	{
		//----------------------------------------------------------------------
		//
		//  Class Constants
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		static private const PORT3_COUNT:uint = 3000;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Variables
		//
		//----------------------------------------------------------------------
		
		/**
		 *  ROM page storage
		 * 
		 *  @private
		 */
		private var _pager:Array = [];
		
		/**
		 *  @private
		 */
		private var _port3Left:int;
		
		/**
		 *  ROM page accessor.
		 * 
		 *  @private
		 */
		private function get romPage():ByteArray
		{
			// This is bad practice to use MemoryMap here. Fix this someday.
			return MemoryMap(memReadMap).getMemoryByType(MemoryType.WRITE_BANK1);
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Methods
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Writes the desired ROM page into active memory.
		 *  
		 *  @private
		 */
		private function mapROM(value:int):void
		{
			value &= 7;
			if (currentROM != value)
			{
				currentROM = value;
				romPage.position = 0;
				romPage.writeBytes(_pager[currentROM]);
			}
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Overridden methods: BaseCpuBoard
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function init(cpuDriver:CpuDriver):Boolean
		{
			super.init(cpuDriver);
			
			_port3Left = PORT3_COUNT;
			
			var len:int = (mem.length / 0x4000);
			
			for (var i:int = 0; i < len; i++)
			{
				var byteArray:ByteArray = new ByteArray();
				byteArray.length = 0x3FFF;
				byteArray.writeBytes(mem, i * 0x4000, 0x3FFF);
				
				_pager[i] = byteArray;
			}
			
			return true;
		}
		
		/**
		 *  @private
		 */
		override public function reset(hard:Boolean):void
		{
			_port3Left = PORT3_COUNT;

			super.reset(hard);
		}
		
		/**
		 *  @private
		 */
		override public function keyDown(row:int, col:int):void
		{
			// Issue the reset command when the ON button is pressed
			if (row == 5 && col == 0)
				reset(false);
			
			super.keyDown(row, col);
		}
		
		/**
		 *  @private
		 */
		override public function output(port:int, value:int):void
		{
			switch (port & 0xFF)
			{
				case 0x01:
					keypadMask = value;
					return;
				
				case 0x02:
					displayContrast = value;
					return;

				case 0x05:
					mapROM(value);
					return;
				
				case 0x06:
					powerReg = value;
					return;
				
				case 0x07:
					linkReg = (linkReg & 0xF3) | (value & 0xC);
					return;
			}
		}
	
		/**
		 *  @private
		 */
		override public function input(port:int):int
		{
			switch (port & 0xFF)
			{
				case 0x01:
					return keyboardRead();
				
				case 0x02:
					return (displayContrast & 0x1f);
				
				case 0x03:
				{
					if (_port3Left)
		            {
		                _port3Left--;
		                return 0x01;
		            }
		            
					return (0x08 | (Z80(cpu).eiR() ? 0 : 2));
				}

				case 0x05:
					return currentROM;
				
				case 0x06:
					return powerReg;
				
			    case 0x07:
			    	return linkReg;
			}
			
			return 0;
		}
	}
}