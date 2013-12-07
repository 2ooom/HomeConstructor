package canvas2d.drawingTools
{
	import canvas2d.primitives.*;
	import canvas2d.*;
	import core.*;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	public class WallDrawingTool extends DrawingToolBase
	{
		protected var _drawingWall:Wall;
		protected var _drawingVertex:Vertex;
		
		/**
		 * Constructor. Creates new instanse of <code>WallDrawingTool</code> object.
		 *
		 * @param	canvas	Canvas on which new walls will be placed.
		 */
		public function WallDrawingTool(canvas:Canvas2D) {
			super(canvas);
		}
		
		override public function onStartDrawing(e:Event):void {
			_isDrawing = true;
			_drawingVertex = new Vertex();
			_drawingVertex.position = _canvasMousePosition;
			_stage.addEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			_canvas.addDrawingObject(_drawingVertex);
			_drawingVertex.isDrawing = true;
			_drawingVertex.startMoving();
		}
		
		protected function stage_OnMouseUp(e:MouseEvent):void {
			if(_drawingWall != null) _drawingWall.isDrawing = false;
			var underVertex:Vertex = _canvas.getVertexInSamePosition(_globalMousePosition, [_drawingVertex]);
			if(underVertex != null) {
				_canvas.swapDrawingChildren(underVertex, _drawingVertex);
				_drawingVertex.removeReference(_drawingWall);
				_drawingVertex.dispose();
				_canvas.removeDrawingObject(_drawingVertex);
				_drawingVertex = underVertex;
				if(_drawingWall != null) {
					_drawingWall.secondVertex = _drawingVertex;
					return finalizeDrawing();
				}
			}
			_drawingWall = new Wall();
			_drawingWall.firstVertex = _drawingVertex;
			_drawingWall.isDrawing = true;
			_drawingWall.position = _canvasMousePosition;
			_canvas.addDrawingObject(_drawingWall);
			_canvas.swapDrawingChildren(_drawingVertex, _drawingWall);
			_drawingVertex.stopMoving();
			_drawingVertex.isDrawing = false;
			_drawingVertex = new Vertex();
			_drawingVertex.position = _canvasMousePosition;
			_canvas.addDrawingObject(_drawingVertex);
			_drawingVertex.isDrawing = true;
			_drawingVertex.startMoving();
			_drawingWall.secondVertex = _drawingVertex;
		}
		
		protected function finalizeDrawing():void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			if(_drawingVertex != null) {
				_drawingVertex.isDrawing = false;
				_drawingVertex.isActive = false;
				_drawingVertex.stopMoving();
			}
			if(_drawingWall != null) {
				_drawingWall.isDrawing = false;
				_drawingWall.isActive = false;
			}
			_drawingWall = null;
			_drawingVertex = null;
			_isDrawing = false;
		}
		
		override public function stopDrawing():void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			if(_drawingVertex != null) {
				_drawingVertex.removeReference(_drawingWall);
				_drawingVertex.dispose();
				_canvas.removeDrawingObject(_drawingVertex);
			}
			if(_drawingWall != null) {
				_drawingWall.dispose();
				var fVert = _drawingWall.firstVertex;
				if(fVert && !fVert.hasReferences) {
					fVert.dispose();
					_canvas.removeDrawingObject(fVert);
				}
				_canvas.removeDrawingObject(_drawingWall);
			}
			_drawingWall = null;
			_drawingVertex = null;
			_isDrawing = false;
		}
	}
}