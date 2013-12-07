package gui.controls
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class SimplePushButton extends PushButton
	{
		/**
		 * Constructor. Creates new instance of <code>SimplePushButton</code>
		 * 
		 * @param	w		Width in pixels of current control.
		 * @param	h		Height in pixels of current control.
		 * @param	content	Child controls which will be added to control layout.
		 */
		public function SimplePushButton(w:Number = 0, h:Number = 0, ...content) {
			super(w, h, content);
		}
		
		override protected function attachDefaultHandler(handler:Function):void {
			if(handler != null) addEventListener(MouseEvent.MOUSE_DOWN, handler);
		}
		
		override protected function detachDefaultHandler(handler:Function):void {
			if(handler != null)	removeEventListener(MouseEvent.MOUSE_DOWN, handler);
		}
		
		override public function draw():void {
			graphics.clear();
		}
	}
}