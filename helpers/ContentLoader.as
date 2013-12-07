package helpers
{
	import away3d.loaders.Loader3D;
	import away3d.loaders.Max3DS;
	import away3d.loaders.Obj;
	import away3d.events.Loader3DEvent;
	
	import core.LoadableObject;
	import core.ContentLoaderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	
	[Event(name="itemLoaded", type="core.ContentLoaderEvent")]
	[Event(name="allLoadedSuccessfull", type="core.ContentLoaderEvent")]	
	public class ContentLoader extends EventDispatcher
	{
		protected static const ERROR_LOADING_ARRAY = "Error while loading items array sequentially. Some items in array are not 'LoadableObject's."
		
		public static function loadBitmap(path:String, listener:Function = null):Loader {
			var loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, listener);
			loader.load(new URLRequest(path));
			return loader;
		}
		
		public static function load3dObject(path:String, listener:Function  = null, init:Object = null):Loader3D {
			var fileExt:String = path.substr(Math.max(path.lastIndexOf("."), 0), path.length - 1).toLowerCase();
			switch(fileExt) {
				case '.max':
				case '.3ds':
					return loadMax3dObject(path, listener, init);
					break;
				case '.obj':
				default:
					return loadObj3dObject(path, listener, init);
					break;
			}
		}
		
		public static function loadObj3dObject(path:String, listener:Function  = null, init:Object = null):Loader3D {
			var loader:Loader3D = Obj.load(path, init);
			loader.addOnSuccess(listener);
			loader.addOnError(onError);
			return loader;
		}
		
		public static function loadMax3dObject(path:String, listener:Function  = null, init:Object = null):Loader3D {
			var loader:Loader3D = Max3DS.load(path, init);
			loader.addOnSuccess(listener);
			loader.addOnError(onError);
			return loader;
		}
		
		private static function onError(e:Event):void {
			trace(e);
		}
		
		protected var _items:Array;
		protected var _itemsProcessed:Number = 0;
		protected var _itemsLoaded:Number = 0;
		protected var _itemLoadedCallback:Function;
		protected function set itemLoadedCallback(handler:Function):void { _itemLoadedCallback = handler; };
		protected var _allLoadedCallback:Function;
		protected function set allLoadedCallback(handler:Function):void { _allLoadedCallback = handler; };
		
		/**
		 * Constructor. Creates new instanse of <code>ContentLoader</code> object.
		 *
		 * @param callbackOnSuccess
		 * @param callbackOnItemLoaded
		 */
		public function ContentLoader(callbackOnSuccess:Function = null, callbackOnItemLoaded:Function = null) {
			itemLoadedCallback = callbackOnItemLoaded;
			allLoadedCallback = callbackOnSuccess;
		}
		
		public function loadSequentially(...items):void {
			var loadQueue = new Array();
			copyItems(loadQueue, items);
			loadArraySequentially(loadQueue);
		}
		
		public function loadArraySequentially(items:Array):void {
			_items = items;
			_itemsProcessed = 0;
			_itemsLoaded = 0;
			loadNextArrayItem();
		}
		
		protected static function copyItems(destination:Array, source:Array):Array {
			for each(var src in source) {
				if(src is Array){
					copyItems(destination, src);
				}
				else destination.push(src);
			}
			return destination;
		}
		
		protected function onArrayItemLoaded(e:Event):void {
			var prev = _items[_itemsProcessed] as LoadableObject;
			prev.removeEventListener(Event.COMPLETE, onArrayItemLoaded);
			_itemsLoaded++;
			_itemsProcessed++;
			fireItemLoaded(prev);
			if(_itemLoadedCallback != null) {
				_itemLoadedCallback.call(null, prev);
			}
			loadNextArrayItem();
			
		}
		
		protected function loadNextArrayItem():void {
			if(_itemsProcessed < _items.length) {
				var next:LoadableObject;
				while(next == null && _itemsProcessed < _items.length) {
					next = _items[_itemsProcessed] as LoadableObject;
					if (next == null) {
						throw new Error(ERROR_LOADING_ARRAY);
						_itemsProcessed++;
					}
				}
				next.addEventListener(Event.COMPLETE, onArrayItemLoaded);
				next.load();
			}
			else if (_allLoadedCallback != null) {
				fireAllLoadedSuccessfull();
				_allLoadedCallback.call(null, _itemsLoaded);
			}
		}
		
		protected function fireAllLoadedSuccessfull():void {
			dispatchEvent(new ContentLoaderEvent(ContentLoaderEvent.ALL_LOADED_SUCCESSFULL));
		}
		
		protected function fireItemLoaded(item:Object):void {
			dispatchEvent(new ContentLoaderEvent(ContentLoaderEvent.ITEM_LOADED, item));
		}
	}
}