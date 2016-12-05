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
	import flash.display.BitmapData;
	import flash.utils.*;
	
	import net.brandonmeyer.ti8Xemu.machine.IMachine;

	/**
	 *  The ScreenData class translates the bytes in the <code>IMachine</code>'s
	 *  video RAM to <code>BitmapData</code>.
	 * 
	 *  @see net.brandonmeyer.ti8Xemu.core.Screen Screen
	 *  @see net.brandonmeyer.ti8xemu.machine.IMachine IMachine
	 */
	public class ScreenData extends BitmapData
	{
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * 
		 *  @param machine The <code>IMachine</code> to render the data from.
		 */
		public function ScreenData(machine:IMachine)
		{
			super(machine.lcdWidth, machine.lcdHeight);
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Color to use for 'ON' pixels.
		 *  
		 *  @default 0x000000;
		 */
		public var onColor:uint = 0x000000;
		
		/**
		 *  Color to use for 'OFF' pixels.
		 * 
		 *  @default 0xFFFFFF;
		 */
		public var offColor:uint = 0xFFFFFF;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Methods
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Reads the RAM and creates a bitmap representation of its current
		 *  state.
		 *  
		 *  @param ram The <code>IMachine</code>'s video RAM.
		 */
		final public function render(ram:ByteArray):void
		{
			if (!ram || ram.length == 0)
				return;
			
			// Create a new ByteArray and pad the end so that we can
			// access all of the information in the RAM with this
			// algorithm. Not ideal, but it works.
			var tmpRAM:ByteArray = new ByteArray();
			tmpRAM.length = ram.length + 4;
			tmpRAM.writeBytes(ram);
			
			var c:int, i:int, x:int = 0, y:int = 0;
			
			lock();
			
			for (i = 0; i < this.width * this.height; )
			{
				tmpRAM.position = i >> 3;

				c = tmpRAM.readInt();
				
				for (var s:int = 0; s < 8; s++)
				{
					setPixel(x, y, (c < 0) ? onColor : offColor);
					
					c <<= 1;
					
					x++;
					
					i++;
					
					if (x >= this.width)
					{
						y++;
						x = 0;
					}
				}
			}
			
			unlock();
		}
		
		/**
		 *  Sets all pixels to 'off'.
		 */
		final public function clear():void
		{
			var rowIndex:Number = 0;
			
			for (var y:uint = 0; y < this.height; y++)
			{
				rowIndex = y * this.width;
				for (var x:uint = 0; x < this.width; x++)
				{
					setPixel(x, y, offColor);
				}
			}
		}
	}
}