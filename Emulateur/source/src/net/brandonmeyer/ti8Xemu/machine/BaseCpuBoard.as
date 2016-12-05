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
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import net.brandonmeyer.core.cpu.ICpu;
	import net.brandonmeyer.core.cpuboard.CpuDriver;
	import net.brandonmeyer.core.memory.IReadMap;
	import net.brandonmeyer.core.memory.IWriteMap;
	import net.brandonmeyer.ti8Xemu.core.ICalculatorCpuBoard;
	
	/**
	 *  The base class used for all machine CpuBoards in the application.
	 */
	public class BaseCpuBoard implements ICalculatorCpuBoard
	{
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		public function BaseCpuBoard()
		{
			//
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		
		protected var cpu:ICpu;
		protected var frequency:int;
	    
		protected var powerReg:uint = 0;
		protected var linkReg:uint = 0x0F;
		
		protected var executionLoopTimer:Timer;
		

		//------------------------------
		// Memory related vars
		//------------------------------
		
		protected var mem:ByteArray;
		protected var currentROM:int = 0;
		protected var memReadMap:IReadMap;
	    protected var memWriteMap:IWriteMap;
	
		
		//------------------------------
		//  Video related vars
		//------------------------------
		
		protected var displayContrast:int = 0;
		
		
		//------------------------------
		//  Keyboard related vars
		//------------------------------
		
		protected var keyboard:Array = new Array(8);
		protected var keypadMask:uint = 0;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Event handlers
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function executionLoopTimer_timerHandler(event:TimerEvent):void
		{
			for (var i:int = 0; i < frequency; i++)
			{
				cpu.interrupt(0xFF, false);
				cpu.exec(69888);
			}
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Methods
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Initialize the timer that calls the <code>execute()</code> function
		 *  on the <code>ICpu</code>.
		 */
		protected function initExecutionLoopTimer():void
		{
			if (executionLoopTimer)
			{
				executionLoopTimer.stop();
				executionLoopTimer.removeEventListener(TimerEvent.TIMER, 
												executionLoopTimer_timerHandler);
				executionLoopTimer == null;
			}
			
			executionLoopTimer = new Timer(18);
			executionLoopTimer.addEventListener(TimerEvent.TIMER, 
												executionLoopTimer_timerHandler, 
												false, 
												0, 
												true);
			executionLoopTimer.start();
		}
		
		protected function keyboardRead():int
		{
			var j:uint = 0xff;
			
			if (!(keypadMask & 1))
				j &= keyboard[0];
			
			if (!(keypadMask & 2))
				j &= keyboard[1];
			
			if (!(keypadMask & 4))
				j &= keyboard[2];
			
			if (!(keypadMask & 8))
				j &= keyboard[3];
			
			if (!(keypadMask & 16))
				j &= keyboard[4];
			
			if (!(keypadMask & 32))
				j &= keyboard[5];
			
			if (!(keypadMask & 64))
				j &= keyboard[6]; 
			
			return j;
		}
		
		protected function linkSend(value:int):void
		{
			// TODO
		}
		
		protected function linkRecv():int
		{
			// TODO
			return 0;
		}
		
		
		//------------------------------
		//  ICPUBoard methods
		//------------------------------
		
		/**
		 *  @inheritDoc
		 */
		public function init(cpuDriver:CpuDriver):Boolean
		{
			this.cpu = cpuDriver.cpu;
			this.frequency = cpuDriver.frequency;
			this.memReadMap = cpuDriver.memReadMap;
			this.memWriteMap = cpuDriver.memWriteMap;
			this.mem = cpuDriver.memReadMap.getMemory();
	
			this.cpu.init(this, false);
			
			initExecutionLoopTimer();
			
			reset(false);
	
			return true;
		}
		
		/**
		 *  @inheritDoc
		 */
		public function halt():void
		{
			if (executionLoopTimer)
			{
				executionLoopTimer.stop();
				executionLoopTimer.removeEventListener(TimerEvent.TIMER, 
												executionLoopTimer_timerHandler);
				executionLoopTimer == null;
			}
		}
		
		/**
		 *  @inheritDoc
		 */
		public function getMem():ByteArray
		{
			return mem;
		}
	
		/**
		 *  @inheritDoc
		 */
		public function getCpu():ICpu
		{
			return cpu;
		}
		
		/**
		 *  @inheritDoc
		 */
		public function reset(hard:Boolean):void
		{
			cpu.reset();
			
			if (hard)
			{
				for (var i:int = 0; i < memWriteMap.getSize(); i++)
				{
					memWriteMap.write(i, 0);
				}
			}
			
			keyboard = [];
			for (i = 0; i < 8; i++)
			{
				keyboard[i] = 0xff;
			}
			
			currentROM = 0;
			
			keypadMask = 0;

			displayContrast = 0;
			
			powerReg = 0;
			linkReg = 0x0F;
		}
		
		/**
		 *  @inheritDoc
		 */
		public function exec(cycles:int):void
		{
			cpu.exec(cycles);
		}
	
		/**
		 *  @inheritDoc
		 */
		public function interrupt(type:int, irq:Boolean):void
		{
			cpu.interrupt(type, irq);
		}
	
		/**
		 *  @inheritDoc
		 */
		public function write8(address:int, data:int):void
		{
	        memWriteMap.write(address, data);
		}

		/**
		 *  @inheritDoc
		 */
		public function read8(address:int):int
		{
	        return memReadMap.read(address);
		}
	
		/**
		 *  @inheritDoc
		 */
		public function read8opc(address:int):int
		{
	        return memReadMap.read(address);
		}
	
		/**
		 *  @inheritDoc
		 */
		public function read8arg(address:int):int
		{
	        return memReadMap.read(address);
		}
	
		/**
		 *  @inheritDoc
		 */
		public function write16(address:int, data:int):void
		{
			memWriteMap.write(address++, data & 0xff);
			memWriteMap.write(address, data >> 8);
		}
	
		/**
		 *  @inheritDoc
		 */
		public function read16(address:int):int
		{
			return memReadMap.read(address++) | (memReadMap.read(address) << 8);
		}
	
		/**
		 *  @inheritDoc
		 */
		public function read16arg(address:int):int
		{
	        return memReadMap.read(address++) | (memReadMap.read(address) << 8);
		}
		
		/**
		 *  @inheritDoc
		 */
		public function output(port:int, value:int):void
		{
			throw new Error("BaseCpuBoard.output() is an abstract method " + 
					"and must be overridden!");
		}
		
		/**
		 *  @inheritDoc
		 */
		public function input(port:int):int
		{
			throw new Error("BaseCpuBoard.input() is an abstract method " + 
					"and must be overridden!");
			
			return 0;
		}
		
		/**
		 *  @inheritDoc
		 */
		public function keyDown(row:int, col:int):void
		{
			keyboard[row] &= ~(1 << col);
		}
		
		/**
		 *  @inheritDoc
		 */
		public function keyUp(row:int, col:int):void
		{
			keyboard[row] |= (1 << col);
		}
	}
}