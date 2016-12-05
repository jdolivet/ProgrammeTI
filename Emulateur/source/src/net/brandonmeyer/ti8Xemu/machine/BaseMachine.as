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
	
	import net.brandonmeyer.core.cpu.ICpu;
	import net.brandonmeyer.core.cpuboard.CpuDriver;
	import net.brandonmeyer.core.memory.MemoryMap;
	import net.brandonmeyer.core.memory.MemoryType;
	import net.brandonmeyer.ti8Xemu.core.ICalculatorCpuBoard;
	
	public class BaseMachine extends AbstractMachine
	{
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		public function BaseMachine()
		{
			//
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		
		/**
		 *  The Machine's CPU.
		 */
		protected var cpu:ICpu;
		
		/**
		 *  The Machine's CPU Board.
		 */
		protected var cpuBoard:ICalculatorCpuBoard;
		
		/**
		 *  The Machine's CPU Driver.
		 */
		protected var cpuDriver:CpuDriver;
		
		/**
		 *  The Machine's memory map.
		 */
		protected var memoryMap:MemoryMap;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function get rom():ByteArray
		{
			return _rom;
		}
		
		/**
		 *  @private
		 */
		override public function get ram():ByteArray
		{
			if (memoryMap)
				return memoryMap.getMemoryByType(MemoryType.WRITE_RAM);
			
			return null;
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Variables
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _rom:ByteArray;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Overridden methods: AbstractMachine
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function init(rom:ByteArray):void
		{
			_rom = rom;
		}
		
		/**
		 *  @private
		 */
		override public function halt():void
		{
			if (cpuBoard)
				cpuBoard.halt();
		}
		
		/**
		 *  @private
		 */
		override public function reset():void
		{
			if (cpuBoard)
				cpuBoard.reset(false);
		}
		
		/**
		 *  @private
		 */
		override public function keyDown(row:int, col:int):void
		{
			if (cpuBoard)
				cpuBoard.keyDown(row, col);
		}
		
		/**
		 *  @private
		 */
		override public function keyUp(row:int, col:int):void
		{
			if (cpuBoard)
				cpuBoard.keyUp(row, col);
		}
	}
}