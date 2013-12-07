package canvas3d
{
	import core.IDisposable;
	import canvas2d.Canvas2D;
	import canvas2d.primitives.Wall;
	import canvas2d.primitives.FurnitureDrawingObject;

	import away3d.containers.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.primitives.*;
	import away3d.materials.*;
	import away3d.lights.*;
	
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;

	public class Canvas3D extends Sprite implements IDisposable
	{
		protected static const BG_COLOR = 0xFFFFFF;
		protected static const BORDER_COLOR = 0x000000;
		protected static const BORDER_WIDTH = 1;
		protected static const OUTLINE_COLOR = 0x000000;
		protected static const OUTLINE_THIKNESS = 2;
		protected static const LIGHT_COLOR = 0xFFFFFF;
		protected static const LIGHT_SPECULAR = 1;
		protected static const LIGHT_DIFFUSE = 0.5;
		protected static const LIGHT_AMBIENT = 0.5;
		protected static const CAMERA_Y_POS = 1000;
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var view:View3D = new View3D();
		protected var _figures:Array = new Array();
		
		protected var _actualWidth:Number;
		public function get actualWidth():Number { return _actualWidth; }
		public function set actualWidth(value:Number):void { _actualWidth = value; }
		
		protected var _actualHeight:Number;
		public function get actualHeight():Number { return _actualHeight; }
		public function set actualHeight(value:Number):void { _actualHeight = value; }
		
		protected function getViewCenter():Vector3D { return new Vector3D( _actualHeight / 2, 0, _actualWidth / 2); }
		/*
		public function Canvas3D(w:Number, h:Number, xPos:Number, yPos:Number, actWidth:Number, actHeight:Number) {
			super(w, h);
			view = new View3D({x:250,y:100});
			x = xPos;
			y = yPos;
			addChild(view);
			
			// The same, using verbose syntax
			var colorMaterial:PhongColorMaterial = new PhongColorMaterial(0xFFA500);
			var sphere:Sphere = new Sphere();
			sphere.material = colorMaterial;
			view.scene.addChild(sphere);
			 
			// We'll need some light sources to see anything
			var light:DirectionalLight3D = new DirectionalLight3D();
            // Move the light away from the default 0,0,0 position so we'll see some reflection
            light.direction = new Vector3D(500,-300,200);
			view.scene.addLight(light);

			// Render the view
			view.render();
			addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		}*/
		
		public function Canvas3D(w:Number, h:Number, xPos:Number, yPos:Number, actWidth:Number, actHeight:Number) {
			_width = w;
			_height = h;
			_actualWidth = actWidth;
			_actualHeight = actHeight;
			var center:Vector3D = getViewCenter();
			var halfWidth = _width / 2;
			var halfHeight = _height / 2;
			view = new View3D({x: halfWidth, y: halfHeight});
			addChild(view);
			
			// Setup light
			var light:DirectionalLight3D = new DirectionalLight3D();
			light.color = LIGHT_COLOR;
			light.specular = LIGHT_SPECULAR;
			light.diffuse = LIGHT_DIFFUSE;
			light.ambient = LIGHT_AMBIENT;
			light.direction = new Vector3D(500,-300,200);
			view.scene.addLight(light);
			
			// Setup clipping
			view.clipping = new RectangleClipping({minX: - halfWidth + BORDER_WIDTH, minY: - halfHeight + BORDER_WIDTH, maxX: halfWidth - BORDER_WIDTH / 2, maxY: halfHeight - BORDER_WIDTH / 2});
			view.camera.moveTo(center.x, CAMERA_Y_POS, center.z);
			view.camera.lookAt(center);
			
			// Add the trident for reference
			var axis:Trident = new Trident(100,true);
			view.scene.addChild(axis);
			
			x = xPos;
			y = yPos;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
			
			draw();	
		}

		protected function onAddedToStage(e:Event):void {
			view.render();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyBoardListener);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel_handler);
			
		}
		
		protected function onRemovedFromStage(e:Event):void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyBoardListener);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel_handler);
			removeEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		}
		
		protected function stage_onEnterFrame(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
			view.render();
		}
		
		protected function keyBoardListener(e:KeyboardEvent):void {
			if(!visible) return;
			if(e.keyCode == Keyboard.LEFT)
				view.camera.moveLeft(4);
			if(e.keyCode == Keyboard.RIGHT)
				view.camera.moveRight(4);
			if(e.keyCode == Keyboard.UP)
				view.camera.moveUp(15);
			if(e.keyCode == Keyboard.DOWN)
				view.camera.moveDown(15);
			if(!e.shiftKey) {
				view.camera.lookAt(getViewCenter());
			}
			view.render();
		}
		
		protected function onMouseWheel_handler(e:MouseEvent):void {
			if(e.delta > 0) {
				view.camera.moveForward(e.delta * 20);
			}
			else view.camera.moveBackward(-e.delta * 20);
			if(!e.shiftKey) {
				view.camera.lookAt(getViewCenter());
			}
			view.render();
		}
		
		protected function drawBorder():void {
			graphics.clear();
			graphics.beginFill(BG_COLOR);
			graphics.lineStyle(BORDER_WIDTH, BORDER_COLOR);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
		}
		
		protected function clearScene():void {
			for(var i = 0; i < _figures.length; i++) {
				view.scene.removeChild(_figures[i]);
			}
			_figures = new Array();
		}
		
		public function repopulate(container:DisplayObjectContainer):void {
			clearScene();
			for(var i = 0; i < container.numChildren; i++) {
				var currenObj = container.getChildAt(i);
				if(currenObj is Wall) {
					populateWall(currenObj as Wall);
				}
				else if(currenObj is FurnitureDrawingObject) {
					populateFurniture(currenObj as FurnitureDrawingObject);
				}
			}
			view.render();
		}
		
		protected function populateWall(seg:Wall):void {
			var ind = seg.parent.getChildIndex(seg);
			var fVlocalPos:Point = seg.firstVertex.position;
			var sVlocalPos:Point = seg.secondVertex.position;
			var dist = Point.distance(sVlocalPos, fVlocalPos);
			var dw = seg.wallWidth / 2;
			var wall = new Cube({
				x : fVlocalPos.y,
				y : 0,
				z : fVlocalPos.x - dw,
				width : seg.wallWidth,
				height : seg.wallHeight,
				depth : dist + dw
			});
			wall.material = new ShadingColorMaterial(0xffffff);
			wall.pivotPoint = new Vector3D(0, -seg.wallHeight / 2, -dist / 2);
			wall.lookAt(new Vector3D(sVlocalPos.y, 0, sVlocalPos.x));
			_figures.push(wall);
			view.scene.addChild(wall);
		}
		
		protected function populateFurniture(furnitureItem:FurnitureDrawingObject):void {
			/* var canv = furnitureItem.parent as Canvas2D;
			var ind = furnitureItem.parent.getChildIndex(seg);
			var localPos = new Point(furnitureItem.x, furnitureItem.y);
			var wall = new Cube({
				material :"yellow#",
				name :"wall_" + ind,
				x : furnitureItem.y,
				y : 0,
				z : furnitureItem.x,
				width : furnitureItem.item.objectWidth,
				height : furnitureItem.item.objectHeight,
				depth : dist + dw
			});
			wall.pivotPoint = new Vector3D(0, -canv.wallHeight / 2, -dist / 2);
			wall.lookAt(new Vector3D(sVlocalPos.y, 0, sVlocalPos.x));
			view.scene.addChild(wall); */
		}
		
		public function draw():void {
			drawBorder();
			view.render();
		}
		
		/* IDisposable implementation */
		public function dispose():void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
	}
}