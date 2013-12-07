package gui.controls
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class PanelMenu extends ControlContainer
	{
		/**
		 * Constructor. Creates new instance of <code>PanelMenu</code>
		 * 
		 * @param	w	Width in pixels of current control.
		 * @param	h	Height in pixels of current control.
		 */
		public function PanelMenu(w:Number = 0, h:Number = 0) {
			super(w, h);
			setContainerScrollRect();
		}
		
		override protected function rearrangeChildControls():void {
			var startY  = 0;
			for(var i = 0; i < _container.numChildren; i++) {
				var obj = _container.getChildAt(i);
				obj.x = 0;
				obj.y = startY;
				startY += obj.height - BORDER_WIDTH;
			}
			if(useVertScrollBar) {
				_vertScrollbar.maximum = _container.height;
				setContainerScrollRect();
			}
		}		
	}
}