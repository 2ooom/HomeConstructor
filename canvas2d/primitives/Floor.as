package canvas2d.primitives
{
	import core.FloorTexture;
	
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	public class Floor extends DrawingObjectBase
	{
		protected static const SELECTED_LINE_COLOR = 0x00D8FF;
		protected static const SELECTED_LINE_WIDTH = 1;
		
		protected var _vertexes = new Array();
		public function get vertexes():Array { return _vertexes; }
		
		protected var _texture:FloorTexture;
		public function get texture():FloorTexture { return _texture; }
		public function set texture(tex:FloorTexture) { _texture = tex;  draw(); }
		
		/**
		 * Sets whether object is selected (to select object click on it).
		 */
		override public function set isSelected(value:Boolean):void {
			if(value != _isSelected) {
				_isSelected = value;
				for each (var vert in _vertexes) {
					vert.isSelected = true;
				}
				draw();
			}
		}
		
		/**
		 * Constructor. Creates new <code>Wall</code>
		 */
		public function Floor(tex:FloorTexture) {
			super();
			_texture = tex;
		}
		
		public function addPoint(vert:Vertex):void {
			_vertexes.push(vert);
			vert.addEventListener(DrawingObjectBase.LOCATION_CHANGE, vertex_onLocationChange);
			vert.addReference(this);
			draw();
		}
		
		public function removePoint(vert:Vertex):void {
			var ind = _vertexes.indexOf(vert);
			if(ind > 0) {
				_vertexes.splice(ind, 1);
				vert.removeEventListener(DrawingObjectBase.LOCATION_CHANGE, vertex_onLocationChange);
				vert.removeReference(this);
			}
			draw();
		}
		
		protected function vertex_onLocationChange(e:Event):void {
			draw();
		}
		
		override public function draw():void {
			graphics.clear();
			var drawActive = isSelected || isActive;
			if(_vertexes.length > 2) {
				var local = getObjectPosLocal(_vertexes[0]);
				if(drawActive) {
					graphics.lineStyle(SELECTED_LINE_WIDTH, SELECTED_LINE_COLOR);
				}
				graphics.moveTo(local.x, local.y);
				graphics.beginBitmapFill(_texture.image.bitmapData);
				for(var i = 1; i < _vertexes.length; i++) {
					local = getObjectPosLocal(_vertexes[i]);
					graphics.lineTo(local.x, local.y);
				}
				graphics.endFill();
			}
		}
		
		protected function getObjectPosLocal(obj:DrawingObjectBase):Point {
			var global = obj.parent.localToGlobal(obj.position);
			return globalToLocal(global);
		}
		
		public function getVertexInSamePosition(vertex:Vertex):Vertex {
			var pos = vertex.position;
			for each(var vert in _vertexes) {
				if(vertex != vert && vert.x == pos.x && vert.y == pos.y) {
					return vert;
				}
			}
			return null;
		}
		
		override protected function stage_onMouseMove(e:MouseEvent):void {
			var prevPosition:Point = position;
			super.stage_onMouseMove(e);
			var dPos:Point = position.subtract(prevPosition);
			for each (var vert in _vertexes) {
				vert.position  = vert.position.add(dPos);
			}
		}
		
		/**
		 * IDisposable implementation
		 */
		override public function dispose():void {
			super.dispose();
			for each (var vert in _vertexes) {
				vert.removeEventListener(DrawingObjectBase.LOCATION_CHANGE, vertex_onLocationChange);
			}
		}
	}
}