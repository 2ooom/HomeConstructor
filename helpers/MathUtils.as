package helpers
{
	import flash.geom.Point;
	
	public class MathUtils
	{
		public static function toDegrees(radians:Number):Number {
			return radians * 180 / Math.PI
		}
		
		public static function toRad(degrees:Number):Number {
			return degrees / 180 * Math.PI
		}
		
		public static function getPerpendicularPoint(pointA:Point, pointB:Point, h:Number, isLeft:Boolean):Point {
			var newX = isLeft? pointB.y - pointA.y : pointA.y - pointB.y;
			var newY = isLeft? pointA.x - pointB.x : pointB.x - pointA.x;
			var newPoint = new Point(newX, newY);
			newPoint.normalize(h);
			return newPoint.add(pointA);
		}
	}
}