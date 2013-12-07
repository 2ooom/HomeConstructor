package gui.controls
{
	import flash.display.Sprite;
	
	public class SubPanel extends Panel
	{
		protected static const SUB_HEADING_HEIGHT = 21;
		protected static const SUB_ARROW_POINTER_X_POS = 20;
		protected static const SUB_HEADEIHG_TITLE_X_POS = 28;
		
		/**
		 * Constructor. Creates new instance of <code>SubPanel</code>
		 * 
		 * @param	title	Panel title displayed in clickable header.
		 * @param	w		Width in pixels of current control.
		 * @param	h		Height in pixels of current control.
		 * @param	content	Array of child controls.
		 */
		public function SubPanel(title:String, w:Number = 0, h:Number = 0, ...content) {
			super(title, w, h, content);
		}
		
		/**
		 * Overriding <code>Panel</code> methods
		 */
		override protected function initialiseHeader():void {
			super.initialiseHeader();
			_panelHeadingArrow.x = SUB_ARROW_POINTER_X_POS;
			_panelHeadingTxt.x = SUB_HEADEIHG_TITLE_X_POS;
		}
		
		override protected function drawHeader():void {
			_panelHeading.graphics.clear();
			_panelHeading.graphics.lineStyle();
			_panelHeading.graphics.beginFill(BG_COLOR);
			_panelHeading.graphics.drawRect(0, 0, _width, HEADING_HEIGHT);
			_panelHeading.graphics.endFill();
		}
		
		override protected function repositionTitle():void {}		
	}
}