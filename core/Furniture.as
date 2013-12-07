package core
{
	import helpers.ContentLoader;
	
	import away3d.core.base.Object3D;
	import away3d.events.Loader3DEvent;
	
	import flash.display.Bitmap;
	
	public class Furniture extends TextureBase
	{
		/**
		 * Get/sets path to obj-file containig item's 3D object.
		 */
		protected var _objectPath:String;
		public function get objectPath():String { return _objectPath; }
		public function set objectPath(value:String):void { _objectPath = value; }
		
		/**
		 * Get/sets item's 3D object width.
		 */
		protected var _objectWidth:Number;
		public function get objectWidth():Number { return _objectWidth; }
		public function set objectWidth(value:Number):void { _objectWidth = value; }
		
		/**
		 * Get/sets item's 3D object height.
		 */
		protected var _objectHeight:Number;
		public function get objectHeight():Number { return _objectHeight; }
		public function set objectHeight(value:Number):void { _objectHeight = value; }
		
		/**
		 * Get/sets item's 3D object depth.
		 */
		protected var _objectDepth:Number;
		public function get objectDepth():Number { return _objectDepth; }
		public function set objectDepth(value:Number):void { _objectDepth = value; }
		
		public var _object:Object3D;
		public function get object():Object3D { return _object; }
		
		override protected function get isFullyLoaded():Boolean { return super.isFullyLoaded /*&& _object != null*/; }
		
		/**
		 * Constructor. Creates new instanse of <code>Furniture</code> object.
		 *
		 * @param	node	XML node from 'config.xml' in correct format.
		 */
		public function Furniture(node:XML = null) {
			super(node);
			if(node != null) {
				objectPath = node.object;
				objectWidth = node.object.@width;
				objectHeight = node.object.@height;
				objectDepth = node.object.@depth;
			}
		}
		
		override public function clone():Object {
			var newItem = new Furniture();
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
			newItem.objectPath = objectPath;
			newItem.objectWidth = objectWidth;
			newItem.objectHeight = objectHeight;
			newItem.objectDepth = objectDepth;
			//newItem._object = _object.clone();
			return newItem;
		}
		
 		override public function load():void {
			_icon = null;
			_image = null;
			_object = null;
			//ContentLoader.load3dObject(objectPath, onObjectLoaded);
			super.load();
		}
		
		protected function onObjectLoaded(e:Loader3DEvent):void {
			_object = e.loader.handle;
			if(isFullyLoaded) fireCompleteEvent();
		}
	}
}