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
package net.brandonmeyer.ti8Xemu.machine.ti82
{
	import flash.utils.ByteArray;
	
	import net.brandonmeyer.core.cpu.Z80;
	import net.brandonmeyer.core.cpuboard.CpuDriver;
	import net.brandonmeyer.core.memory.MemoryMap;
	import net.brandonmeyer.core.memory.MemoryType;
	import net.brandonmeyer.ti8Xemu.machine.BaseCpuBoard;

	public class TI82CpuBoard extends BaseCpuBoard
	{
		//----------------------------------------------------------------------
		//
		//  Class Constants
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		static private const PORT3_COUNT:uint = 5000;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		
		public var vidRAM:ByteArray;
		
		/**
		 *  ROM page storage
		 */
		protected var pager:Array = [];
		
		/**
		 *  ROM page accessor.
		 */
		protected function get romPage():ByteArray
		{
			return MemoryMap(memReadMap).getMemoryByType(MemoryType.WRITE_BANK1);
		}
		
		
		//------------------------------
		//  Video related vars
		//------------------------------
		
		protected var vidCol:int = 0;
		protected var vidRow:int = 0;
		protected var vidDir:int = 7;
		protected var vidMode:int = 0;
		protected var lcdOff:int = 1;
		protected var justSet:int = 0;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Variables
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _port3Left:int;
		
		
		
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
				romPage.writeBytes(pager[currentROM]);
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
			super.init(cpuDriver)
			
			vidRAM = new ByteArray();
			vidRAM.length = 0x300;
			
			_port3Left = PORT3_COUNT;
			
			for (var i:int = 0; i < (mem.length / 0x4000); i++)
			{
				pager[i] = new ByteArray();
				pager[i].writeBytes(mem, i * 0x4000, 0x3FFF);
			}
			
			return true;
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
		override public function reset(hard:Boolean):void
		{
			vidRAM = new ByteArray();
			vidRAM.length = 0x300;
			
			_port3Left = PORT3_COUNT;

			super.reset(hard);
		}

		/**
		 *  @private
		 */
		override public function input(port:int):int
		{
			switch (port & 0x17)
			{
				case 0x00:
				{
			    	return linkReg
				}
				
				case 0x01:
				{
					return keyboardRead();
				}
			
				case 0x02:
				{
					return currentROM;
				}
				
				case 0x03:
				{
					if (_port3Left)
		            {
		                _port3Left--;
		                return 0x01;
		            }
		            
					return (0x08 | (Z80(cpu).eiR() ? 0 : 2));
				}
				
				case 0x11:
				{
					var v:int;
					if (justSet)
		            {
		                justSet = 0;
		                return 0;
		            }
		            if (vidRow < 0)
		            	vidRow = 63;
		            
		            if (vidRow > 63)
		            	vidRow = 0;
		            
		            if (vidCol < 0)
		            	vidCol = 15;
		            
		            if (vidCol > 15)
		            	vidCol = 0;
		            
		            if (vidMode)
		            {
		                if (vidCol > 11)
		                	return 0;
		                
		                v = vidRAM[(vidRow * 12) + vidCol];
		            }
		            else
		            {
		                var col:int = 6 * vidCol;
		                var ofs:int = vidRow * 12 + (col >> 3);
		                var shift:int = 10 - (col & 7);
		                v = ((vidRAM[ofs] << 8) | vidRAM[ofs + 1]) >> shift;
		            }
		            
		            switch (vidDir)
		            {
		                case 4:
		                	vidRow--;
		                	break;
		                
		                case 5:
		                	vidRow++;
		                	break;
		                
		                case 6:
		                	vidCol--;
		                	break;
		                
		                case 7:
		                	vidCol++;
		                	break;
		            }
		            return v;
				}
			}
			
			return 0x08;
		}
		
		/**
		 *  @private
		 */
		override public function output(port:int, value:int):void
		{
			switch (port & 0x17)
			{
				case 0x00:
				{
					linkReg = (linkReg & 0xF3) | (value & 0xC);
					
					return;
				}
		
				case 0x01:
				{
					keypadMask = value;
			
					return;
				}
				
				case 0x02:
				{
					mapROM(value);
			
					return;
				}
				
				case 0x10:
				{
					if ((value & 0xc0) == 0xc0)
					{
		                displayContrast = (value & 0x3f) >> 1;
		   			}
		            else if ((value >= 0x20) && (value <= 0x2f))
		            {
		                vidCol = value - 0x20;
		                justSet = 1;
		            }
		            else if ((value >= 0x80) && (value <= 0xbf))
		            {
		                vidRow = value - 0x80;
		                justSet = 1;
		            }
		            else if ((value >= 4) && (value <= 7))
		            {
		                vidDir = value;
		            }
		            else if (value==0)
		            {
		                vidMode = 0;
		            }
		            else if (value == 1)
		            {
		                vidMode = 1;
		            }
		            else if (value == 2)
		            {
		                lcdOff = 1;
		            }
		            else if (value == 3)
		            {
		                lcdOff = 0;
		            }
		            break;
				}
				
				case 0x11:
				{
					if (vidRow < 0)
						vidRow=63;
					
		            if (vidRow > 63)
		            	vidRow = 0;
		            
		            if (vidCol < 0)
		            	vidCol = 15;
		            
		            if (vidCol > 15)
		            	vidCol = 0;
		            
		            if (vidMode)
		            {
		                if (vidCol > 11)
		                	return;
		                vidRAM[(vidRow * 12) + vidCol] = value;
		            }
		            else
		            {
		                var col:int = 6 * vidCol;
		                var ofs:int = vidRow * 12 + (col >> 3);
		                var shift:int = col & 7;
		                var mask:int;
		                value <<= 2;
		                mask = ~(252 >> shift);
		                vidRAM[ofs] = vidRAM[ofs] & mask | (value >> shift);
		                if (shift > 2)
		                {
		                    ofs++;
		                    shift = 8 - shift;
		                    mask = ~(252 << shift);
		                    vidRAM[ofs] = vidRAM[ofs] & mask | (value << shift);
		                }
		            }
		            
		            switch (vidDir)
		            {
		                case 4:
		                	vidRow--;
		                	break;
		                
		                case 5:
		                	vidRow++;
		                	break;
		                
		                case 6:
		                	vidCol--;
		                	break;
		                
		                case 7:
		                	vidCol++;
		                	break;
		            }
		            
		            break;
				}
			}
		}
	}
}