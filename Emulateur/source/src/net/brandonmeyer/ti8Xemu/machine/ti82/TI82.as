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
	import net.brandonmeyer.ti8Xemu.machine.BaseMachine;
	import net.brandonmeyer.ti8Xemu.vo.RomVO;

	public class TI82 extends BaseMachine
	{
		//----------------------------------------------------------------------
		//
		//  Private class constants
		//
		//----------------------------------------------------------------------
		
		static private const MEM_ROM_START:uint      = 0x0;
		static private const MEM_ROM_END:uint        = 0x3FFF;
		
		static private const MEM_ROM_PAGE_START:uint = 0x4000;
		static private const MEM_ROM_PAGE_END:uint   = 0x7FFF;
		
		static private const MEM_RAM_START:uint      = 0x8000;
		static private const MEM_RAM_END:uint        = 0xFFFF;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Class variables
		//
		//----------------------------------------------------------------------
		
		/**
		 *  This is a work-around for retaining the ROM data in the RomVO
		 *  objects and having them be available through the IMachine
		 *  interface getter method: knownRoms.
		 * 
		 *  @private
		 */
		static private var _knownRoms:Array = 
			[new RomVO("V2.0V (TI-81)", "55a829fea0107193b82a215ca395c0bd"),
			 new RomVO("10.0", "85d83e2920eca865a0ed307597b840e6"),
			 new RomVO("11.0", "f8948e0614d96abddeff8c36e5666044"),
			 new RomVO("16.0", "6fa27889f2d2ad1dc898a847d82e2ffd"),
			 new RomVO("17.0", "1d475d956b216b1cdb8a27a5232c5f87"),
			 new RomVO("18.0", "e00b994cde8600cfe04e5588c73b27f7"),
			 new RomVO("19.0", "3264935479a6be7b1bff366ce28d6e9b"),
			 new RomVO("19.0006", "8ac330474fd835d88c9125cbdac985c0"),
			 new RomVO("19.0006 (patched for VTI)", "b035981e8c66676da78235b9d02a5335")];
		
		
		
		//----------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function get vidRAM():ByteArray
		{
			if (!cpuBoard)
				return null;
			
			return TI82CpuBoard(cpuBoard).vidRAM;
		}
		
		/**
		 *  Overridden for speed.
		 *  @private
		 */
		override public function get ram():ByteArray
		{
			if (memoryMap)
				return memoryMap.findMemory(MEM_RAM_START, MEM_RAM_END);
			
			return null;
		}
		
		/**
		 *  @private
		 */
		override public function get knownRoms():Array
		{
			return _knownRoms;
		}

		/**
		 *  @private
		 */
		override public function get name():String
		{
			return "TI-82";
		}
		
		/**
		 *  @private
		 */
		override public function get mhz():uint
		{
			return 6;
		}
		
		/**
		 *  @private
		 */
		override public function get lcdHeight():int
		{
			return 64;
		}
		
		/**
		 *  @private
		 */
		override public function get lcdWidth():int
		{
			return 96;
		}
		
		
		
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
			super.init(rom);
			
			cpu = new Z80();
			
			cpuBoard = new TI82CpuBoard();

			memoryMap = new MemoryMap(rom);
			
			// ROM
			memoryMap.setReadBank(MEM_ROM_START, 
								  MEM_ROM_END, 
								  MemoryType.READ_ROM);
			
			// ROM Page
			memoryMap.setReadBank(MEM_ROM_PAGE_START, 
								  MEM_ROM_PAGE_END, 
								  MemoryType.READ_BANK1);
			memoryMap.setWriteBank(MEM_ROM_PAGE_START, 
								   MEM_ROM_PAGE_END, 
								   MemoryType.WRITE_BANK1);
			
			// RAM
			memoryMap.setReadBank(MEM_RAM_START, 
								  MEM_RAM_END, 
								  MemoryType.READ_RAM);
			memoryMap.setWriteBank(MEM_RAM_START, 
								   MEM_RAM_END, 
								   MemoryType.WRITE_RAM);
			
			cpuDriver = new CpuDriver(cpu, mhz, memoryMap, memoryMap);
			
			cpuBoard.init(cpuDriver);
			cpu.init(cpuBoard, false);
		}
	}
}