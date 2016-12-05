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
package net.brandonmeyer.ti8Xemu.machine.ti83
{
	import flash.utils.ByteArray;
	
	import net.brandonmeyer.ti8Xemu.machine.ti82.TI82CpuBoard;

	public class TI83CpuBoard extends TI82CpuBoard
	{
		//----------------------------------------------------------------------
		//
		//  Overridden methods: TI82CpuBoard
		//
		//----------------------------------------------------------------------

		/**
		 *  @private
		 */
		override public function input(port:int):int
		{
			switch (port & 0x17)
			{
				case 0x00:
					return (((currentROM & 0x08) << 1) | ((linkReg & 0x03) << 0x02));

				case 0x04:
		            return 0xff;
				
				case 0x06:
		            return currentROM;
		        
		        case 0x07:
		            return 0xff;
				
				case 0x14:
					return 1;
				
				default:
					return super.input(port);
			}
			
			return 0;
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
            		value = (currentROM & 7) | ((value & 16) >> 1);
					if (currentROM != value)
					{
						currentROM = value;
						romPage.position = 0;
						romPage.writeBytes(pager[currentROM], 0x0, 0x3FFF);
					}
            		
            		linkReg = (linkReg & 0x03);
            		
            		return;
				}

				case 0x02:
				{
					value = (currentROM & 8)|(value & 0x7);
					if (currentROM != value)
					{
						currentROM = value;
						romPage.position = 0;
						romPage.writeBytes(pager[currentROM], 0x0, 0x3FFF);
					}
			
					return;
				}
				
				default:
					super.output(port, value);
			}
		}
	}
}