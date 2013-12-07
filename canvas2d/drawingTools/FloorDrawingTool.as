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
	import flash.display.Sprite;
	
	public class FloorDrawingTool extends DrawingToolBase
	{
		public static var texture:FloorTexture;
		
		protected static const LINE_COLOR = 0x000000;
		protected static const LINE_WIDTH = 1;
		
		protected var _drawingFloor:Floor;
		protected var _drawingVertex:Vertex;
		protected var _drawingLine:Wall;
		protected var _firstVertex:Vertex;
		protected var _firstPos:Point;
		protected var _firstLine:Sprite;
		protected var _drawingFirstLine:Boolean;
		
		/**
		 * Constructor. Creates new instanse of <code>FloorDrawingTool</code> object.
		 *
		 * @param	canvas	Canvas on which new walls will be placed.
		 */
		public function FloorDrawingTool(canvas:Canvas2D) {
			super(canvas);
		}
		
		override public function onStartDrawing(e:Event):void {
			_isDrawing = true;
			_drawingFirstLine = true;
			_firstPos = _canvasMousePosition;
			_firstLine = new Sprite();
			_firstLine.x = _firstPos.x;
			_firstLine.y = _firstPos.y;
			_drawingFloor = new Floor(texture);
			_canvas.addDrawingObject(_drawingFloor);
			_firstVertex = new Vertex();
			_firstVertex.position = _firstPos;
			_drawingVertex = new Vertex();
			_drawingVertex.position = _firstPos;
			_stage.addEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_OnMouseMove);
			_canvas.addChild(_firstLine);
			_canvas.addDrawingObject(_firstVertex);
			_canvas.addDrawingObject(_drawingVertex);
			_drawingFloor.addPoint(_firstVertex);
			_drawingFloor.addPoint(_drawingVertex);
			_drawingVertex.isDrawing = true;
			_drawingFloor.isDrawing = true;
			_drawingVertex.startMoving();
		}
		
		protected function stage_OnMouseMove(e:MouseEvent):void {
			var pos = _firstLine.globalToLocal(_drawingVertex.parent.localToGlobal(_drawingVertex.position));
			_firstLine.graphics.clear();
			_firstLine.graphics.lineStyle(LINE_WIDTH, LINE_COLOR);
			_firstLine.graphics.moveTo(0, 0);
			_firstLine.graphics.lineTo(pos.x, pos.y);
		}
		
		protected function stage_OnMouseUp(e:MouseEvent):void {
			var pos = _drawingVertex.position;
			if(_drawingFirstLine) {
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_OnMouseMove);
				_canvas.removeChild(_firstLine);
				_drawingFirstLine = false;
			}
			var underVertex:Vertex = _drawingFloor.getVertexInSamePosition(_drawingVertex);
			if(underVertex != null) {
				_canvas.swapDrawingChildren(underVertex, _drawingVertex);
				_drawingVertex.dispose();
				_canvas.removeDrawingObject(_drawingVertex);
				_drawingFloor.removePoint(_drawingVertex);
				_drawingVertex = underVertex;
				return finalizeDrawing();
			}
			_drawingVertex.stopMoving();
			_drawingVertex = new Vertex();
			_drawingVertex.position = pos;
			_canvas.addDrawingObject(_drawingVertex);
			_drawingFloor.addPoint(_drawingVertex);
			_drawingVertex.startMoving();
		}
		
		protected function finalizeDrawing():void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			if(_drawingFirstLine) {
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_OnMouseMove);
				_canvas.removeChild(_firstLine);
			}
			if(_drawingVertex != null) {
				_drawingVertex.isDrawing = false;
				_drawingVertex.isActive = false;
				_drawingVertex.stopMoving();
			}
			if(_drawingFloor != null) {
				_drawingFloor.isDrawing = false;
				_drawingFloor.isActive = false;
			}
			_drawingFloor = null;
			_drawingVertex = null;
			_isDrawing = false;
		}
		
		override public function stopDrawing():void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			if(_drawingFloor != null) {
				_drawingFloor.isDrawing = false;
				_drawingFloor.isActive = false;
				if(_drawingVertex != null) {
					_drawingFloor.removePoint(_drawingVertex);
				}
			}
			if(_drawingVertex != null) {
				_drawingVertex.dispose();
				_canvas.removeDrawingObject(_drawingVertex);
			}
			if(_drawingFirstLine) {
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_OnMouseMove);
				_canvas.removeChild(_firstLine);
				_firstVertex.dispose();
				_canvas.removeDrawingObject(_firstVertex);
				_drawingFloor.dispose();
				_canvas.removeDrawingObject(_drawingFloor);
			}
			if(!_drawingFirstLine && _drawingFloor.vertexes.length < 3) {
				_drawingFloor.dispose();
				_canvas.removeDrawingObject(_drawingFloor);
				for each(var vert in _drawingFloor.vertexes) {
					vert.dispose();
					_canvas.removeDrawingObject(vert);
				}
			}
			_drawingFloor = null;
			_drawingVertex = null;
			_isDrawing = false;
		}
	}
}