package helpers
{
	public class SizeUtility
	{
		private static var _wallSizeSm = 15;
		
		public static function get wallSizeSm() : Number {
			return _wallSizeSm;
		}
		
		public static function set wallSizeSm(value:Number) : void {
			_wallSizeSm = value;
		}
		
		public static function get wallSizePx():Number {
			return getPixels(wallSizeSm);
		}
		
		public static const PIXELS_IN_SM = 2/3; // average wall width is 15sm which is 10px line width in editor
		public static const SM_IN_M = 100;
		
		public static function getPixels(centimeters:Number):Number {
			return centimeters * PIXELS_IN_SM;
		}
		
		public static function getCentimeters(pixels:Number):Number {
			return pixels / PIXELS_IN_SM;
		}
		
		public static function getMitersStr(pixels:Number):String {
			return (getCentimeters(pixels) / SM_IN_M).toFixed(2) + " m";
		}
	}
}