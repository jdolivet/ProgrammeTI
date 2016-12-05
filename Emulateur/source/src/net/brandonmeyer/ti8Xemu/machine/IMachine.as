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
	
	public interface IMachine
	{
		function init(rom:ByteArray):void;
		function halt():void;
		function reset():void;
		
		function get rom():ByteArray;
		function get ram():ByteArray;
		function get vidRAM():ByteArray;
		function get knownRoms():Array;
		
		function get name():String;
		
		function get mhz():uint;
		
		function get lcdHeight():int;
		function get lcdWidth():int;
		
		function keyDown(row:int, col:int):void;
		function keyUp(row:int, col:int):void;
	}
}