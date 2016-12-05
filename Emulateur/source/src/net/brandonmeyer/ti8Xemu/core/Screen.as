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
	import flash.display.*;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;
	import mx.styles.StyleManager;
	import mx.utils.ObjectUtil;
	
	import net.brandonmeyer.ti8Xemu.machine.IMachine;
	
	
	// Styles
	[Style(name="borderThickness", type="int", inherit="no")]
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	[Style(name="pixelOnColor", type="uint", format="Color", inherit="no")]
	
	
	/**
	 *  The Screen class is used for displaying the data in the 
	 * 	<code>Calculator</code>'s video RAM.
	 * 
	 *  @see net.brandonmeyer.ti8Xemu.core.ScreenData ScreenData
	 *  @see net.brandonmeyer.ti8xemu.machine.IMachine IMachine
	 *  @see net.brandonmeyer.ti8Xemu.core.Calculator Calculator
	 */
	public class Screen extends UIComponent
	{
		//----------------------------------------------------------------------
		//
		//  Class constants
		//
		//----------------------------------------------------------------------
		
		static private const DEFAULT_PIXEL_ON_COLOR:uint = 		0x000000;
		static private const DEFAULT_BACKGROUND_COLOR:uint = 	0xFFFFFF;
		static private const DEFAULT_BORDER_COLOR:uint = 		0x0;
		static private const DEFAULT_BORDER_THICKNESS:int = 	1;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Constructor
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * 
		 *  @param calculator The <code>Calculator</code> to display the data 
		 *  from.
		 */
		public function Screen(calculator:Calculator = null)
		{
			this.calculator = calculator;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 0, true);
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Properties
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _calculator:Calculator;
		
		public function set calculator(value:Calculator):void
		{
			if (_calculator == value)
				return;
			
			_calculator = value;
		}
		
		/**
		 *  @private
		 */
		public function get calculator():Calculator
		{
			return _calculator;
		}

		
		protected var bitmap:Bitmap;
		protected var screenData:ScreenData;
		protected var machine:IMachine;
		protected var previouslyRenderedVidRAM:ByteArray;
		
		
		
		//----------------------------------------------------------------------
		//
		//  Event handlers
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function enterFrameHandler(event:Event):void
		{
			render();
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Methods
		//
		//----------------------------------------------------------------------
		
		/**
		 *  Render the screen data from the calculator's RAM.
		 *  
		 *  @private
		 */
		final private function render():void
		{
			// If we're setting up for the first time or the calculator's 
			// machine has changed then perform setup.
			if (!machine || (calculator && (calculator.getMachine() != machine)))
			{
				machine = calculator.getMachine();
				
				if (machine == null)
				{
					bitmap.bitmapData = null;
					return;
				}
				
				screenData = new ScreenData(machine);
				screenData.onColor = getPixelOnColor();
				screenData.offColor = getBackgroundColor();
				
				invalidateDisplayList();
				validateDisplayList();
			}
			
			var vidRAM:ByteArray = machine.vidRAM;
			
			// Return if the video RAM has not changed since last render.
			try
			{
				if (ObjectUtil.compare(vidRAM, previouslyRenderedVidRAM) == 0)
					return;
			}
			catch (e:Error) {}

			try
			{
				previouslyRenderedVidRAM = ObjectUtil.copy(vidRAM) as ByteArray;
				screenData.render(vidRAM);
			}
			catch (e:Error)
			{
				bitmap.bitmapData = null;
			}
			
			bitmap.bitmapData = screenData;
		}
		
		
		//------------------------------
		//  Style getters
		//------------------------------
		
		/**
		 *  Get the default or currently set color for 'ON' pixels.
		 *  @private
		 */
		private function getPixelOnColor():uint
		{
			var val:uint = getStyle("pixelOnColor");
			
			if (val == StyleManager.NOT_A_COLOR)
				val = DEFAULT_PIXEL_ON_COLOR;
			
			return val;
		}
		
		/**
		 *  Get the default or currently set color for the background.
		 *  @private
		 */
		private function getBackgroundColor():uint
		{
			var val:uint = getStyle("backgroundColor");
			
			if (val == StyleManager.NOT_A_COLOR || 
				(val == 0 && getPixelOnColor() == 0))
			{
				val = DEFAULT_BACKGROUND_COLOR;
			}
			
			return val;
		}
		
		/**
		 *  Get the default or currently set value for the border thickness.
		 *  @private
		 */
		private function getBorderThickness():int
		{
			var val:int = getStyle("borderThickness");
			
			if (val == StyleManager.NOT_A_COLOR)
				val = DEFAULT_BORDER_THICKNESS;
			
			return val;
		}
		
		/**
		 *  Get the default or currently set color for the border.
		 *  @private
		 */
		private function getBorderColor():uint
		{
			var val:uint = getStyle("borderColor");
			
			if (val == StyleManager.NOT_A_COLOR)
				val = DEFAULT_BORDER_COLOR;
			
			return val;
		}
		
		
		
		//----------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//----------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			var sprite:Sprite = new Sprite();
			
			if (!bitmap)
			{
				bitmap = new Bitmap();
				sprite.addChild(bitmap);
			}
			
			sprite.y = sprite.x = 1;
			
			addChild(sprite);
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var borderThickness:uint = getBorderThickness();
			
			graphics.clear();
			graphics.lineStyle(borderThickness, getBorderColor());
			graphics.beginFill(getBackgroundColor());
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			
			if (calculator && machine && bitmap)
			{
				// Try scaling by height first.
				var scale:int = (unscaledHeight - borderThickness) / machine.lcdHeight;
				
				// It's too wide. Scale by width instead.
				if ((scale * machine.lcdWidth) > unscaledWidth)
					scale = (unscaledWidth - borderThickness) / machine.lcdWidth;
				
				// Apply the scale
				bitmap.scaleX = bitmap.scaleY = scale;
				
				// Center it
				bitmap.x = ((unscaledWidth - borderThickness) - (machine.lcdWidth * scale)) * 0.5;
				bitmap.y = ((unscaledHeight - borderThickness) - (machine.lcdHeight * scale)) * 0.5;
			}
		}
	}
}