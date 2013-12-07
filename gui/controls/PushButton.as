package gui.controls
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	[Event(name="select", type="flash.events.Event")]
	public class PushButton extends ControlContainer
	{
		protected static const GRADIENT_BG_COLORS_ALTERNATIVE = [GRADIENT_BG_COLOR4, GRADIENT_BG_COLOR3, GRADIENT_BG_COLOR2, GRADIENT_BG_COLOR1];

		/**
		 * Gets/sets associated object which could be usefull when button event is triggered.
		 */
		protected var _associatedObj:Object;
		public function get associatedObj():Object { return _associatedObj; }
		public function set associatedObj(value:Object):void { _associatedObj = value; }
		
		protected var _isPushed = false;
		
		/**
		 * Gets/sets event handling function to handle the default event for this component (click in this case).
		 */
		protected var _defaultHandler:Function;
		public function get defaultHandler():Function { return _defaultHandler; }
		public function set defaultHandler(value:Function):void {
			detachDefaultHandler(_defaultHandler);
			_defaultHandler = value;
			attachDefaultHandler(_defaultHandler);
		}
		
		public function set isPushed(value:Boolean):void {
			if(_isPushed != value) {
				togglePushed();
			}
		}
		
		public function get isPushed():Boolean {
			return _isPushed;
		}
		
		/**
		 * Constructor. Creates new instance of <code>PushButton</code>
		 * 
		 * @param	w	Width in pixels of current control.
		 * @param	h	Height in pixels of current control.
		 * @param	content	Child controls which will be added to control layout.
		 */
		public function PushButton(w:Number = 0, h:Number = 0, ...content) {
			super(w, h);
			addChildren(content);
			buttonMode = true;
			useHandCursor = true;
			attachDefaultHandler(onClick);
			draw();
		}
		
		protected function attachDefaultHandler(handler:Function):void {
			if(handler != null) addEventListener(MouseEvent.CLICK, handler);
		}
		
		protected function detachDefaultHandler(handler:Function):void {
			if(handler != null)	removeEventListener(MouseEvent.CLICK, handler);
		}
		
		protected function onClick(e:MouseEvent):void {
			isPushed = true;
		}
		
		protected function togglePushed():void {
			_isPushed = !_isPushed;
			if(_isPushed) fireSelectedEvent();
			draw();
		}
		
		override public function draw():void {
			_bgGradientMatrix.createGradientBox(_width, _height, -90 * TO_RAD);
			graphics.clear();
			graphics.lineStyle(BORDER_WIDTH, BORDER_COLOR);
			if(_isPushed) graphics.beginGradientFill(GradientType.LINEAR, GRADIENT_BG_COLORS_ALTERNATIVE, GRADIENT_BG_ALPHAS, GRADIENT_BG_RATIOS, _bgGradientMatrix);
			else graphics.beginGradientFill(GradientType.LINEAR, GRADIENT_BG_COLORS, GRADIENT_BG_ALPHAS, GRADIENT_BG_RATIOS, _bgGradientMatrix);
			
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		protected function fireSelectedEvent():void {
			dispatchEvent(new Event(Event.SELECT));
		}
		
		/**
		 * IDisplosable Implementation
		 */
		override public function dispose():void {
			detachDefaultHandler( onClick);
			super.dispose();
		}
	}
}