package canvas2d.primitives
{
	import canvas2d.Canvas2D;
	
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Wall extends Line
	{
		public static const DEFAULT_WALL_HEIGHT = 168; // ~253 sm
		
		protected var _firstVertex:Vertex;
		protected var _secondVertex:Vertex;
		
		/**
		 * Sets whether object is selected (to select object click on it).
		 */
		override public function set isSelected(value:Boolean):void {
			if(value != _isSelected) {
				_isSelected = value;
				if(firstVertex != null && firstVertex.referencesNumber == 1) firstVertex.isSelected = true;
				if(secondVertex != null && secondVertex.referencesNumber == 1) secondVertex.isSelected = true;
				draw();
			}
		}
		
		public function set firstVertex(vertex:Vertex):void {
			removeVertexEventListeners(_firstVertex);
			_firstVertex = vertex;
			addVertexEventListeners(vertex)
			draw();
		}
		
		public function get firstVertex():Vertex { return _firstVertex; }
		
		public function set secondVertex(vertex:Vertex):void {
			removeVertexEventListeners(_secondVertex);
			_secondVertex = vertex;
			addVertexEventListeners(vertex)
			draw();
		}
		
		public function get secondVertex():Vertex { return _secondVertex; }
		
		override public function get firstPointLocal():Point {
			if(_firstVertex == null) return new Point();
			if(_firstVertex.parent == null) return _firstVertex.position;
			
			var vertGlobal:Point = _firstVertex.parent.localToGlobal(_firstVertex.position);
			return globalToLocal(vertGlobal);
		}
		
		override public function get secondPointLocal():Point {
			if(_secondVertex == null) return new Point();
			if(_secondVertex.parent == null) return _secondVertex.position;
			
			var vertGlobal:Point = _secondVertex.parent.localToGlobal(_secondVertex.position);
			return globalToLocal(vertGlobal);
		}
		
		public function get wallWidth():Number { return lineWidth; }
		public function set wallWidth(value:Number):void { lineWidth = value; }
		
		protected var _wallHeight:Number = DEFAULT_WALL_HEIGHT;
		public function get wallHeight():Number { return _wallHeight; }
		public function set wallHeight(value:Number):void {	_wallHeight = value; }
		
		/**
		 * Constructor. Creates new <code>Wall</code>
		 */
		public function Wall() {
			super();
		}
		
		protected function vertex_onLocationChange(e:Event):void {
			draw();
		}
		
		protected function vertex_onMouseDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, vertex_OnMouseUp);
			isDrawing = true;
		}
		
		protected function vertex_OnMouseUp(e:MouseEvent):void {
			isDrawing = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, vertex_OnMouseUp);
		}
		
		protected function vertex_onRemoved(e:Event):void {}
		
		protected function removeVertexEventListeners(vertex:Vertex):void {
			if(vertex != null) {
				vertex.removeEventListener(DrawingObjectBase.LOCATION_CHANGE, vertex_onLocationChange);
				vertex.removeEventListener(MouseEvent.MOUSE_DOWN, vertex_onMouseDown);
				vertex.removeEventListener(Event.REMOVED, vertex_onRemoved);
				vertex.removeReference(this);
			}
		}
		
		protected function addVertexEventListeners(vertex:Vertex):void {
			if(vertex != null) {
				vertex.addEventListener(DrawingObjectBase.LOCATION_CHANGE, vertex_onLocationChange);
				vertex.addEventListener(MouseEvent.MOUSE_DOWN, vertex_onMouseDown);
				vertex.addEventListener(Event.REMOVED, vertex_onRemoved);
				vertex.addReference(this);
			}
		}
		
		override protected function stage_onMouseMove(e:MouseEvent):void {
			var prevPosition:Point = position;
			super.stage_onMouseMove(e);
			var dPos:Point = position.subtract(prevPosition);
			if(firstVertex != null) firstVertex.position = firstVertex.position.add(dPos);
			if(secondVertex != null) secondVertex.position = secondVertex.position.add(dPos);
		}
		
		/**
		 * IDisposable implementation 
		 */
		override public function dispose():void {
			super.dispose();
			removeVertexEventListeners(_firstVertex);
			removeVertexEventListeners(_secondVertex);
		}
	}
}