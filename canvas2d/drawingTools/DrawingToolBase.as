package canvas2d.drawingTools
{
	import canvas2d.Canvas2D;
	import canvas2d.primitives.Vertex;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.Stage;
	
	public class DrawingToolBase implements IDrawingTool
	{
		protected var _canvas:Canvas2D;
		protected var _isDrawing:Boolean = false;		
		
		protected function get _stage():Stage { return _canvas.stage; }
		
		protected function get _globalMousePosition():Point {
			return new Point(_stage.mouseX, _stage.mouseY);
		}
		
		protected function get _canvasMousePosition():Point {
			return _canvas.getNearestGridPoint(_globalMousePosition);
		}
		
		protected function get _canvasMousePositionGlobal():Point {
			return _canvas.pane.localToGlobal(_canvas.getNearestGridPoint(_globalMousePosition));
		}
		
		public function get isDrawing():Boolean { return _isDrawing; }
		
		/**
		 * Constructor. Creates new instance of <code>DrawingToolBase</code> object.
		 *
		 * @param	canvas	Canvas on which new drawing objects will be placed.
		 */
		public function DrawingToolBase(canvas:Canvas2D) {
			_canvas = canvas;
		}
		
		public function onStartDrawing(e:Event):void {}
		
		public function stopDrawing():void {}
	}
}