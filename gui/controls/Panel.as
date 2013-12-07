package gui.controls
{
	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.None; 
	
	public class Panel extends ControlContainer
	{
		public static const HEADING_HEIGHT = 21;
		
		protected static const BG_COLOR = 0xE8EEF3;
		protected static const ARROW_POINTER_X_POS = 12;
		protected static const ARROW_POINTER_Y_POS = 9;
		protected static const TWEEN_MOTION_DURATION = 6;
		protected static const TWEEN_ROTATION_DURATION = 6;
		protected static const TWEEN_FADE_DURATION = 6;
		
		protected var _isMinimized = false;
		
		protected var _panelHeading = new Sprite();
		protected var _panelHeadingTxt = new TextField();
		protected var _panelHeadingArrow = new ArrowPointer();
		
		/**
		 * Assign new text to clickable header
		 */
		public function set title(value:String):void {
			_panelHeadingTxt.text = value;
			repositionTitle();
		}
		
		/**
		 * Gets text displayed in header
		 */
		public function get title():String {
			return _panelHeadingTxt.text;
		}
		
		/**
		 * Constructor. Creates new instance of <code>Panel</code>
		 * 
		 * @param	title	Panel title displayed in clickable header.
		 * @param	w		Width in pixels of current control.
		 * @param	h		Height in pixels of current control.
		 * @param	content	Array of child controls.
		 */
		public function Panel(title:String, w:Number = 0, h:Number = 0, ...content) {
			super(w, h);
			addChildren(content);
			useVertScrollBar = true;
			initialiseHeader();
			this.title = title;
			_container.y = HEADING_HEIGHT + BORDER_WIDTH;
			_vertScrollbar.y = HEADING_HEIGHT;
			addChildBase(_panelHeading);
			draw();
		}
		
		protected function initialiseHeader():void {
			_panelHeadingArrow.x = ARROW_POINTER_X_POS;
			_panelHeadingArrow.y = ARROW_POINTER_Y_POS;
			_panelHeadingTxt.defaultTextFormat = _defaultTextFormat;
			_panelHeadingTxt.embedFonts = BaseControl.EMBEDED_FONTS;
			_panelHeadingTxt.selectable = false;
			_panelHeadingTxt.autoSize = TextFieldAutoSize.LEFT;
			_panelHeadingTxt.antiAliasType = AntiAliasType.ADVANCED;
			_panelHeading.addChild(_panelHeadingTxt);
			_panelHeading.addChild(_panelHeadingArrow);
			_panelHeading.buttonMode = true;
			_panelHeading.useHandCursor = true;
			_panelHeading.addEventListener(MouseEvent.CLICK, onHeaderClick);
		}
		
		protected function onHeaderClick(e:MouseEvent):void {
			toggleMinimized();
		}
		
		protected function toggleMinimized() {
			if(_isMinimized) {
				animateMaximize();
			}
			else animateMinimize();
			_isMinimized = !_isMinimized;
		}
		
		protected function animateMinimize():void {
			if(_vertScrollbar != null) _vertScrollbar.height = 0;
			var twArrow = new Tween(_panelHeadingArrow, "rotationZ", None.easeInOut, 0, -90, TWEEN_ROTATION_DURATION);
			var fadeTween = fadeOutChildren();
			if(fadeTween != null) {
				fadeTween.addEventListener(TweenEvent.MOTION_FINISH, onTweenFadeOutFinished);
			}
			else {
				var twPanel = new Tween(_container, "height", None.easeInOut, _height, 0, TWEEN_MOTION_DURATION);
				twPanel.addEventListener(TweenEvent.MOTION_CHANGE, onTweenMotionProgress); 
			}
		}
		
		protected function onTweenFadeOutFinished(e:TweenEvent):void {
			var twPanel = new Tween(_container, "height", None.easeInOut, _height, 0, TWEEN_MOTION_DURATION);
			twPanel.addEventListener(TweenEvent.MOTION_CHANGE, onTweenMotionProgress); 
		}
		
		protected function animateMaximize():void {
			var twArrow = new Tween(_panelHeadingArrow, "rotationZ", None.easeInOut, -90, 0, TWEEN_ROTATION_DURATION);
			var twPanel = new Tween(_container, "height", None.easeInOut, 0, _height, TWEEN_MOTION_DURATION);
			if(_vertScrollbar != null) {
				var twScroll = new Tween(_vertScrollbar, "height", None.easeInOut, 0, _height, TWEEN_MOTION_DURATION);
			}
			twPanel.addEventListener(TweenEvent.MOTION_CHANGE, onTweenMotionProgress); 
			twPanel.addEventListener(TweenEvent.MOTION_CHANGE, onTweenMotionFinished);
		}
		
		protected function onTweenMotionProgress(e:TweenEvent):void {
			fireResizeEvent();
		}
		
		protected function onTweenMotionFinished(e:TweenEvent):void {
			fadeInChildren();
		}
		
		override public function draw():void {
			drawHeader();
			_container.graphics.clear();
			_container.graphics.lineStyle();
			_container.graphics.beginFill(BG_COLOR);
			if(_container.scrollRect == null) {
				_container.graphics.drawRect(0, 0, _width, _height);
			}
			else {
				var sr = _container.scrollRect.clone();
				_container.graphics.drawRect(sr.x, sr.y, _width, _height);
			}
			_container.graphics.endFill();
		}
		
		protected function drawHeader():void {
			_bgGradientMatrix.createGradientBox(_width, HEADING_HEIGHT, -90 * TO_RAD);
			_panelHeading.graphics.clear();
			_panelHeading.graphics.lineStyle(BORDER_WIDTH, BORDER_COLOR);
			_panelHeading.graphics.beginGradientFill(GradientType.LINEAR, GRADIENT_BG_COLORS, GRADIENT_BG_ALPHAS, GRADIENT_BG_RATIOS, _bgGradientMatrix);
			_panelHeading.graphics.drawRect(0, 0, _width, HEADING_HEIGHT);
			_panelHeading.graphics.endFill();
			repositionTitle();
		}
		
		protected function repositionTitle():void {
			_panelHeadingTxt.x = (_width - _panelHeadingTxt.textWidth) / 2;
		}
		
		protected function fadeInChildren():Tween {
			return changeChildrenAlpha(0, 1);
		}
		
		protected function fadeOutChildren():Tween {
			return changeChildrenAlpha(1, 0);
		}
		
		protected function changeChildrenAlpha(fromAlpha:Number, toAlpha:Number):Tween {
			var tw:Tween;
			for(var i = 0; i < _container.numChildren; i++ ) {
				var obj = _container.getChildAt(i);
				tw = new Tween(obj, "alpha", None.easeInOut, fromAlpha, toAlpha, TWEEN_FADE_DURATION);
			}
			return tw;
		}
		
		/**
		 * IDisplosable Implementation
		 */
		override public function dispose():void {
			_panelHeading.removeEventListener(MouseEvent.CLICK, onHeaderClick);
			super.dispose();
		}
	}
}