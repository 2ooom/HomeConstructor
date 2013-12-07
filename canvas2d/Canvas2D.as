package canvas2d
{
	import canvas2d.drawingTools.*;
	import canvas2d.primitives.*;
	import core.*;
	import gui.controls.*;
	import gui.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.ui.Keyboard;
	
	public class Canvas2D extends Sprite implements IDisposable
	{
		public static const DEFAULT_WALL_HEIGHT = 168; // ~253 sm
		public static const DEFAULT_WALL_WIDTH = 9; // ~14 sm
		
		protected static const BG_COLOR = 0xFFFFFF;
		protected static const BORDER_COLOR = 0x000000;
		protected static const BORDER_WIDTH = 1;
		protected static const GRID_LINE_WIDTH = 1;
		protected static const GRID_STRONG_LINE_WIDTH = 1;
		protected static const GRID_LINE_COLOR = 0xF5F5F5;
		protected static const GRID_STRONG_LINE_COLOR = 0xC0C0C0;
		protected static const STEP_SIZE = 11;
		protected static const HALF_STEP_SIZE = STEP_SIZE / 2;
		protected static const STEPS_IN_STRONG_LINE = 5;
		protected static const STRONG_STEP_SIZE = STEPS_IN_STRONG_LINE * STEP_SIZE;
		protected static const SCROLLBAR_WIDTH = 10;
		protected static const SCROLL_SPEED = .03;
		
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var _border:Shape = new Shape();
		protected var _pane:Sprite = new Sprite();
		public function get pane():Sprite { return _pane; }
		
		public var snapToGrid:Boolean;
		protected var _toolBox:ToolBox;
		protected var _furnitureDrawingTool:FurnitureDrawingTool
		protected var _drawingToolFactory:DrawingToolFactory;
		protected var _verticalScrollBar:VerticalScrollBar;
		protected var _horizontalScrollBar:HorizontalScrollBar;
		
		protected var _wallWidth:Number = DEFAULT_WALL_WIDTH;
		public function get wallWidth():Number { return _wallWidth;	}		
		public function set wallWidth(value:Number):void { _wallWidth = value; }
		
		protected var _wallHeight:Number = DEFAULT_WALL_HEIGHT;
		public function get wallHeight():Number { return _wallHeight; }
		public function set wallHeight(value:Number):void {	_wallHeight = value; }
		
		protected var _actualWidth:Number;
		public function get actualWidth():Number { return _actualWidth; }
		public function set actualWidth(value:Number):void { _actualWidth = value; }
		
		protected var _actualHeight:Number;
		public function get actualHeight():Number { return _actualHeight; }
		public function set actualHeight(value:Number):void { _actualHeight = value; }
		
		protected function get currentFloorTexture():FloorTexture { return FloorDrawingTool.texture; }
		protected function set currentFloorTexture(value:FloorTexture):void { FloorDrawingTool.texture = value;}
		
		protected var _currentDrawingTool:IDrawingTool;		
		protected var _currentDrawingToolType:String;
		
		public function get currentDrawingToolType():String { return _currentDrawingToolType; }
		public function set currentDrawingToolType(value:String) {
			if(value != _currentDrawingToolType) {
				stopDrawing();
				_currentDrawingTool = _drawingToolFactory.getDrawingTool(value);
				if(_currentDrawingTool is MoveDrawingTool) {
					_currentDrawingTool.onStartDrawing(new Event(MouseEvent.MOUSE_DOWN));
				}
				_currentDrawingToolType = value;
			}
		}
		
		/**
		 * Constructor. Creates new instance of <code>Canvas2D</code>.
		 *
		 * @param w			Width of canvas control on stage layout.
		 * @param h			Width of canvas control on stage layout.
		 * @param actWidth	Width of srawing pane available with scrooling.
		 * @param actHeight	Width of srawing pane available with scrooling.
		 * @param roolbox	ToolBox control assigned to current canvas.
		 *
		 */
		public function Canvas2D(w:Number, h:Number, actWidth:Number, actHeight:Number, toolBox:ToolBox) {
			_width = w;
			_height = h;
			actualWidth = actWidth;
			actualHeight = actHeight;
			scrollRect = new Rectangle(0, 0, _width, _height);
			_drawingToolFactory = new DrawingToolFactory(this);
			_furnitureDrawingTool = new FurnitureDrawingTool(this);
			_toolBox = toolBox;
			_toolBox.rectangleBtn.isPushed = true;
			_toolBox.addEventListener(ToolBoxEvent.FURNITURE_SELECT, toolBox_onFurnitureItemSelected);
			_toolBox.addEventListener(ToolBoxEvent.FLOOR_TEXTURE_SELECT, toolBox_onFloorTextureSelected);
			_toolBox.addEventListener(ToolBoxEvent.WALL_TEXTURE_SELECT, toolBox_onWallTextureSelected);
			_toolBox.addEventListener(ToolBoxEvent.DAWING_TOOL_SELECT, toolBox_onDrawingToolSelected);
			currentDrawingToolType = DrawingToolFactory.RECTANGLE_DRAWING_TOOL;
			_verticalScrollBar = new VerticalScrollBar(SCROLLBAR_WIDTH, _height - SCROLLBAR_WIDTH);
			_verticalScrollBar.addEventListener(Event.CHANGE, onVerticalScrollUpdated);
			_verticalScrollBar.maximum = actualHeight;
			_horizontalScrollBar = new HorizontalScrollBar(_width - SCROLLBAR_WIDTH, SCROLLBAR_WIDTH);
			_horizontalScrollBar.addEventListener(Event.CHANGE, onHorizontalScrollUpdated);
			_horizontalScrollBar.maximum = actualWidth;
			addChild(_pane);
			addChild(_border);
			addChild(_verticalScrollBar);
			addChild(_horizontalScrollBar);
			draw();
			_pane.addEventListener(MouseEvent.MOUSE_DOWN, pane_onMouseDown);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			_verticalScrollBar.percent = .5;
			_horizontalScrollBar.percent = .5;
		}
		
		protected function onVerticalScrollUpdated(e:Event):void {
			var sender = e.target;
			var scrollable = sender.maximum - scrollRect.height;
			var sr = scrollRect.clone();
			sr.y = scrollable * sender.percent;
			scrollRect = sr;
			positionBorder();
		}
		
		protected function onHorizontalScrollUpdated(e:Event):void {
			var sender = e.target;
			var scrollable = sender.maximum - scrollRect.width;
			var sr = scrollRect.clone();
			sr.x = scrollable * sender.percent;
			scrollRect = sr;
			positionBorder();
		}
		
		protected function onAddedToStage(e:Event):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
		}
		
		protected function onRemovedFromStage(e:Event):void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
		}
		
		protected function getAllDrawingObjects():Array {
			var res:Array = new Array();
			for(var i = 0; i < _pane.numChildren; i++ ) {
				var drawingObj = _pane.getChildAt(i) as DrawingObjectBase;
				if(drawingObj != null) res.push(drawingObj);
			}
			return res;
		}
		
		protected function getSelectedDrawingObjects():Array {
			var res:Array = new Array();
			var drawingObjects:Array = getAllDrawingObjects();
			for each(var drawingObj:DrawingObjectBase in drawingObjects ) {
				if(drawingObj.isSelected) res.push(drawingObj);
			}
			return res;
		}
		
		protected function keyboardListener(e:KeyboardEvent):void {
			if(!visible) return;
			var selectedObjects = getSelectedDrawingObjects();
			var noSelections = selectedObjects == null || selectedObjects.length == 0;
			switch(e.keyCode) {
				case Keyboard.ESCAPE:
				case Keyboard.Q:
					stopDrawing();
					break;
				case Keyboard.DELETE:
					deleteSelectedObjects();
					break;
				case Keyboard.LEFT:
					if(noSelections) _horizontalScrollBar.percent += -SCROLL_SPEED;
					break;
				case Keyboard.RIGHT:
					if(noSelections) _horizontalScrollBar.percent += SCROLL_SPEED;
					break;
				case Keyboard.UP:
					if(noSelections) _verticalScrollBar.percent += -SCROLL_SPEED;
					break;
				case Keyboard.DOWN:
					if(noSelections) _verticalScrollBar.percent += SCROLL_SPEED;
					break;
				default:
					break;
			}
		}
		
		protected function deleteSelectedObjects():void {
			var selectedObjects = getSelectedDrawingObjects();
			for each(var drawingObj:DrawingObjectBase in selectedObjects) {
				var vert:Vertex = drawingObj as Vertex;
				if(vert != null) {
					var refs:Array = vert.getReferences();
					for each(var ref:DrawingObjectBase in refs) {
						ref.dispose();
						if(ref.parent == _pane) removeDrawingObject(ref);
					}
				}
				drawingObj.dispose();
				if(drawingObj.parent == _pane)removeDrawingObject(drawingObj);
			}
		}
		
		protected function stopDrawing():void {
			if(_currentDrawingTool != null && _currentDrawingTool.isDrawing) {
				_currentDrawingTool.stopDrawing();
			}
			if(_furnitureDrawingTool != null && _furnitureDrawingTool.isDrawing) {
				_furnitureDrawingTool.stopDrawing();
			}
		}
		
		public function draw():void {
			addBorder();
			// draw grid lines
			_pane.graphics.clear();
			_pane.graphics.beginFill(BG_COLOR);
			_pane.graphics.drawRect(0, 0, actualWidth, actualHeight);
			_pane.graphics.endFill();
			_pane.graphics.lineStyle(GRID_LINE_WIDTH, GRID_LINE_COLOR);
			drawLines(STEP_SIZE);
			// draw strong lines
			_pane.graphics.lineStyle(GRID_STRONG_LINE_WIDTH, GRID_STRONG_LINE_COLOR);
			drawLines(STRONG_STEP_SIZE);
		}
		
		protected function addBorder():void {
			_border.graphics.clear();
			_border.graphics.lineStyle(BORDER_WIDTH, BORDER_COLOR);
			_border.graphics.drawRect(0, 0, _width, _height);
			_border.graphics.endFill();
			positionBorder();
		}
		
		protected function positionBorder():void {
			_border.x = scrollRect.x;
			_border.y = scrollRect.y;
			_verticalScrollBar.x = scrollRect.x + _width - SCROLLBAR_WIDTH;
			_verticalScrollBar.y = scrollRect.y;
			_horizontalScrollBar.x = scrollRect.x;
			_horizontalScrollBar.y = scrollRect.y + _height - SCROLLBAR_WIDTH;
		}
		
		protected function drawLines(step:Number):void {
			for(var i = step; i < actualWidth; i += step) {
				_pane.graphics.moveTo(i - BORDER_WIDTH, BORDER_WIDTH);
				_pane.graphics.lineTo(i - BORDER_WIDTH, actualHeight - BORDER_WIDTH);
			}
			for(i = step; i < actualHeight; i += step) {
				_pane.graphics.moveTo(BORDER_WIDTH, i - BORDER_WIDTH);
				_pane.graphics.lineTo(actualWidth - BORDER_WIDTH, i - BORDER_WIDTH);
			}
		}
		
		protected function pane_onMouseDown(e:MouseEvent):void {
			if(!_currentDrawingTool.isDrawing) {
				_currentDrawingTool.onStartDrawing(e);
			}
		}
		
		public function getVertexInSamePosition(pos:Point, except:Array = null):Vertex {
			var gridPos = getNearestGridPointGlobal(pos);
			var items = getObjectsUnderPoint(gridPos);
			for each(var obj:DisplayObject in items) {
				var vert = obj as Vertex;
				if(vert != null && (except == null || except.indexOf(vert) < 0)) {
					return vert;
				}
			}
			return null;
		}
		
		public function getNearestGridPoint(currentPoint:Point):Point  {
			if(!snapToGrid) {
				return currentPoint;
			}
			var newPoint = globalToLocal(currentPoint);
			newPoint.x = getNearestGridPos(newPoint.x);
			newPoint.y = getNearestGridPos(newPoint.y);
			return newPoint;
		}
		
		public function getNearestGridPointGlobal(currentPoint:Point):Point  {
			return localToGlobal(getNearestGridPoint(currentPoint));
		}
		
		protected function getNearestGridPos(currentPos:Number):Number {
			if(Math.abs(currentPos) <= HALF_STEP_SIZE) {
				return 0;
			}
			if(Math.abs(currentPos) <= STEP_SIZE) {
				return STEP_SIZE;
			}
			var a = Math.floor(currentPos / STEP_SIZE);
			if(a == 0) {
				return currentPos;
			}
			var newPos = a * STEP_SIZE;
			if(currentPos % STEP_SIZE >= HALF_STEP_SIZE) {
				newPos += STEP_SIZE;
			}
			return newPos;
		}
		
		public function redrawChildren():void {
			for(var i = 0; i < _pane.numChildren; i++) {
				var obj = _pane.getChildAt(i);
				if(obj is DrawingObjectBase) {
					obj.draw();
				}
			}
		}
		
		protected function toolBox_onDrawingToolSelected(e:ToolBoxEvent):void {
			currentDrawingToolType = e.selectedObj as String;
		}
		
		protected function toolBox_onWallTextureSelected(e:ToolBoxEvent):void {
			// TODO: Implement
		}
		
		protected function toolBox_onFurnitureItemSelected(e:ToolBoxEvent):void {
			_furnitureDrawingTool.item = e.selectedObj as Furniture;
			_furnitureDrawingTool.onStartDrawing(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		protected function toolBox_onFloorTextureSelected(e:ToolBoxEvent):void {
			currentFloorTexture = e.selectedObj as FloorTexture;
			if(currentDrawingToolType == DrawingToolFactory.MOVE_DRAWING_TOOL) {
				// TODO:
			}
		}
		
		/**
		 * Makes all child controls selectable and movable.
		 */
		public function enableChildrenInteractivity():void {
			setChildrenInteractivity(true);
		}
		
		/**
		 * Removes intaractivity of child controls (selecting, moving).
		 */
		public function disableChildrenInteractivity():void {
			setChildrenInteractivity(false);
		}
		
		protected function setChildrenInteractivity(areInteractive:Boolean):void {
			var drawingObects = getAllDrawingObjects();
			for each(var drawingObj in drawingObects) {
				setChildInteractivity(drawingObj, areInteractive);
			}
		}
		
		/**
		 * Makes single child control selectable and movable.
		 */
		public function enableChildInteractivity(child:DrawingObjectBase):void {
			setChildInteractivity(child, true);
		}
		
		/**
		 * Removes intaractivity of single child control (selecting, moving).
		 */
		public function disableChildInteractivity(child:DrawingObjectBase):void {
			setChildInteractivity(child, false);
		}
		
		protected function setChildInteractivity(child:DrawingObjectBase, isInteractive:Boolean):void {
			if(isInteractive) child.enableInteracvivity();
			else child.disableInteracvivity();
		}
			
		/** 
		 * Adds child object from passed array to canvas layout positionning child inside canvas and assigning
		 * event handlers on child's 'locationChange' event to keep on eye on childs movements. 
		 *
		 * @param children			Array of <code>DrawingObjectBase</code> which will be added to canvas layout.
		 *
		 * @return child object
		 */		
		public function addDrawingObjectRange(children:Array):Array {
			for each(var child in children) {
				addDrawingObject(child);
			}
			return children;
		}
		
		/** 
		 * Adds child object to canvas layout positionning child inside canvas and assigning event handlers
		 * on child's 'locationChange' event to keep on eye on childs movements.
		 *
		 * @param child				<code>DrawingObjectBase</code> which will be added to canvas layout.
		 *
		 * @return child object
		 */
		public function addDrawingObject(child:DrawingObjectBase):DrawingObjectBase {
			correctChildPosition(child);
			child.addEventListener(DrawingObjectBase.LOCATION_CHANGE, child_onLocationChange)
			_pane.addChild(child);
			return child;
		}
		
		protected function child_onLocationChange(e:Event):void {
			var child = e.target as DrawingObjectBase;
			correctChildPosition(child);
		}
		
		protected function correctChildPosition(child:DrawingObjectBase):Point {
			if(child.parent != null) {
				var upperLeftPoint:Point = child.getUpperLeftPoint();
				var globalPoint = child.parent.localToGlobal(child.position.add(upperLeftPoint));
				var localPoint = getNearestGridPoint(globalPoint).subtract(upperLeftPoint);
				child.x = localPoint.x;
				child.y = localPoint.y;
				return localPoint;
			}
			return new Point(child.x, child.y);
		}
		
		/** 
		 * Removes child object from canvas and removes event handlers for child's 'locationChange' event.
		 *
		 * @param child				<code>DrawingObjectBase</code> which will be added to from canvas layout and disposed.
		 */
		public function removeDrawingObject(child:DrawingObjectBase):void {
			child.removeEventListener(DrawingObjectBase.LOCATION_CHANGE, child_onLocationChange);
			_pane.removeChild(child);
		}
		
		/**
		 * Transfers swapChildren call to real display object container.
		 */
		public function swapDrawingChildren(obj1:DisplayObject, obj2:DisplayObject):void {
			_pane.swapChildren(obj1, obj2);
		}
		
		/**
		 * IDisplosable Implementation
		 */
		public function dispose():void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			_pane.removeEventListener(MouseEvent.MOUSE_DOWN, pane_onMouseDown);
			_verticalScrollBar.removeEventListener(Event.CHANGE, onVerticalScrollUpdated);
			_horizontalScrollBar.removeEventListener(Event.CHANGE, onHorizontalScrollUpdated);
			_toolBox.removeEventListener(ToolBoxEvent.FURNITURE_SELECT, toolBox_onFurnitureItemSelected);
			_toolBox.removeEventListener(ToolBoxEvent.FLOOR_TEXTURE_SELECT, toolBox_onFloorTextureSelected);
			_toolBox.removeEventListener(ToolBoxEvent.WALL_TEXTURE_SELECT, toolBox_onWallTextureSelected);
			_toolBox.removeEventListener(ToolBoxEvent.DAWING_TOOL_SELECT, toolBox_onDrawingToolSelected);
			if(stage != null) stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
		}
	}
}