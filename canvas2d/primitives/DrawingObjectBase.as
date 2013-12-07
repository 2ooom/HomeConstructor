package canvas2d.primitives
{
	import core.IDisposable;
	import core.IClonable;
	
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.geom.Point;

	[Event(name="locationChange", type="flash.events.Event")]
	public class DrawingObjectBase extends Sprite implements IDisposable, IClonable
	{
		public static const LOCATION_CHANGE = "locationChange";
		
		protected var _dx:Number;
		protected var _dy:Number;
		
		protected var _isSelected:Boolean = false;
		protected var _isDrawing:Boolean = false;
		protected var _isActive:Boolean = false;
		protected var _isMoving:Boolean = false;
		protected var _isDropped:Boolean = false;
		protected var _isMovingAllowed:Boolean = false;
		protected var _isActivationAllowed:Boolean = false;
		protected var _isSelectionAllowed:Boolean = false;
		
		protected var _mustSelect:Boolean = false;
		
		/**
		 * Gets/sets whether object is been drawing. While object is drawn it's 'alpha' property is changed.
		 */
		public function get isDrawing():Boolean { return _isDrawing; }
		public function set isDrawing(value:Boolean):void {
			if(value != _isDrawing) {
				_isDrawing = value;
				onDrawingChanged();
			}
		}
		
		protected function onDrawingChanged():void {
			draw();
		}
		
		/**
		 * Gets/sets whether object is moving.
		 */
		public function get isMoving():Boolean { return _isMoving; }
		public function set isMoving(value:Boolean):void {
			if(value != _isMoving) {
				_isMoving = value;
				draw();
			}
		}
		
		/**
		 * Gets/sets whether object is can be moved.
		 */
		public function get isMovingAllowed():Boolean { return _isMovingAllowed; }
		public function set isMovingAllowed(value:Boolean):void {
			if(value != _isMovingAllowed) {
				_isMovingAllowed = value;
				if(_isMovingAllowed) addMovingEventListeners();
				else removeMovingEventListeners();
			}
		}
		
		/**
		 * Gets/sets whether object can be selected.
		 */
		public function get isActivationAllowed():Boolean { return _isActivationAllowed; }
		public function set isActivationAllowed(value:Boolean):void {
			if(value != _isActivationAllowed) {
				_isActivationAllowed = value;
				if(_isActivationAllowed) addActivationEventListeners();
				else removeActivationEventListeners();
			}
		}
		
		/**
		 * Gets/sets whether object can be selected.
		 */
		public function get isSelectionAllowed():Boolean { return _isSelectionAllowed; }
		public function set isSelectionAllowed(value:Boolean):void {
			if(value != _isSelectionAllowed) {
				_isSelectionAllowed = value;
				if(_isSelectionAllowed) addSelectionEventListeners();
				else removeSelectionEventListeners();
			}
		}
		
		/**
		 * Gets/sets whether object is moving. In this case 'alpha' property is changed.
		 */
		public function get isDropped():Boolean { return _isDropped; }
		public function set isDropped(value:Boolean):void {
			if(value != _isDropped) {
				_isDropped = value;
				onDroppedChanged();
			}
		}
		
		protected function onDroppedChanged():void {}
		
		/**
		 * Gets/sets whether object is selected (to select object click on it).
		 */
		public function get isSelected():Boolean { return _isSelected; }
		public function set isSelected(value:Boolean):void {
			if(value != _isSelected) {
				_isSelected = value;
				draw();
			}
		}
		
		/**
		 * Gets/sets whether object is active (global focus is set on this object).
		 */
		public function get isActive():Boolean { return _isActive; }
		public function set isActive(value:Boolean):void {
			if(value != _isActive) {
				_isActive = value;
				draw();
			}
		}
		
		/**
		 * Makes object interactive. It can be seleted via mouse click, moved and responses on mouse hovering.
		 */
		public function enableInteracvivity():void {
			setInteractivity(true);
		}
		
		/**
		 * Disables object's interactivinty.
		 */
		public function disableInteracvivity():void {
			setInteractivity(false);
		}
		
		protected function setInteractivity(isInteractive:Boolean):void {
			isMovingAllowed = isInteractive;
			isActivationAllowed = isInteractive;
			isSelectionAllowed = isInteractive;
			if(!isInteractive) {
				isActive = false;
				isSelected = false;
				isDrawing = false;
				stopMoving();
			}
		}
		
		protected function addMovingEventListeners():void {
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected function removeMovingEventListeners():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			if(stage && isMoving) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
			}
		}
		
		protected function addActivationEventListeners():void {
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		protected function removeActivationEventListeners():void {
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		protected function addSelectionEventListeners():void {
			addEventListener(MouseEvent.MOUSE_DOWN, selectionBegin_onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, selectionFinish_onMouseUp);
			addEventListener(MouseEvent.MOUSE_MOVE, selection_onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, canvas_onMouseDown);
		}
		
		protected function removeSelectionEventListeners():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, selectionBegin_onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, selectionFinish_onMouseUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, selection_onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, canvas_onMouseDown);
		}
		
		public function get position():Point {
			return new Point(x, y);
		}
		
		public function set position(point:Point):void {
			x = point.x;
			y = point.y;
			fireLocationChangeEvent();
		}
		
		/**
		 * Constructor. Creates new <code>DrawingObjectBase</code>
		 */
		public function DrawingObjectBase() {
			tabEnabled = true;
			buttonMode = true;
			useHandCursor = true;
			draw();
		}
		
		protected function onMouseOver(e:MouseEvent):void {
			isActive = true;
		}
		
		protected function onMouseOut(e:MouseEvent):void {
			isActive = false;
		}
		
		protected function onMouseDown(e:MouseEvent):void {
			startMoving();
		}
				
		protected function stage_onMouseMove(e:MouseEvent):void {
			var localPoint = parent.globalToLocal(new Point(stage.mouseX, stage.mouseY));
			x = localPoint.x - _dx;
			y = localPoint.y - _dy;
			fireLocationChangeEvent();
		}
		
		protected function stage_onMouseUp(e:MouseEvent):void {
			stopMoving();
		}
		
		public function startMoving():void {
			isMoving = true;
			isDropped = false;
			if(stage) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
			}
			var localPoint = globalToLocal(new Point(stage.mouseX, stage.mouseY));
			_dx = localPoint.x;
			_dy = localPoint.y;
		}
		
		public function stopMoving():void {
			_dx = _dy = 0;
			if(stage) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, stage_onMouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_onMouseMove);
			}
			isDropped = true;
			isMoving = false;
		}
		
		public function draw():void {}
		
		public function fireLocationChangeEvent() {
			dispatchEvent(new Event(DrawingObjectBase.LOCATION_CHANGE));
		}
		
		protected function selectionBegin_onMouseDown(e:MouseEvent):void {
			_mustSelect = true;
		}
		
		protected function selectionFinish_onMouseUp(e:MouseEvent):void {
			if(_mustSelect) isSelected = true;
		}
		
		protected function selection_onMouseMove(e:MouseEvent):void {
			_mustSelect = false;
		}
		
		protected function canvas_onMouseDown(e:MouseEvent):void {
			if(!e.ctrlKey) isSelected = false;
		}
		
		public function getUpperLeftPoint():Point {
			return new Point();
		}
		
		/**
		 * Creates a full copy of current object.
		 */
		public function clone():Object {
			var objType:Class = Object(this).constructor;
			var newObj = new objType() as DrawingObjectBase;
			newObj._dx = _dx;
			newObj._dy = _dy;
			newObj.isSelected = isSelected;
			newObj.isDrawing = isDrawing;
			newObj.isActive = isActive;
			if(isMoving) newObj.startMoving();
			newObj.isDropper = isDropped;
			newObj.isMovingAllowed = true;
			newObj.isActivationAllowed = true;
			newObj.isSelectionAllowed = true;
			newObj.x = x;
			newObj.y = y;
			newObj._mustSelect = _mustSelect;
			
			return newObj;
		}
		
		/**
		 * IDisposable implementation
		 */
		 public function dispose():void {
			disableInteracvivity();
		}
	}
}