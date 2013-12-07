package canvas2d.drawingTools
{
	import canvas2d.Canvas2D;
	import canvas2d.primitives.Vertex;
	import canvas2d.primitives.Wall;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.Stage;
	
	public class RectangleDrawingTool extends WallDrawingTool
	{
		protected static const WALLS_NUMBER_IN_ROOM = 4;
		protected var _topWall:Wall;
		protected var _rightWall:Wall;
		protected var _bottomWall:Wall;
		protected var _leftWall:Wall;
		
		protected var _topLeftVertex:Vertex;
		protected var _topRightVertex:Vertex;
		protected var _bottomRightVertex:Vertex;
		protected var _bottomLeftVertex:Vertex;
		
		protected var _roomWalls:Array;
		protected var _roomVertexes:Array;
		
		/**
		 * Constructor. Creates new instanse of <code>RectangleDrawingTool</code> object.
		 *
		 * @param	canvas	Canvas on which new wall rectangle will be placed.
		 */
		public function RectangleDrawingTool(canvas:Canvas2D) {
			super(canvas);
		}
		
		override public function onStartDrawing(e:Event):void {
			_isDrawing = true;
			_roomWalls = new Array();
			_roomVertexes = new Array();
			var canvasPos:Point = _canvasMousePosition;
			for(var i = 0; i < WALLS_NUMBER_IN_ROOM; i++) {
				_roomWalls[i] = new Wall();
				_roomWalls[i].x = canvasPos.x;
				_roomWalls[i].y = canvasPos.y;
				_roomWalls[i].isDrawing = true;
				_canvas.addDrawingObject(_roomWalls[i]);
			}
			for(i = 0; i < WALLS_NUMBER_IN_ROOM; i++) {
				_roomVertexes[i] = new Vertex();
				_roomVertexes[i].x = canvasPos.x;
				_roomVertexes[i].y = canvasPos.y;
				_roomVertexes[i].isDrawing = true;
				_canvas.addDrawingObject(_roomVertexes[i]);
				//var fVertInd:Number = i == WALLS_NUMBER_IN_ROOM - 1? 0 : i + 1;
				//_roomWalls[fVertInd].firstVertex = _roomVertexes[i];
				//_roomWalls[i].secondVertex = _roomVertexes[i];
			}
			
			_topWall = _roomWalls[0];
			_rightWall = _roomWalls[1];
			_bottomWall = _roomWalls[2];
			_leftWall = _roomWalls[3];
			
			_topRightVertex = _roomVertexes[0];
			_bottomRightVertex = _roomVertexes[1];
			_bottomLeftVertex = _roomVertexes[2];
			_topLeftVertex = _roomVertexes[3];
			
			_topWall.firstVertex = _topLeftVertex;
			_topWall.secondVertex = _topRightVertex;
			_rightWall.firstVertex = _topRightVertex;
			_rightWall.secondVertex = _bottomRightVertex;
			_bottomWall.firstVertex = _bottomRightVertex;
			_bottomWall.secondVertex = _bottomLeftVertex;
			_leftWall.firstVertex = _bottomLeftVertex;
			_leftWall.secondVertex = _topLeftVertex;
			_stage.addEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_OnMouseMove);
			
			_bottomRightVertex.startMoving();
		}
		
		protected function stage_OnMouseMove(e:MouseEvent):void {
			_bottomLeftVertex.position = new Point(_topLeftVertex.x, _bottomRightVertex.y);
			_topRightVertex.position = new Point(_bottomRightVertex.x, _topLeftVertex.y);
		}
		
		override protected function stage_OnMouseUp(e:MouseEvent):void {
			if(_topLeftVertex.position.equals(_topRightVertex.position) &&
				_topLeftVertex.position.equals(_bottomRightVertex.position) &&
				_topLeftVertex.position.equals(_bottomLeftVertex.position)) {
				stopDrawing();
			}
			else {
				var underVertex:Vertex = _canvas.getVertexInSamePosition(_canvas.localToGlobal(_topLeftVertex.position), [_topLeftVertex]);
				if(underVertex != null) {
					_canvas.swapDrawingChildren(_topLeftVertex, underVertex);
					_topLeftVertex.removeReference(_topWall);
					_topLeftVertex.removeReference(_leftWall);
					_topLeftVertex.dispose();
					_canvas.removeDrawingObject(_topLeftVertex);
					_topLeftVertex = underVertex;
					_topWall.firstVertex = _topLeftVertex;
					_leftWall.secondVertex = _topLeftVertex;
				}
				underVertex = _canvas.getVertexInSamePosition(_canvas.pane.localToGlobal(_topRightVertex.position), [_topRightVertex]);
				if(underVertex != null) {
					_canvas.swapDrawingChildren(_topRightVertex, underVertex);
					_topRightVertex.removeReference(_topWall);
					_topRightVertex.removeReference(_rightWall);
					_topRightVertex.dispose();
					_canvas.removeDrawingObject(_topRightVertex);
					_topRightVertex = underVertex;
					_rightWall.firstVertex = _topRightVertex;
					_topWall.secondVertex = _topRightVertex;
				}
				underVertex = _canvas.getVertexInSamePosition(_canvas.pane.localToGlobal(_bottomRightVertex.position), [_bottomRightVertex]);
				if(underVertex != null) {
					_canvas.swapDrawingChildren(_bottomRightVertex, underVertex);
					_bottomRightVertex.removeReference(_bottomWall);
					_bottomRightVertex.removeReference(_rightWall);
					_bottomRightVertex.dispose();
					_canvas.removeDrawingObject(_bottomRightVertex);
					_bottomRightVertex = underVertex;
					_bottomWall.firstVertex = _bottomRightVertex;
					_rightWall.secondVertex = _bottomRightVertex;
				}
				underVertex = _canvas.getVertexInSamePosition(_canvas.pane.localToGlobal(_bottomLeftVertex.position), [_bottomLeftVertex]);
				if(underVertex != null) {
					_canvas.swapDrawingChildren(_bottomLeftVertex, underVertex);
					_bottomLeftVertex.removeReference(_bottomWall);
					_bottomLeftVertex.removeReference(_leftWall);
					_bottomLeftVertex.dispose();
					_canvas.removeDrawingObject(_bottomLeftVertex);
					_bottomLeftVertex = underVertex;
					_leftWall.firstVertex = _bottomLeftVertex;
					_bottomWall.secondVertex = _bottomLeftVertex;
				}
				finalizeDrawing();
			}
		}
		
		override protected function finalizeDrawing():void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_OnMouseMove);
			_bottomRightVertex.stopMoving();
			for (var i = 0; i < WALLS_NUMBER_IN_ROOM; i++ ) {
				_roomVertexes[i].isDrawing = false;
				_roomWalls[i].isDrawing = false;
			}
			_isDrawing = false;
		}
		
		override public function stopDrawing():void {
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_OnMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_OnMouseMove);
			for (var i = 0; i < WALLS_NUMBER_IN_ROOM; i++ ) {
				_roomVertexes[i].dispose();
				_canvas.removeDrawingObject(_roomVertexes[i]);
				_roomWalls[i].dispose();
				_canvas.removeDrawingObject(_roomWalls[i]);
			}
			_isDrawing = false;
		}
	}
}