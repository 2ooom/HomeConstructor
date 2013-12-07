package
{
	import core.*;
	import helpers.ContentLoader;
	
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class ConfigManager extends LoadableObject
	{
		protected static const CONFIG_PATH = "config.xml";
		protected static const ERROR_LOADING_CONFIG_RELATED_OBJECTS = "Error iccured while loading config-related object. Not all items were loaded.";
		
		protected static var _isInitialized:Boolean;
		
		protected static var _configReq = new URLRequest(CONFIG_PATH);
		protected static var _loader = new URLLoader();
		
		protected static var _configXml:XML;
		protected static var _floorTextureGroup:FloorTextureGroup;
		protected static var _wallTextureGroup:WallTextureGroup;
		protected static var _furnitureGroups:Array;
		
		/**
		 * Read-only. Says wheather object was initialized or not. In other words was config.xml
		 * successfully read and parsed.
		 */
		public static function get isInitialized():Boolean { return _isInitialized; }
		
		/**
		 * Read-only. Returns <code>FloorTextureGroup</code> object, containing floor textures.
		 */
		public static function get floorTextureGroup():FloorTextureGroup { return _floorTextureGroup; }
		
		/**
		 * Read-only. Returns <code>WallTextureGroup</code> object, containing walls textures.
		 */
		public static function get wallTextureGroup():WallTextureGroup { return _wallTextureGroup; }
		
		/**
		 * Read-only. Returns collection of <code>FurnitureGroup</code> objects, each of them is
		 * holding collection of furniture items.
		 */
		public static function get furnitureGroups():Array { return _furnitureGroups; }
		
		/**
		 * Constructor. Initializes object, reads data from config.xml.
		 */
		public function ConfigManager() {
			load();
		}
		
		override public function load():void {
			_isInitialized = false;
			_loader.load(_configReq);
			_loader.addEventListener(Event.COMPLETE, onConfigLoaded);
		}
		
		protected function onConfigLoaded(e:Event):void {
			_configXml = new XML(e.target.data);
			
			_floorTextureGroup = new FloorTextureGroup(_configXml.textures.floor[0]);			
			_wallTextureGroup = new WallTextureGroup(_configXml.textures.walls[0]);
			_furnitureGroups = new Array();
			
			for each(var furnitureGroupNode in _configXml.furniture.*) {
				_furnitureGroups.push(new FurnitureGroup(furnitureGroupNode));
			}
			// loading related objects
			var loader = new ContentLoader(onFurnitureGroupsLoaded);
			loader.loadSequentially(_floorTextureGroup, _wallTextureGroup, _furnitureGroups);
		}

		protected function onFurnitureGroupsLoaded(loaded:Number):void {
			if(loaded == _furnitureGroups.length + 2) {
				_isInitialized = true;
				fireCompleteEvent();
			}
			else throw new Error(ERROR_LOADING_CONFIG_RELATED_OBJECTS);
		}
	}
}