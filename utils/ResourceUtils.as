package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.system.ApplicationDomain;

	public class ResourceUtils
	{
		private static var tempCls:Class;
		private static var tempBitmapData:BitmapData;
		private static var tempBitmap:Bitmap;

		public static function getBitmapData(resName:String):BitmapData
		{
			tempCls = getCls(resName);
			tempBitmapData = new tempCls(0, 0) as BitmapData;
			return tempBitmapData;
		}

		public static function getBitmap(resName:String):Bitmap
		{
			tempBitmap = new Bitmap(getBitmapData(resName));
			return tempBitmap;
		}

		public static function getMovieClip(resName:String):MovieClip
		{
			tempCls = getCls(resName);
			return new tempCls() as MovieClip;
		}
		
		public static function getSprite(resName:String):Sprite
		{
			tempCls = getCls(resName);
			return new tempCls() as Sprite;
		}

		public static function getSound(resName:String):Sound
		{
			tempCls = getCls(resName);
			return new tempCls() as Sound;
		}
		
		public static function getButton(resName:String):SimpleButton{
			tempCls = getCls(resName);
			return new tempCls() as SimpleButton;
		}

		public static function getCls(resName:String):Class
		{
			return ApplicationDomain.currentDomain.getDefinition(resName) as Class;
		}
	}
}


