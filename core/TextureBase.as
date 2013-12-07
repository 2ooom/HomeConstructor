package core
{
	import helpers.ContentLoader;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class TextureBase extends Thumbnail
	{
		/**
		 * Get/sets path to full size texture image.
		 */
		protected var _imagePath:String;
		public function get imagePath():String { return _imagePath; }
		public function set imagePath(value:String):void { _imagePath = value; }
		
		/**
		 * Get/sets texture image width.
		 */
		protected var _imageWidth:Number;
		public function get imageWidth():Number { return _imageWidth <= 0 && _image != null? _image.width : _imageWidth; }
		public function set imageWidth(value:Number):void { _imageWidth = value; }
		
		/**
		 * Get/sets texture image height.
		 */
		protected var _imageHeight:Number;
		public function get imageHeight():Number { return _imageHeight <= 0 && _image != null? _image.height : _imageHeight; }
		public function set imageHeight(value:Number):void { _imageHeight = value; }
		
		/**
		 * Read-only. Returns <code>Bitmap</code> with image.
		 */
		protected var _image:Bitmap;
		public function get image():Bitmap { return _image; }
		
		override protected function get isFullyLoaded():Boolean { return _icon != null && _image != null; }
		
		/**
		 * Constructor. Creates new instanse of <code>TextureBase</code> image.
		 *
		 * @param	node	XML node from 'config.xml' in correct format.
		 */
		public function TextureBase(node:XML = null) {
			super(node);
			if(node != null) {
				imagePath = node.image;
				imageWidth = node.image.@width;
				imageHeight = node.image.@height;
			}
		}
		
		override public function clone():Object {
			var newItem = new TextureBase();
			newItem.name = name;
			newItem.iconPath = iconPath;
			newItem.iconWidth = iconWidth;
			newItem.iconHeight = iconHeight;
			newItem._icon = _icon;
			setBitmapSize(newItem._icon, newItem._iconWidth, newItem._iconHeight);
			newItem.imagePath = imagePath;
			newItem.imageWidth = imageWidth;
			newItem.imageHeight = imageHeight;
			newItem._image = new Bitmap(_image.bitmapData);
			setBitmapSize(newItem._image, newItem._imageWidth, newItem._imageHeight);
			return newItem;
		}
		
		override public function load():void {
			_icon = null;
			_image = null;
			ContentLoader.loadBitmap(imagePath, onImageLoaded);
			super.load();
		}
		
		protected function onImageLoaded(e:Event):void {
			_image = e.target.content;
			setBitmapSize(_image, _imageWidth, _imageHeight);
			if(isFullyLoaded) fireCompleteEvent();
		}
	}
}