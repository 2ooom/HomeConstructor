package core
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.EventDispatcher;
	
	/**
	 * Abstract class for objects that cntain data which must be loaded.
	 * Exposes load():void method which initialises asyncronous load of
	 * objects inner content.
	 * After al content inside object is loaded Event.COMPLETE is fired.
	 */
	[Event(name="complete", type="flash.events.Event")]
	public class LoadableObject extends EventDispatcher implements ILoadable
	{
		/**
		 * Initializes loading of inner content. Must be overriden.
		 */
		public function load():void {}
		
		/**
		 * Fires Event.COMPLETE which signalizes that loading process was finished.
		 */
		protected function fireCompleteEvent():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}