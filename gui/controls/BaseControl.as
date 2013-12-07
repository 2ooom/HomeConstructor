package gui.controls
{
	import flash.geom.Matrix;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	[Event(name="resize", type="flash.events.Event")]
	public class BaseControl extends Sprite
	{
		public static var myriadProFont:MyriadPro = new MyriadPro();
		
		protected static const GRADIENT_BG_COLOR1 = 0xD3D3D3;
		protected static const GRADIENT_BG_COLOR2 = 0xE4E4E4;
		protected static const GRADIENT_BG_COLOR3 = 0xF7F7F7;
		protected static const GRADIENT_BG_COLOR4 = 0xFFFFFF;
		protected static const GRADIENT_BG_COLORS = [GRADIENT_BG_COLOR1, GRADIENT_BG_COLOR2, GRADIENT_BG_COLOR3, GRADIENT_BG_COLOR4];
		protected static const GRADIENT_BG_ALPHAS = [1, 1, 1, 1];
		protected static const GRADIENT_BG_RATIOS = [0, 60, 170, 255];
		protected static const TO_RAD = Math.PI / 180;
		protected static const BORDER_COLOR = 0x969696;
		protected static const BORDER_WIDTH = 0.25;
		protected static const VERTICAL_SPACING = 5;
		protected static const HORIZONTAL_SPACING = 5;
		protected static const DEFAULT_FONT = myriadProFont.fontName;
		protected static const DEFAULT_TEXT_COLOR = 0x000000;
		protected static const DEFAULT_TEXT_SIZE = 13;
		protected static const EMBEDED_FONTS = true;
		
		protected static var _defaultTextFormat:TextFormat = new TextFormat(DEFAULT_FONT, DEFAULT_TEXT_SIZE, DEFAULT_TEXT_COLOR);
		public static function get defaultTextFormat():TextFormat { return _defaultTextFormat; }
		
		protected var _width:Number;
		protected var _height:Number;
		
		public function get displayWidth():Number { return _width; }
		public function set displayWidth(value:Number):void {
			_width = value;
			draw();
			fireResizeEvent();
		}
		
		public function get displayHeight():Number { return _height; }
		public function set displayHeight(value:Number):void {
			_height = value;
			draw();
			fireResizeEvent();
		}
		protected var _bgGradientMatrix = new Matrix();
		
		public function setSize(w:Number, h:Number):void {
			_width = w;
			_height = h;
			draw();
			fireResizeEvent();
		}
		
		/**
		 * Constructor. Creates new instance of <code>BaseControl</code>
		 * 
		 * @param	w	Width in pixels of current control.
		 * @param	h	Height in pixels of current control.
		 */
		public function BaseControl(w:Number = 0, h:Number = 0) {
			_width = w;
			_height = h;
		}
		
		protected function fireResizeEvent():void {
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		protected static function detachObject(obj:DisplayObject) {
			if(obj != null && obj.parent != null) {
				obj.parent.removeChild(obj);
			}
		}
		
		public function draw() :void { }
	}
}