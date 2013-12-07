package core
{
	import flash.events.Event;
	
	public class ContentLoaderEvent extends Event
	{
		public static const ITEM_LOADED = "itemLoaded";
		public static const ALL_LOADED_SUCCESSFULL = "allLoadedSuccessfull";
		
		protected var _item:Object;
		
		public function get item():Object { return _item; }
		public function set item(obj:Object):void { _item = obj; }
		
		/**
		 * Constructor. Creates new instanse of <code>ContentLoaderEvent</code> object.
		 *
		 * @param	type	Event type. String key.
		 * @param	itm		Attached item.
		 */
		public function ContentLoaderEvent(type:String, itm:Object = null) {
			super(type);
			item = itm;
		}
	}
}