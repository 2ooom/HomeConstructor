package core
{
	import flash.events.Event;
	
	public class ToolBoxEvent extends Event
	{
		public static const FURNITURE_SELECT = "furnitureSelect";
		public static const FLOOR_TEXTURE_SELECT = "floorTextureSelect";
		public static const WALL_TEXTURE_SELECT = "wallTextureSelect";
		public static const DAWING_TOOL_SELECT = "drawingToolSelect";
		
		protected var _selectedObj:Object;
		
		public function get selectedObj():Object { return _selectedObj; }
		public function set selectedObj(obj:Object):void { _selectedObj = obj; }
		
		/**
		 * Constructor. Creates new instanse of <code>ToolBoxEvent</code> object.
		 *
		 * @param	type		Event type. String key.
		 * @param	selected	Object which was selected.
		 */
		public function ToolBoxEvent(type:String, selected:Object) {
			super(type);
			selectedObj = selected;
		}
	}
}