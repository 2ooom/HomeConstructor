package gui.controls
{
	import core.IDisposable;
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	public class ControlContainer extends BaseControl implements IDisposable
	{
		protected static const VERTICAL_SPACING = 5;
		protected static const HORIZONTAL_SPACING = 5;
		protected static const SCROLLBAR_WIDTH = 10;
		
		public var _container = new Sprite();
		protected var _vertScrollbar:VerticalScrollBar;
		protected var _useVertScrollBar = false;
		protected var _bottomStub:Sprite = new Sprite();	// used to stretch container bottom and top margins
		public function get useVertScrollBar():Boolean { return _useVertScrollBar; }
		public function set useVertScrollBar(value:Boolean):void {
			if(value != _useVertScrollBar) {
				if(value) {
					addVertScrollBar();
				}
				else removeVertScrollBar();
				_useVertScrollBar = value;
			}
		}
		
		protected var _marginTop:Number = 0;
		public function get marginTop():Number { return _marginTop; }
		public function set marginTop(value:Number):void { _marginTop = value; }
		
		/**
		 * Constructor. Creates new instance of <code>ControlContainer</code>
		 * 
		 * @param	w	Width in pixels of current control.
		 * @param	h	Height in pixels of current control.
		 */
		public function ControlContainer(w:Number = 0, h:Number = 0) {
			super(w, h);
			super.addChild(_container);
			drawStub();
		}
		
		protected function addVertScrollBar():void {
			_vertScrollbar = new VerticalScrollBar(SCROLLBAR_WIDTH, _height);
			_vertScrollbar.addEventListener(Event.CHANGE, onVertScrollUpdated);
			_vertScrollbar.x = _width - SCROLLBAR_WIDTH;
			super.addChild(_vertScrollbar);
		}
		
		protected function removeVertScrollBar():void {
			if(_vertScrollbar != null) {
				_vertScrollbar.dispose();
				_vertScrollbar.removeEventListener(Event.CHANGE, onVertScrollUpdated);
				super.removeChild(_vertScrollbar);
				_vertScrollbar = null;
			}
		}
		
		public function addChildren(...children):void {
			var addedNum = addChildrenRange(children);
			if(addedNum > 0) rearrangeChildControls();
		}
		
		protected function addChildrenRange(children:Array):Number {
			var addedNum = 0;
			for each(var child in children) {
				if(child is DisplayObject) {
					addedNum++;
					_container.addChild(child);
					child.addEventListener(Event.RESIZE, onChildResized);
				}
				else if (child is Array) {
					addedNum += addChildrenRange(child as Array);
				}
			}
			return addedNum;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			_container.addChild(child);
			child.addEventListener(Event.RESIZE, onChildResized);
			rearrangeChildControls();
			return child; 
		}
		
		public function addChildBase(child:DisplayObject):DisplayObject {
			return super.addChild(child);
		}
		
		public function removeChildBase(child:DisplayObject):DisplayObject {
			return super.removeChild(child);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject {
			_container.removeChild(child);
			child.removeEventListener(Event.RESIZE, onChildResized);
			rearrangeChildControls();
			return child;
		}
		
		protected function rearrangeChildControls():void {
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onEnterFrame(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			rearrangeChildControlsWorker();
		}
		
		protected function rearrangeChildControlsWorker():void {
			var availableWidth = _width - BORDER_WIDTH * 2 - (useVertScrollBar? SCROLLBAR_WIDTH * 2 : 0);
			var currentRowWidth = 0;
			var rowsWidth = new Array();
			var rowsHeight = new Array();
			var rows = new Array();
			var currentRow = new Array();
			var currentRowHeight = 0;
			var sumRowsHeight = 0;
			removeBottomStub();
			for(var i = 0; i < _container.numChildren; i++) {
				var obj = _container.getChildAt(i);
				var w = obj.width + (currentRow.length == 0? 0 : HORIZONTAL_SPACING);
				if(obj.height > currentRowHeight) {
					currentRowHeight = obj.height;
				}
				var wasAdded = false;
				if(currentRowWidth + w <= availableWidth) {
					currentRow.push(obj);
					currentRowWidth += w;
					wasAdded = true;
				}
				if (currentRowWidth + w > availableWidth || i == _container.numChildren - 1) {
					sumRowsHeight += currentRowHeight + (rows.length == 0? 0 : VERTICAL_SPACING);
					rows.push(currentRow);
					rowsWidth.push(currentRowWidth);
					rowsHeight.push(currentRowHeight);
					currentRow = new Array();
					currentRowWidth = 0;
					currentRowHeight = 0;
				}
				if(!wasAdded) {
					currentRow.push(obj);
					currentRowWidth += w;
				}
			}
			var startY = Math.max((_height - sumRowsHeight) / 2, marginTop);//Math.max((_height - sumRowsHeight) / 2, VERTICAL_SPACING);
			for(i = 0; i < rows.length; i++) {
				currentRow = rows[i];
				currentRowWidth = i == rows.length - 1? rowsWidth[0] : rowsWidth[i];	// to aligt last row to the left
				currentRowHeight = rowsHeight[i];
				var startX = (_width - currentRowWidth) / 2;
				for(var c = 0; c < currentRow.length; c++) {
					obj = currentRow[c];
					obj.x = startX;
					obj.y = startY;
					startX += obj.width + HORIZONTAL_SPACING;
				}
				startY += currentRowHeight + VERTICAL_SPACING;
			}
			if(useVertScrollBar) {
				if(startY > _height) fixBottomStub(startY);
				_vertScrollbar.maximum = _container.height;
				setContainerScrollRect();
			}
		}
		
		protected function removeBottomStub():void {
			if(_container == _bottomStub.parent) _container.removeChild(_bottomStub);
		}
		
		protected function fixBottomStub(yPos:Number):void {
			addBottomStub();
			repositionBottomStub(yPos);
		}
		
		protected function addBottomStub():void {
			if(_container != _bottomStub.parent) _container.addChild(_bottomStub);
		}
		
		protected function repositionBottomStub(yPos:Number):void {
			_bottomStub.x = 0;
			_bottomStub.y = yPos;
		}
		
		protected function drawStub():void {
			_bottomStub.graphics.clear();
			_bottomStub.graphics.drawRect(0, 0, _width, 1);
		}
		
		protected function setContainerScrollRect():void {
			_container.scrollRect = new Rectangle(0, 0, _width + BORDER_WIDTH, _height + BORDER_WIDTH);
		}
		
		protected function onChildResized(e:Event):void {
			rearrangeChildControls();
		}
		
		protected function onVertScrollUpdated(e:Event):void {
			var sender = e.target;
			var scrollable = sender.maximum - _container.scrollRect.height;
			var sr = _container.scrollRect.clone();
			
			sr.y = scrollable * sender.percent;
			
			_container.scrollRect = sr;
			draw();
		}
		
		/**
		 * IDisplosable Implementation
		 */
		public function dispose():void {
			clearContent();
			detachObject(_container);
			detachObject(this);
			_container = null;
		}
		
		protected function clearContent():void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if(useVertScrollBar && _vertScrollbar != null) {
				removeVertScrollBar();
			}
			for(var i = 0; i < _container.numChildren; i++ ) {
				var obj = getChildAt(i);
				obj.removeEventListener(Event.RESIZE, onChildResized);
				var disp = obj as IDisposable;
				if(disp != null) {
					disp.dispose();
				}
				detachObject(obj);
			}
		}
	}
}