package canvas2d.primitives
{
	import flash.geom.Point;
	
	public class Vertex extends DrawingObjectBase
	{
		protected static const VERTEX_RADIUS = 4;
		protected static const VERTEX_BORDER_WIDTH = 1;
		protected static const VERTEX_BORDER_COLOR = 0x000000;
		protected static const VERTEX_COLOR = 0x000000;
		protected static const VERTEX_COLOR_ACTIVE = 0xFFFFFF;
		protected static const VERTEX_COLOR_SELECTED = 0x00D8FF;
		protected static const VERTEX_BORDER_COLOR_ACTIVE = 0x000000;
		protected static const VERTEX_BORDER_COLOR_SELECTED = 0x00D8FF;
		
		protected var _references:Array = new Array();
		
		public function addReference(object:Object):void {
			_references.push(object);
		}
		
		public function getReferences():Array {
			var res:Array = new Array();
			for each(var ref in _references) {
				res.push(ref);
			}
			return res;
		}
		
		public function removeReference(object:Object):void {
			var index = _references.indexOf(object);
			if(index >= 0) _references.splice(index, 1);
		}
		public function get referencesNumber():Number { return _references.length; }
		public function get hasReferences():Boolean { return _references.length > 0; }
		
		/**
		 * Constructor. Creates new <code>Vertex</code>
		 */
		public function Vertex() {
			super();
		}
		
		override public function draw():void {
			var drawActive =  (isActive || isMoving) && !(isSelected);
			graphics.clear();
			var vertColor = VERTEX_COLOR;
			var borderColor = VERTEX_BORDER_COLOR;
			if(drawActive) {
				vertColor = VERTEX_COLOR_ACTIVE;
				borderColor = VERTEX_BORDER_COLOR_ACTIVE;
			}
			else if (isSelected) {
				vertColor = VERTEX_COLOR_SELECTED;
				borderColor = VERTEX_BORDER_COLOR_SELECTED;
			}
			graphics.beginFill(vertColor);
			graphics.drawCircle(0, 0, VERTEX_RADIUS);
			graphics.endFill();
			graphics.lineStyle(VERTEX_BORDER_WIDTH, borderColor);
			graphics.drawCircle(0, 0, VERTEX_RADIUS);
		}
	}
}