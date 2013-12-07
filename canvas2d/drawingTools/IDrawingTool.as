package canvas2d.drawingTools
{
	import flash.events.Event;
	
	public interface IDrawingTool
	{
		function get isDrawing():Boolean;
		
		function onStartDrawing(e:Event):void;
		
		function stopDrawing():void;
	}
}