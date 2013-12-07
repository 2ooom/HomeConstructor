package gui
{
	import gui.controls.*;
	import core.ToolBoxEvent;
	import canvas2d.drawingTools.DrawingToolFactory;
	import canvas2d.drawingTools.FloorDrawingTool;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	[Event(name="furnitureSelect", type="core.ToolBoxEvent")]
	[Event(name="floorTextureSelect", type="core.ToolBoxEvent")]
	[Event(name="wallTextureSelect", type="core.ToolBoxEvent")]
	[Event(name="drawingToolSelect", type="core.ToolBoxEvent")]
	public class ToolBox extends PanelMenu
	{
		
		protected static const DRAWING_BTN_SIZE = 29;
		protected static const DRAWING_PANEL_HEIGHT = 54;
		protected static const DRAWING_PANEL_TITLE = "Drawing Tools";
		protected static const FLOOR_PANEL_HEIGHT = 100;
		protected static const FLOOR_PANEL_TITLE = "Floor";
		protected static const WALL_PANEL_HEIGHT = 100;
		protected static const WALL_PANEL_TITLE = "Walls";
		protected static const FURNITURE_PANEL_TITLE = "Furniture";
		protected static const TEXTURE_BUTTONS_PADDING = 3;
		protected static const TEXTURE_BUTTONS_PADDING_DOUBLE = TEXTURE_BUTTONS_PADDING * 2;
		
		protected var _isInitialized = false;
		
		protected var _drawingPanel:Panel;
		protected var _floorPanel:Panel;
		protected var _wallPanel:Panel;
		protected var _furniturePanel:Panel;
		
		protected var _furnitureMenu:PanelMenu;
		
		protected var _drawingButtonGroup:PushButtonGroup;
		protected var _floorButtonGroup:PushButtonGroup;
		protected var _wallButtonGroup:PushButtonGroup;
		
		protected var _segmentBtn:PushButton;
		public function get segmentBtn():PushButton { return _segmentBtn; };
		protected var _rectangleBtn:PushButton;
		public function get rectangleBtn():PushButton { return _rectangleBtn; };
		protected var _pointerBtn:PushButton;
		public function get pointerBtn():PushButton { return _pointerBtn; };
		protected var _floorBtn:PushButton;
		public function get floorBtn():PushButton { return _floorBtn; };
		
		protected var _segmentBtnPic:SegmentBtnPic;
		protected var _rectangleBtnPic:RectangleBtnPic;
		protected var _pointerBtnPic:PointerBtnPic;
		protected var _floorBtnPic:FloorBtnPic;
		
		protected function get furniturePanelHeight():Number { return _height - (/*WALL_PANEL_HEIGHT + */FLOOR_PANEL_HEIGHT + DRAWING_PANEL_HEIGHT + 3 * (BORDER_WIDTH + Panel.HEADING_HEIGHT)); }
		protected function get furnitureSubPanelHeight():Number { return furniturePanelHeight - 4 * 20; }
		
		/**
		 * Constructor. Creates new instance of <code>ToolBox</code>
		 */
		public function ToolBox(w:Number, h:Number) {
			super(w, h);
			
			// Creating Drawing Panel pictograms instances from the library
			_segmentBtnPic = new SegmentBtnPic();
			_rectangleBtnPic = new RectangleBtnPic();
			_pointerBtnPic = new PointerBtnPic();
			_floorBtnPic = new FloorBtnPic();
			
			// Initialising Drawing Panel buttons
			_segmentBtn = new PushButton(DRAWING_BTN_SIZE, DRAWING_BTN_SIZE, _segmentBtnPic);
			_segmentBtn.associatedObj = DrawingToolFactory.WALL_DRAWING_TOOL;
			_rectangleBtn = new PushButton(DRAWING_BTN_SIZE, DRAWING_BTN_SIZE, _rectangleBtnPic);
			_rectangleBtn.associatedObj = DrawingToolFactory.RECTANGLE_DRAWING_TOOL; 
			_pointerBtn = new PushButton(DRAWING_BTN_SIZE, DRAWING_BTN_SIZE, _pointerBtnPic);
			_pointerBtn.associatedObj = DrawingToolFactory.MOVE_DRAWING_TOOL;
			_floorBtn = new PushButton(DRAWING_BTN_SIZE, DRAWING_BTN_SIZE, _floorBtnPic);
			_floorBtn.associatedObj = DrawingToolFactory.FLOOR_DRAWING_TOOL;
			
			// Creating button group for Drawing Panel
			_drawingButtonGroup = new PushButtonGroup(_rectangleBtn, _segmentBtn, _pointerBtn, _floorBtn);
			for each(var drawingBtn in _drawingButtonGroup.items) {
				drawingBtn.defaultHandler = drawingToolsBtnHandler;
			}
			// Creating button group for Floor Panel
			_floorButtonGroup = new PushButtonGroup();
			
			// Creating button group for Wall Panel
			_wallButtonGroup = new PushButtonGroup();
			
			// Creating predefined Panels
			_drawingPanel = new Panel(DRAWING_PANEL_TITLE, _width, DRAWING_PANEL_HEIGHT, _drawingButtonGroup.items);
			_floorPanel = new Panel(FLOOR_PANEL_TITLE, _width, FLOOR_PANEL_HEIGHT);
			_floorPanel.marginTop = 5;
			_wallPanel = new Panel(WALL_PANEL_TITLE, _width, WALL_PANEL_HEIGHT);
			_wallPanel.marginTop = 5;
			_furniturePanel = new Panel(FURNITURE_PANEL_TITLE, _width, furniturePanelHeight, FURNITURE_PANEL_TITLE);
			_furniturePanel.useVertScrollBar = false;
			_furnitureMenu = new PanelMenu(_width, furniturePanelHeight);
			trace(furniturePanelHeight);
		}
		
		public function populate():void {
			// Populating Floor textures panel
			var floorItems = ConfigManager.floorTextureGroup.items;
			var floorBtns = new Array();
			for each (var floorTexture in floorItems) {
				var floorBtn = new PushButton(floorTexture.iconWidth + TEXTURE_BUTTONS_PADDING_DOUBLE, floorTexture.iconHeight + TEXTURE_BUTTONS_PADDING_DOUBLE, floorTexture.icon);
				floorBtn.associatedObj = floorTexture;
				floorBtn.defaultHandler = floorTextureBtnHandler;
				floorBtns.push(floorBtn);
			}
			_floorPanel.addChildren(floorBtns);
			_floorButtonGroup.addItems(floorBtns);
			
			if(floorItems.length > 0) {
				FloorDrawingTool.texture = floorItems[0];
			}
			else removeChild(_floorBtn);
			
			// Populating Wall textures panel 
			var wallItems = ConfigManager.wallTextureGroup.items;
			var wallBtns = new Array();
			for each (var wallTexture in wallItems) {
				var wallBtn = new PushButton(wallTexture.iconWidth + TEXTURE_BUTTONS_PADDING_DOUBLE, wallTexture.iconHeight + TEXTURE_BUTTONS_PADDING_DOUBLE, wallTexture.icon);
				wallBtn.associatedObj = wallTexture;
				wallBtn.defaultHandler = wallTextureBtnHandler;
				wallBtns.push(wallBtn);
			}
			_wallPanel.addChildren(wallBtns);
			_wallButtonGroup.addItems(wallBtns);
			
			// Populating Furniture panel
			var furnitureGroups = ConfigManager.furnitureGroups;
			var furniturePanels = new Array();
			for each(var furnitureGroup in furnitureGroups) {
				var furnitureItems = furnitureGroup.items;
				var furnitureButtons = new Array();
				for each(var furniturItem in furnitureItems) {
					var furnitureBtn = new SimplePushButton(furniturItem.iconWidth, furniturItem.iconHeight, furniturItem.icon);
					furnitureBtn.associatedObj = furniturItem;
					furnitureBtn.defaultHandler = furnitureBtnHandler;
					furnitureButtons.push(furnitureBtn);
				}
				var furniturePnl = new SubPanel(furnitureGroup.name, _width, furnitureSubPanelHeight, furnitureButtons);
				furniturePanels.push(furniturePnl);
			}
			_furnitureMenu.addChildren(furniturePanels);
			_furniturePanel.addChild(_furnitureMenu);
			
			addChildren(_drawingPanel, _floorPanel,/* _wallPanel, */_furniturePanel);
		}
		
		protected function drawingToolsBtnHandler(e:MouseEvent):void {
			var btn = e.currentTarget as PushButton;
			if(btn != null) fireDrawingToolSelect(btn.associatedObj);
		}
		
		protected function floorTextureBtnHandler(e:MouseEvent):void {
			var btn = e.currentTarget as PushButton;
			if(btn != null) fireFloorTextureSelect(btn.associatedObj);
		}
		
		protected function wallTextureBtnHandler(e:MouseEvent):void {
			var btn = e.currentTarget as PushButton;
			if(btn != null) fireWallTextureSelect(btn.associatedObj);
		}
		
		protected function furnitureBtnHandler(e:MouseEvent):void {
			var btn = e.currentTarget as PushButton;
			if(btn != null) fireFurnitureSelect(btn.associatedObj);
		}
		
		protected function fireFurnitureSelect(selected:Object):void {
			dispatchEvent(new ToolBoxEvent(ToolBoxEvent.FURNITURE_SELECT, selected));
		}
		
		protected function fireWallTextureSelect(selected:Object):void {
			dispatchEvent(new ToolBoxEvent(ToolBoxEvent.WALL_TEXTURE_SELECT, selected));
		}
		
		protected function fireFloorTextureSelect(selected:Object):void {
			dispatchEvent(new ToolBoxEvent(ToolBoxEvent.FLOOR_TEXTURE_SELECT, selected));
		}
		
		protected function fireDrawingToolSelect(selected:Object):void {
			dispatchEvent(new ToolBoxEvent(ToolBoxEvent.DAWING_TOOL_SELECT, selected));
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject {
			var ind = _drawingButtonGroup.items.indexOf(child);
			if(ind > 0) {
				_drawingPanel.removeChild(child);
				_drawingButtonGroup.items.splice(ind, 1);
			}
			else super.removeChild(child);
			return child;
		}
	}
}