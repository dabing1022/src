package model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class CardData 
	{
		/**颜色*/
		public static var COLOR_GUI:int = 5;
		public static var COLOR_HEI:int = 4;
		public static var COLOR_HONG:int = 3;
		public static var COLOR_MEI:int = 2;
		public static var COLOR_FANG:int = 1;
		/**分值*/
		public static const VA:int = 1;
		public static const V2:int = 2;
		public static const V3:int = 3;
		public static const V4:int = 4;
		public static const V5:int = 5;
		public static const V6:int = 6;
		public static const V7:int = 7;
		public static const V8:int = 8;
		public static const V9:int = 9;
		public static const V10:int = 10;
		public static const VJ:int = 11;
		public static const VQ:int = 12;
		public static const VK:int = 13;
		public static const VG1:int = 14;//小鬼
		public static const VG2:int = 15;//大鬼
		
		public var color:int;
		public var value:int;
		public function CardData(color:int, value:int):void
		{
			this.color = color;
			this.value = value;
		}
		
		public function get key():String{
			return color + "_" + value;
		}
		
		public function clone():CardData{
			return new CardData(color, value);
		}
	}
}