package canvas2d.primitives
{
	import helpers.MathUtils;
	
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;

	public class InteractiveDrawingObject extends DrawingObjectBase
	{
		protected static const ROTATION_SPEED = 1;
		protected static const MOVE_SPEED = 1;
		protected static const OUTLINE_COLOR = 0x00D8FF;
		protected static const OUTLINE_WIDTH = 1;
		protected static const RESIZE_BOX_NUMBER = 8;
		protected static const BOX_INNER_COLOR = 0x000000;
		protected static const BOX_INNER_SIZE = 6;
		protected static const BOX_INNER_SIZE_HALF = BOX_INNER_SIZE / 2;
		protected static const BOX_OUTER_COLOR = 0xFFFFFF;
		protected static const BOX_OUTER_SIZE = 8;
		protected static const BOX_OUTER_SIZE_HALF = BOX_OUTER_SIZE / 2;
		
		protected var _content:DisplayObject;
		
		protected var _helperBoxes:Array = new Array(RESIZE_BOX_NUMBER);
		
		protected var _topResizer:Sprite;
		protected var _rightResizer:Sprite;
		protected var _bottomResizer:Sprite;
		protected var _leftResizer:Sprite;
		
		protected var _topLeftRotator:RotationArrows;
		protected var _topRightRotator:RotationArrows;
		protected var _bottomRightRotator:RotationArrows;
		protected var _bottomLeftRotator:RotationArrows;
		
		protected var _isRotating:Boolean = false;
		protected var _isResizing:Boolean = false;
		protected var _isRotationAllowed:Boolean = false;
		protected var _isResizingAllowed:Boolean = false;
		
		/**
		 * Overrides base setter to hang on intractivity events
		 */
		override public function set isSelected(value:Boolean):void {
			if(value != _isSelected) {
				_isSelected = value;
				isRotationAllowed = value;
				if(value) {
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
				} else {
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardListener);
				}
				draw();
			}
		}
		
		/**
		 * Overrides base setter to hang on intractivity events
		 */
		override public function set isActive(value:Boolean):void {
			if(value != _isActive) {
				_isActive = value;
				draw();
				isResizingAllowed = value;
			}
		}
		
		/**
		 * Gets/sets whether object is being rotated.
		 */
		public function get isRotating():Boolean { return _isRotating; }
		public function set isRotating(value:Boolean):void {
			if(_isRotating != value) {
				_isRotating = value;
				draw();
			}
		}
		
		/**
		 * Gets/sets whether object is being resized.
		 */
		public function get isResizing():Boolean { return _isResizing; }
		public function set isResizing(value:Boolean):void {
			if(_isResizing != value) {
				_isResizing = value;
				draw();
			}
		}
		
		/**
		 * Gets/sets whether object can be rotated.
		 */
		public function get isRotationAllowed():Boolean { return _isRotationAllowed; }
		public function set isRotationAllowed(value:Boolean):void {
			if(value != _isRotationAllowed) {
				_isRotationAllowed = value;
				if(_isRotationAllowed) addRotationEventListeners();
				else removeRotationEventListeners();
			}
		}
		
		protected function addRotationEventListeners():void {
			for(var i = 0; i < _helperBoxes.length / 2; i ++) {
				_helperBoxes[i].addEventListener(MouseEvent.MOUSE_DOWN, rotator_onMouseDown);
			}
		}
		
		protected function removeRotationEventListeners():void {
			for(var i = 0; i < _helperBoxes.length / 2; i ++) {
				_helperBoxes[i].removeEventListener(MouseEvent.MOUSE_DOWN, rotator_onMouseDown);
			}
		}
		
		/**
		 * Gets/sets whether object can be resized.
		 */
		public function get isResizingAllowed():Boolean { return _isResizingAllowed; }
		public function set isResizingAllowed(value:Boolean):void {
			if(value != _isResizingAllowed) {
				_isResizingAllowed = value;
				if(_isResizingAllowed) addResizingEventListeners();
				else removeResizingEventListeners();
			}
		}
		
		protected function addResizingEventListeners():void {
			for(var i = _helperBoxes.length / 2; i < _helperBoxes.length; i ++) {
				_helperBoxes[i].addEventListener(MouseEvent.MOUSE_DOWN, resize_onMouseDown);
			}
		}
		
		protected function removeResizingEventListeners():void {
			for(var i = _helperBoxes.length / 2; i < _helperBoxes.length; i ++) {
				_helperBoxes[i].removeEventListener(MouseEvent.MOUSE_DOWN, resize_onMouseDown);
			}
		}
		
		/**
		 * Constructor. Creates new <code>InteractiveDrawingObject</code>
		 *
		 * @param content	<code>DisplayObject</code> which will be added to object's layout.
		 */
		public function InteractiveDrawingObject(content:DisplayObject) {
			_content = content;
			addChild(_content);
			initializeHelperBoxes();
			super();
		}
		
		protected function initializeHelperBoxes():void {
			for(var i = 0; i < _helperBoxes.length / 2; i ++) {
				_helperBoxes[i] = addRotationArrow(90 * i);
				_helperBoxes[i + _helperBoxes.length / 2] = addResizeBox();
			}
		}
		
		override public function draw():void {
			var drawOutline = isSelected || isActive || isMoving || isResizing || isRotating;
			hideHelperBoxes();
			graphics.clear();
			if(drawOutline) {
				// drawing outline
				graphics.lineStyle(OUTLINE_WIDTH, OUTLINE_COLOR);
				graphics.drawRect(_content.x, _content.y, _content.width, _content.height);
				// position resize boxes
				// upper-left
				_topLeftRotator = _helperBoxes[0];
				_topLeftRotator.x = _content.x;
				_topLeftRotator.y = _content.y;
				//upper-right
				_topRightRotator = _helperBoxes[1];
				_topRightRotator.x = _content.x + _content.width;
				_topRightRotator.y = _content.y;
				//lower-right
				_bottomRightRotator = _helperBoxes[2];
				_bottomRightRotator.x = _content.x + _content.width;
				_bottomRightRotator.y = _content.y + _content.height;
				//lower-left
				_bottomLeftRotator = _helperBoxes[3];
				_bottomLeftRotator.x = _content.x;
				_bottomLeftRotator.y = _content.y + _content.height;
				//upper-middle
				_topResizer = _helperBoxes[4];
				_topResizer.x = _content.x + _content.width / 2;
				_topResizer.y = _content.y;
				//middle-right
				_rightResizer = _helperBoxes[5];
				_rightResizer.x = _content.x + _content.width;
				_rightResizer.y = _content.y + _content.height / 2;
				//lower-middle
				_bottomResizer = _helperBoxes[6];
				_bottomResizer.x = _content.x + _content.width / 2;
				_bottomResizer.y = _content.y + _content.height;
				//middle-left
				_leftResizer = _helperBoxes[7];
				_leftResizer.x = _content.x;
				_leftResizer.y = _content.y + _content.height / 2;
				
				showHelperBoxes();
			}
		}
		
		protected function hideHelperBoxes():void {
			for(var i = 0; i < _helperBoxes.length; i++) {
				_helperBoxes[i].visible = false;
			}
		}
		
		protected function showHelperBoxes():void {
			for(var i = 0; i < _helperBoxes.length; i++) {
				_helperBoxes[i].visible = true;
			}
		}
		
		protected function addResizeBox():Sprite {
			var resizeBox:Sprite = new Sprite();
			resizeBox.graphics.beginFill(BOX_OUTER_COLOR);
			resizeBox.graphics.drawRect(-BOX_OUTER_SIZE_HALF, -BOX_OUTER_SIZE_HALF, BOX_OUTER_SIZE, BOX_OUTER_SIZE);
			resizeBox.graphics.endFill();
			resizeBox.graphics.beginFill(BOX_INNER_COLOR);
			resizeBox.graphics.drawRect(-BOX_INNER_SIZE_HALF, -BOX_INNER_SIZE_HALF, BOX_INNER_SIZE, BOX_INNER_SIZE);
			resizeBox.graphics.endFill();
			addChild(resizeBox);
			return resizeBox;
		}
		
		protected function addRotationArrow(angle:Number):RotationArrows {
			var rotationArrow:RotationArrows = new RotationArrows();
			rotationArrow.rotationZ = angle;
			addChild(rotationArrow);
			return rotationArrow;
		}
		
		protected function rotator_onMouseDown(e:MouseEvent):void {
			isMovingAllowed = false;
			if(e.target == _topRightRotator || e.target == _bottomRightRotator) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, rotationRight_onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, rotationRight_onMouseUp);
			}
			else {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, rotationLeft_onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, rotationLeft_onMouseUp);
			}
		}
		
		protected function keyboardListener(e:KeyboardEvent):void {
			if(!visible) return;
			switch(e.keyCode) {
				case Keyboard.LEFT:
					if(e.shiftKey) rotationZ -= ROTATION_SPEED;
					else x -= MOVE_SPEED;
					break;
				case Keyboard.RIGHT:
					if(e.shiftKey) rotationZ += ROTATION_SPEED;
					else x += MOVE_SPEED;
					break;
				case Keyboard.UP:
					y -= MOVE_SPEED;
					break;
				case Keyboard.DOWN:
					y += MOVE_SPEED;
					break;
			}
		}
		
		protected function rotationRight_onMouseMove(e:MouseEvent):void {
			var dx = stage.mouseX - x;
			var dy = stage.mouseY - y;
			var angle = MathUtils.toDegrees(Math.atan(dy/dx));
			if (dx < 0) angle += 180;
			if (dx >= 0 && dy < 0) angle += 360;
			rotationZ = angle;
		}
		
		protected function rotationLeft_onMouseMove(e:MouseEvent):void {
			var dx = stage.mouseX - x;
			var dy = stage.mouseY - y;
			var angle = MathUtils.toDegrees(Math.atan(dy/dx));
			if (dx < 0) angle += 180;
			if (dx >= 0 && dy < 0) angle += 360;
			rotationZ = -angle;
		}
		
		protected function rotationRight_onMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, rotationRight_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, rotationRight_onMouseUp);
			isMovingAllowed = true;
			isSelected = true;
		}
		
		protected function rotationLeft_onMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, rotationLeft_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, rotationLeft_onMouseUp);
			isMovingAllowed = true;
			isSelected = true;
		}
		
		protected function resize_onMouseDown(e:MouseEvent):void {
			isMovingAllowed = false;
			if(e.target == _topResizer || e.target == _bottomResizer) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, resizeVertical_onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, resizeVertical_onMouseUp);
			}
			else {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, resizeHorizontal_onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, resizeHorizontal_onMouseUp);
			}
		}
		
		protected function resizeVertical_onMouseMove(e:MouseEvent):void {
			var p:Point = globalToLocal(new Point(stage.mouseX, stage.mouseY));
			var dy = Math.abs(p.y) - _content.height / 2;
			resizeVertical(dy);
			if(e.shiftKey) resizeHorizontal(dy);
			draw();
		}
		
		protected function resizeVertical(dy:Number):void {
			var newH = _content.height + dy;
			var newY = _content.y - dy / 2;
			_content.y = newY;
			_content.height = newH;
		}
		
		protected function resizeHorizontal_onMouseMove(e:MouseEvent):void {
			var p:Point = globalToLocal(new Point(stage.mouseX, stage.mouseY));
			var dx = Math.abs(p.x) - _content.width / 2;
			resizeHorizontal(dx);
			if(e.shiftKey) resizeVertical(dx);
			draw();
		}
		
		protected function resizeHorizontal(dx:Number):void {
			var newW = _content.width + dx;
			var newX = _content.x - dx / 2;
			_content.x = newX;
			_content.width = newW;			
		}
		
		protected function resizeVertical_onMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizeVertical_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, resizeVertical_onMouseUp);
			isMovingAllowed = true;
			isSelected = true;
		}
		
		protected function resizeHorizontal_onMouseUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, resizeHorizontal_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, resizeHorizontal_onMouseUp);
			isMovingAllowed = true;
			isSelected = true;
		}
		
		/**
		 * IDisposable implementation.
		 */
		override public function dispose():void {
			super.dispose();
		}
	}
}