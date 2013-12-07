package canvas2d.drawingTools
{
	import canvas2d.Canvas2D;
	
	public class DrawingToolFactory
	{
		private static const DRAWING_TOOL_NOT_SUPPORTED = "Specified drawing tool is not supported";
		
		public static const WALL_DRAWING_TOOL = "WallDrawingTool";
		public static const FLOOR_DRAWING_TOOL = "FloorDrawingTool";
		public static const RECTANGLE_DRAWING_TOOL = "RectangleDrawingTool";
		public static const MOVE_DRAWING_TOOL = "MoveDrawingTool";
		
		protected var _canvas:Canvas2D;
		protected var _wallDrawingTool:WallDrawingTool;
		protected var _rectangleDrawingTool:RectangleDrawingTool;
		protected var _moveDrawingTool:MoveDrawingTool;
		protected var _floorDrawingTool:FloorDrawingTool;
		
		/**
		 * Constructor. Creates new instanse of <code>DrawingToolFactory</code> object.
		 *
		 * @param	canvas	Canvas on which drawing tools will operate.
		 */
		public function DrawingToolFactory(canvas:Canvas2D) {
			_canvas = canvas;
			_wallDrawingTool = new WallDrawingTool(_canvas);
			_rectangleDrawingTool = new RectangleDrawingTool(_canvas);
			_moveDrawingTool = new MoveDrawingTool(_canvas);
			_floorDrawingTool = new FloorDrawingTool(_canvas);
		}
		
		public function getDrawingTool(drawingToolType:String):IDrawingTool {
			switch(drawingToolType) {
				case WALL_DRAWING_TOOL: return _wallDrawingTool;
				case RECTANGLE_DRAWING_TOOL: return _rectangleDrawingTool;
				case MOVE_DRAWING_TOOL: return _moveDrawingTool;
				case FLOOR_DRAWING_TOOL: return _floorDrawingTool;
				default: throw new Error(DRAWING_TOOL_NOT_SUPPORTED);
			}
		}
	}
}