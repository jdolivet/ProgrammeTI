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
	import net.brandonmeyer.ti8Xemu.machine.BaseMachine;
	import net.brandonmeyer.ti8Xemu.vo.RomVO;
	
	public class TI85 extends BaseMachine
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
				   [new RomVO("2.0", "55f6abcdc5d6aaa96b12ee733095b612"),
				    new RomVO("3.0A", "d605d3ce4123053f866762aae68554f8"),
				    new RomVO("4.0", "a928bdf958fca70161f1508f535d0a4a"),
				    new RomVO("5.0", "a51a8eaa9ce32be59a18bacfe9b2dc8e"),
				    new RomVO("6.0", "a182fe348523bce3e6b2b36ebf8f6412"),
				    new RomVO("8.0", "9b8e23ccf63ec067ce9a4945dcc77a1f"),
				    new RomVO("9.0", "edc54d0b01274e9c3cd56ef3f591ae59"),
					new RomVO("10.0", "c41be0b3d23fae52f391781fc9ee8c07"),
					new RomVO("1.6K (81)", "cf992a900b89499166c4c21e54e7b901"),
					new RomVO("1.8K (81)", "cfbf7eda022ac6d8fdcbb74a12d4489c")];
		
		
		
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
			if (!ram)
				return null;
			
			var vRAM:ByteArray = new ByteArray();
			vRAM.writeBytes(ram, ram.length - 0x400);
			
			return vRAM;
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
			return "TI-85";
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
			return 128;
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
			
			cpuBoard = new TI85CpuBoard();

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