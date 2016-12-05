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
	
	import net.brandonmeyer.core.cpu.Z80;
	import net.brandonmeyer.core.cpuboard.CpuDriver;
	import net.brandonmeyer.core.memory.MemoryMap;
	import net.brandonmeyer.core.memory.MemoryType;
	import net.brandonmeyer.ti8Xemu.machine.BaseMachine;
	import net.brandonmeyer.ti8Xemu.vo.RomVO;

	public class TI83 extends BaseMachine
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
				   [new RomVO("1.02", "4edf419caa9fb0542b4fed8bcd8b54c2"),
					new RomVO("1.03", "28308683219bc1242b3a423f05061e69"),
					new RomVO("1.04", "02d48eaad98a74619e2f68de23ac212f"),
					new RomVO("1.06", "552338d93033ecca7b06cab4d9da789b"),
					new RomVO("1.07", "d4448d09bbfde687c04f9e3310e023ab"),
					new RomVO("1.08", "13b0aca73319cd7617705dd6bd509b8b"),
					new RomVO("1.10", "163b7cecdd3862116dfa7f0d650d56ab"),
					new RomVO("1.10001 (TI-82 Stats)", "795323bb91afefb7c9a9936606443398"),
					new RomVO("1.11fr7 (TI-82 Stats.fr)", "d1355862e65331055290a7f6daa2a609"),
					new RomVO("1.00fr5 (TI-76.fr)", "bf45604fddc21133c615ec926dbf00f8"),
					new RomVO("19.0006 (TI-82)", "822079f2f38cfb2213c1f5f63e0a5c70"),
					new RomVO("19.0006 (TI-82 vtipatched)","0a3fd4564aaaa33e182e10f75655ba48")];
		
		
		
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
			
			return TI83CpuBoard(cpuBoard).vidRAM;
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
			return "TI-83";
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
			
			cpuBoard = new TI83CpuBoard();

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