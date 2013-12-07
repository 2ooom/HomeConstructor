package {
	
	import flash.display.SimpleButton;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import canvas3d.*;
	import canvas2d.*;
	import canvas2d.drawingTools.*;

	import flash.events.Event;
	import gui.ToolBox;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.ui.Keyboard;
	
	public class HomeConstructor extends MovieClip
	{
		protected var configManager:ConfigManager;
		protected var _toolBox:ToolBox;
		protected var _canvas3d:Canvas3D;
		protected var _canvas2d:Canvas2D;
		
		protected static const TOOLBOX_WIDTH = 172;
		
		protected static const CANVAS_VISIBLE_WIDTH = 660;
		protected static const CANVAS_VISIBLE_HEIGHT = 520;
		
		protected static const CANVAS_ACTUAL_WIDTH = 2560;
		protected static const CANVAS_ACTUAL_HEIGHT = 1600;
		
		protected static const CANVAS_X_POS = TOOLBOX_WIDTH + 1;
		protected static const CANVAS_Y_POS = 0;
		
		protected static const TOOLBOX_X_POS = 0;
		protected static const TOOLBOX_Y_POS = 0;
		
		protected function get canvasVisibleWidth():Number {
			return stage.stageWidth - CANVAS_X_POS;
		}
		
		protected function get canvasVisibleHeight():Number {
			return stage.stageHeight - CANVAS_Y_POS;
		}
		
		public function HomeConstructor() {
			// initializing config
			configManager = new ConfigManager();
			configManager.addEventListener(Event.COMPLETE, onConfigLoaded);
		}
		
		protected function rearrange():void {
			_toolBox.x = TOOLBOX_X_POS;
			_toolBox.y = TOOLBOX_Y_POS;
			
			_canvas2d.x = CANVAS_X_POS;
			_canvas2d.y = CANVAS_Y_POS;
			
			_canvas3d.x = CANVAS_X_POS;
			_canvas3d.y = CANVAS_Y_POS;
		}

		protected function onConfigLoaded(e:Event):void {
			// initializing toolbox
			_toolBox = new ToolBox(TOOLBOX_WIDTH, canvasVisibleHeight);

			// initializing canvas 2D
			_canvas2d = new Canvas2D(canvasVisibleWidth, canvasVisibleHeight, CANVAS_ACTUAL_WIDTH, CANVAS_ACTUAL_HEIGHT, _toolBox);
			_canvas2d.snapToGrid = true;

			// initializing Canvas 3D
			_canvas3d = new Canvas3D(canvasVisibleWidth, canvasVisibleHeight, CANVAS_X_POS, CANVAS_Y_POS, CANVAS_ACTUAL_WIDTH, CANVAS_ACTUAL_HEIGHT);
			
			addChild(_toolBox);
			addChild(_canvas3d);
			addChild(_canvas2d);
			
			rearrange();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_toolBox.populate();
		}

		protected function onEnterFrame(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function keyboardListener(e:KeyboardEvent):void {
			switch(e.keyCode){
				case Keyboard.NUMBER_3:
					_canvas2d.visible = false;
					_canvas3d.visible = true;
					_canvas3d.repopulate(_canvas2d.pane);
					break;
				case Keyboard.NUMBER_2:
					_canvas2d.visible = true;
					_canvas3d.visible = false;
					break;
				case Keyboard.R:
					_canvas3d.repopulate(_canvas2d.pane);
					break;
			}
		}
	}
}