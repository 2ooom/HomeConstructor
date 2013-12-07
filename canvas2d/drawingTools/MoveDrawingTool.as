package canvas2d.drawingTools
{
	import canvas2d.Canvas2D;
	import canvas2d.primitives.DrawingObjectBase;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.Stage;
	
	public class MoveDrawingTool extends DrawingToolBase
	{
		/**
		 * Constructor. Creates new instanse of <code>MoveDrawingTool</code> object.
		 *
		 * @param	canvas	Canvas on which new wall rectangle will be placed.
		 */
		public function MoveDrawingTool(canvas:Canvas2D) {
			super(canvas);
		}
		
		override public function onStartDrawing(e:Event):void {
			_isDrawing = true;
			_canvas.enableChildrenInteractivity();
			_canvas.pane.addEventListener(Event.ADDED, canvas_onAdd);
		}
		
		protected function canvas_onAdd(e:Event):void {
			_canvas.enableChildInteractivity(e.target as DrawingObjectBase);
		}
		
		override public function stopDrawing():void {
			_canvas.disableChildrenInteractivity();
			_canvas.pane.removeEventListener(Event.ADDED, canvas_onAdd);
			_isDrawing = false;
		}
	}
}