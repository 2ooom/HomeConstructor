package canvas2d.primitives
{
	import helpers.SizeUtility;
	import helpers.MathUtils;
	import canvas2d.Canvas2D;
	import gui.controls.BaseControl;
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	public class Line extends DrawingObjectBase
	{
		protected static const LINE_WIDTH_DEFAULT = 9;
		protected static const LINE_COLOR = 0x000000;
		protected static const LINE_COLOR_SELECTED = 0x00D8FF;
		protected static const LINE_COLOR_ACTIVE = 0x000000;
		protected static const LINE_COLOR_ACTIVE_OUTER = 0xFFFFFF;
		protected static const LINE_OUTER_BORDER_WIDTH = 2;
		protected static const SUB_LINE_COLOR = 0x000000;
		protected static const SUB_LINE_WIDTH = 1;
		protected static const SUB_LINE_DISTANCE = 10;
		protected static const SUB_TITLE_COLOR = 0x000000;
		protected static const SUB_TITLE_TEXT_SIZE = 11;
		protected static const SUB_TITLE_TEXT_BOTTOM_MARGIN = 4;
		protected static const SUB_TITLE_BG_COLOR = 0xFFFFFF;
		protected static const SUB_TITLE_BORDER_COLOR = 0x000000;
		protected static const SUB_TITLE_BOLD = true;
		protected static const SUB_LINE_ARROW_HOR_SHIFT = 8;
		protected static const SUB_LINE_ARROW_VERT_SHIFT = 2.5;
		
		protected var _lineWidth:Number = LINE_WIDTH_DEFAULT;
		public function get lineWidth():Number { return _lineWidth; }
		public function set lineWidth(value:Number):void { _lineWidth = value; }
		
		protected var _lineColor:Number = LINE_COLOR;
		public function get lineColor():Number { return _lineColor; }
		public function set lineColor(value:Number):void { _lineColor = value;  draw(); }
		
		protected var _drawSize:Boolean = true;
		public function get drawSize():Boolean { return _drawSize; }
		public function set drawSize(value:Boolean):void {
			if(value != _drawSize) {
				_drawSize = value;
				draw();
			}
		}
		
		protected var _simpleLine:Boolean = false;
		public function get simpleLine():Boolean { return _simpleLine; }
		public function set simpleLine(value:Boolean):void { _simpleLine = value; }
		
		protected var _txtLabel:TextField = new TextField();
		protected var _txtFormat:TextFormat = BaseControl.defaultTextFormat;
		protected var _firstPointLocal:Point = new Point(); 
		protected var _secondPointLocal:Point = new Point(); 
		
		public function get firstPointLocal():Point { return _firstPointLocal; }
		public function get secondPointLocal():Point { return _secondPointLocal; }
		
		public function set firstPointGlobal(point:Point):void {
			_firstPointLocal = globalToLocal(point);
		}

		public function set secondPointGlobal(point:Point):void {
			_secondPointLocal = globalToLocal(point);
		}
		
		/**
		 * Constructor. Creates new <code>Line</code>
		 */
		public function Line() {
			_txtFormat.bold = SUB_TITLE_BOLD;
			_txtFormat.size = SUB_TITLE_TEXT_SIZE;
			_txtLabel.defaultTextFormat = _txtFormat;
			_txtLabel.borderColor = SUB_TITLE_BORDER_COLOR;
			_txtLabel.textColor = SUB_TITLE_COLOR;
			_txtLabel.selectable = false;
			_txtLabel.backgroundColor = SUB_TITLE_BG_COLOR;
			_txtLabel.autoSize = TextFieldAutoSize.LEFT;
			addChild(_txtLabel);
			super();
		}
		
		override public function draw():void {
			var drawActive =  (isActive || isMoving || isDrawing) && !(isSelected);
			graphics.clear();
			_txtLabel.visible = false;
			if(drawActive || isSelected) { // draw measure helpers
				graphics.lineStyle(SUB_LINE_WIDTH, SUB_LINE_COLOR);
				var r = SUB_LINE_DISTANCE + lineWidth / 2;
				var dist = Point.distance(firstPointLocal, secondPointLocal);
				var rot = MathUtils.toDegrees(Math.atan((firstPointLocal.y - secondPointLocal.y)/(firstPointLocal.x - secondPointLocal.x))); 

				var firstSubPoint = MathUtils.getPerpendicularPoint(firstPointLocal, secondPointLocal, r, true);
				var secondSubPoint = MathUtils.getPerpendicularPoint(secondPointLocal, firstPointLocal, r, false);
				
				// draw second Point arrows
				drawArrows(firstSubPoint, secondSubPoint);
				// draw first Point arrows
				drawArrows(secondSubPoint, firstSubPoint);
				//draw connecting line
				graphics.moveTo(firstPointLocal.x, firstPointLocal.y);
				graphics.lineTo(firstSubPoint.x, firstSubPoint.y);
				graphics.lineTo(secondSubPoint.x, secondSubPoint.y);
				graphics.lineTo(secondPointLocal.x, secondPointLocal.y);
				
				// draw size container
				_txtLabel.text = SizeUtility.getMitersStr(dist);
				var middlePoint = Point.interpolate(firstSubPoint, secondSubPoint, 0.5);
				var labelLeftPoint = middlePoint.subtract(firstSubPoint);
				labelLeftPoint.normalize((dist - _txtLabel.width) / 2);
				labelLeftPoint = labelLeftPoint.add(firstSubPoint);
				var lblMargin = SUB_TITLE_TEXT_BOTTOM_MARGIN + _txtLabel.height;
				var labelPosition = MathUtils.getPerpendicularPoint(labelLeftPoint, firstSubPoint, lblMargin, false);
				_txtLabel.x = labelPosition.x;// - _txtLabel.width / 2;
				_txtLabel.y = labelPosition.y;// - _txtLabel.height / 2;
				//_txtLabel.rotationZ = rot;
				_txtLabel.visible = true;
			}
			// drawing simple line
			if(drawActive) {
				graphics.lineStyle(lineWidth, LINE_COLOR_ACTIVE);
				graphics.moveTo(firstPointLocal.x, firstPointLocal.y);
				graphics.lineTo(secondPointLocal.x, secondPointLocal.y);
				graphics.lineStyle(lineWidth - LINE_OUTER_BORDER_WIDTH, LINE_COLOR_ACTIVE_OUTER);
				graphics.moveTo(firstPointLocal.x, firstPointLocal.y);
				graphics.lineTo(secondPointLocal.x, secondPointLocal.y);
			}
			else if(simpleLine) {
				graphics.lineStyle(lineWidth, lineColor);
				graphics.moveTo(firstPointLocal.x, firstPointLocal.y);
				graphics.lineTo(secondPointLocal.x, secondPointLocal.y);
			}
			else {
				graphics.lineStyle(lineWidth, isSelected? LINE_COLOR_SELECTED : LINE_COLOR);
				graphics.moveTo(firstPointLocal.x, firstPointLocal.y);
				graphics.lineTo(secondPointLocal.x, secondPointLocal.y);
			}
		}
		
		protected function drawArrows(pointA:Point, pointB:Point):void {
			var horShiftPoint = pointB.subtract(pointA);
			horShiftPoint.normalize(SUB_LINE_ARROW_HOR_SHIFT);
			horShiftPoint = horShiftPoint.add(pointA);
			var vertShiftPointTop = new Point(pointB.y - pointA.y, (pointB.x - pointA.x) * -1);
			var vertShiftPointBottom = new Point((pointB.y - pointA.y) * -1, pointB.x - pointA.x);
			vertShiftPointTop.normalize(SUB_LINE_ARROW_VERT_SHIFT);
			vertShiftPointBottom.normalize(SUB_LINE_ARROW_VERT_SHIFT);
			vertShiftPointTop.offset(horShiftPoint.x, horShiftPoint.y);
			vertShiftPointBottom.offset(horShiftPoint.x, horShiftPoint.y);
			graphics.moveTo(vertShiftPointTop.x, vertShiftPointTop.y);
			graphics.lineTo(pointA.x, pointA.y);
			graphics.lineTo(vertShiftPointBottom.x, vertShiftPointBottom.y);
		}
	}
}