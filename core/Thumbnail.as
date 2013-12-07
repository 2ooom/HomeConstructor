package core
{
	import core.LoadableObject;
	import helpers.ContentLoader;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	
	public class Thumbnail extends LoadableObject
	{
		/**
		 * Get/sets item's name.
		 */
		protected var _name:String;
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		
		/**
		 * Get/sets path to item's thumbnail picture.
		 */
		protected var _iconPath:String;
		public function get iconPath():String { return _iconPath; }
		public function set iconPath(value:String):void { _iconPath = value; }
		
		/**
		 * Get/sets item's thumbnail picture width.
		 */
		protected var _iconWidth:Number;
		public function get iconWidth():Number { return _iconWidth <= 0 && _icon != null? _icon.width : _iconWidth; }
		public function set iconWidth(value:Number):void { _iconWidth = value; }
		
		/**
		 * Get/sets item's thumbnail picture height.
		 */
		protected var _iconHeight:Number;
		public function get iconHeight():Number { return _iconHeight <= 0 && _icon != null? _icon.height : _iconHeight;  }
		public function set iconHeight(value:Number):void { _iconHeight = value; }
		
		/**
		 * Read-only. Returns <code>Bitmap</code> with icon.
		 */
		protected var _icon:Bitmap;
		public function get icon():Bitmap { return _icon; }
		
		protected function get isFullyLoaded():Boolean { return _icon != null; }
		
		/**
		 * Constructor. Creates new instanse of <code>Thumbnail</code> object.
		 *
		 * @param	node	XML node from 'config.xml' in correct format.
		 */
		public function Thumbnail(node:XML = null) {
			if(node != null) {
				name = node.@name;
				iconPath = node.icon.text();
				iconWidth = node.icon.@width;
				iconHeight = node.icon.@height;
			}
		}
		
		public function clone():Object {
			var newItem = new Thumbnail();
			newItem.name = name;
			newItem.iconPath = iconPath;
			newItem.iconWidth = iconWidth;
			newItem.iconHeight = iconHeight;
			newItem._icon = _icon;
			setBitmapSize(newItem._icon, newItem._iconWidth, newItem._iconHeight);
			return newItem;
		}
		
		override public function load():void {
			_icon = null;
			ContentLoader.loadBitmap(iconPath, onIconLoaded);
		}
		
		protected function onIconLoaded(e:Event):void {
			_icon = e.target.content;
			if(_iconWidth > 0) {
				_icon.width = _iconWidth;
			}
			if(_iconHeight > 0) {
				_icon.height = _iconHeight;
			}
			if(isFullyLoaded) fireCompleteEvent();
		}
				
		protected static function setBitmapSize(bmp:Bitmap, w:Number, h:Number) : void {
			if(w > 0) bmp.width = w;
			if(h > 0) bmp.height = h;
		}
	}
}