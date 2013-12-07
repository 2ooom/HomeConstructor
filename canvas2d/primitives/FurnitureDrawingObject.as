package canvas2d.primitives
{
	import core.Furniture;
	import core.IDisposable;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.filters.DropShadowFilter;
	
	public class FurnitureDrawingObject extends InteractiveDrawingObject
	{		
		protected static const IMAGE_ALPHA_FADED = 0.4;
		protected static const IMAGE_ALPHA_DEFAULT = 1;
		protected static const _dropShadowFilter:DropShadowFilter = new DropShadowFilter(6, 45, 0x000000, 1, 18, 18, 0.4); //(distance, angle, color, alpha, blurX, blurY, strength)
		
		/**
		 * Read only property for underlying <code>Furniture</code> item
		 */
		protected var _item:Furniture;
		public function get item():Furniture { return _item; }
		
		override protected function onDrawingChanged():void {
			if(_isDrawing) fadeOutImage();
			else fadeInImage();
		}
		
		override protected function onDroppedChanged():void {
			if(_isDropped) dropShadow();
			else removeShadow();
		}
		
		protected function fadeOutImage():void { _item.image.alpha = IMAGE_ALPHA_FADED; }
		protected function fadeInImage():void {	_item.image.alpha = IMAGE_ALPHA_DEFAULT; }
		
		protected function dropShadow():void { _item.image.filters = [_dropShadowFilter]; }
		protected function removeShadow():void { _item.image.filters = null; }
		
		/**
		 * Constructor. Creates new instanse of <code>FurnitureDrawingObject</code> object.
		 *
		 * @param	furnitureItem	<code>Furniture</code> object holding information about displaing furniture item.
		 */
		public function FurnitureDrawingObject(furnitureItem:Furniture) {
			_item = furnitureItem.clone() as Furniture;
			item.image.x = - item.imageWidth / 2;
			item.image.y = - item.imageHeight / 2;
			super(item.image);
		}
		
		override public function getUpperLeftPoint():Point {
			return new Point(-item.image.width / 2, -item.image.height / 2);
		}
	}
}