package ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
	public class AnimeButton extends SimpleButton
	{
		private var bmp1:Bitmap;
		private var bmp2:Bitmap;
		private var bmp3:Bitmap;
		public function AnimeButton(bmpd1:BitmapData, bmpd2:BitmapData, bmpd3:BitmapData, x:int = 0, y:int = 0):void
		{
			bmp1 = new Bitmap(bmpd1);
			bmp2 = new Bitmap(bmpd2);
			bmp3 = new Bitmap(bmpd3);
			super(bmp1, bmp2, bmp3, bmp3);
			
			this.x = x;
			this.y = y;
		}
		
		public function dispose():void{
			bmp1.bitmapData.dispose();
			bmp2.bitmapData.dispose();
			bmp3.bitmapData.dispose();
			bmp1.bitmapData = null;
			bmp2.bitmapData = null;
			bmp3.bitmapData = null;
			bmp1 = null;
			bmp2 = null;
			bmp3 = null;
		}
	}
}