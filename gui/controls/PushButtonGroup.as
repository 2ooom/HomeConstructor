package gui.controls
{
	import flash.events.Event;
	
	public class PushButtonGroup
	{
		protected var _items = new Array();
		
		public function get items():Array { return _items; }
		
		protected var _currentButton:PushButton;
		
		public function get currentButton():PushButton { return _currentButton;	}		
		
		public function PushButtonGroup(...pushButtons) {
			addItems(pushButtons);
		}
		
		public function addItems(...pushButtons):void {
			addItemsRange(pushButtons);
		}
		
		public function addItemsRange(pushButtons:Array):void {
			for each(var button in pushButtons) {
				var b = button as PushButton;
				var ms = button as Array;
				if(b != null) {
					_items.push(b);
					b.addEventListener(Event.SELECT, onSelect);
				}
				else if (ms != null) addItemsRange(ms);
			}
		}
		
		protected function onSelect(e:Event):void {
			_currentButton = e.currentTarget as PushButton;
			for(var i = 0; i < _items.length; i++ ) {
				_items[i].isPushed = _items[i] == _currentButton;
			}
		}
	}
}