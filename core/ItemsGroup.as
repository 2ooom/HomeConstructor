package core
{
	import helpers.ContentLoader;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class ItemsGroup extends LoadableObject
	{
		protected static const NOT_IMPLEMENTED_ERROR = "Not implemented for this class.";
		/**
		 * Get/sets item's name.
		 */
		protected var _name:String;
		public function get name():String { return _name; }
		public function set name(value:String):void { _name = value; }
		
		/**
		 * Get/sets colletion of items.
		 */
		protected var _items = new Array();
		public function get items():Array { return _items; }
		public function set items(value:Array):void { _items = value; }
		
		protected var _loadedItems:Number;
		
		/**
		 * Constructor. Creates new instanse of <code>ItemsGroup</code> object.
		 *
		 * @param	node	XML node from 'config.xml' in correct format.
		 */
		public function ItemsGroup(node:XML) {
			name = node.@name;
			for each(var itemNode in node.*) {
				var obj = initializeSingleItem(itemNode);
				items.push(obj);
			}
		}
		
		protected function initializeSingleItem(itemNode:XML):Object {
			throw new Error(NOT_IMPLEMENTED_ERROR);
		}
		
		override public function load():void {
			_loadedItems = 0;
			var loader = new ContentLoader(onItemsLoaded);
			loader.loadArraySequentially(_items);
		}
		
		protected function onItemsLoaded(loaded:Number):void {
			_loadedItems = loaded;
			fireCompleteEvent();
		}
	}
}