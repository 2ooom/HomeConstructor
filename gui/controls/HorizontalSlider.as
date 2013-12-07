package gui.controls
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * Represents the base functionality for Sliders.
	 */
	[Event(name="change", type="flash.events.Event")]
	public class HorizontalSlider extends BaseControl
	{
		protected static const MARKER_BG_COLOR = 0x333333;
		protected static const TRACK_BG_COLOR = 0xCCCCCC;
		
		protected var _marker:Sprite = new Sprite();
		
		protected var _percent:Number = 0;		
		protected var _maximum:Number;
		
		protected function get markerMinimum():Number { return 0; }
		protected function get markerMaximum():Number { return _width; }
		protected function get trackSize():Number { return markerMaximum - markerMinimum; }	
		
		public function get maximum():Number { return _maximum; }
		
		public function set maximum(value:Number):void {
			if(value < _width) _maximum = _width;
			_maximum = value;
			draw();
		}
		
		protected function get markerSize():Number {
			return (trackSize / maximum) * _width ;
		}
		/**
		 * The percent is represented as a value between 0 and 1.
		 */
		public function get percent():Number { return _percent; }
		
		public function set percent(p:Number):void {
			_percent = Math.min(1, Math.max(0, p));
			_marker.x = _percent * (trackSize - _marker.width);
			fireChangeEvent();
		}
		
		/**
		 * Constructor. Creates new instance of <code>HorizontalSlider</code>
		 * 
		 * @param	w		Width in pixels of current control.
		 * @param	h		Height in pixels of current control.
		 */
		public function HorizontalSlider(w:Number = 0, h:Number = 0) {
			super(w, h);
			_maximum = _width;
			_marker.addEventListener(MouseEvent.MOUSE_DOWN, marker_onMouseDown);
			addChild(_marker);
			draw();
		}
		
		// ends the sliding session
		protected function stage_onMouseUp(e:MouseEvent):void {
			_marker.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
		}
		
		// updates the data to reflect the visuals
		protected function stage_onMouseMove(e:MouseEvent):void {
			e.updateAfterEvent();
			_percent = _marker.x / (trackSize - _marker.width);
			
			fireChangeEvent();
		}
		
		//  Executed when the _marker is pressed by the user.
		protected function marker_onMouseDown(e:MouseEvent):void {
			_marker.startDrag(false, new Rectangle(0, 0, trackSize - _marker.width, 0));
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
		} 
		
		override public function draw():void {
			graphics.clear();
			graphics.beginFill(TRACK_BG_COLOR);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			_marker.graphics.clear();
			_marker.graphics.beginFill(MARKER_BG_COLOR);
			_marker.graphics.drawRect(markerMinimum, 0, markerSize, _height);
			_marker.graphics.endFill();
		}
		
		protected function fireChangeEvent():void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * IDisplosable Implementation
		 */
		public function dispose():void {
			if(_marker != null) {
				_marker.removeEventListener(MouseEvent.MOUSE_DOWN, marker_onMouseDown);
			}
			if(stage != null) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
			}
		}
	}
}