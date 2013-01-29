package
{
	import flash.geom.Point;

	public class Const
	{
		/**舞台宽*/
		public static const WIDTH:uint = 1000;
		/**舞台高*/
		public static const HEIGHT:uint = 680;
		/**舞台半宽*/
		public static const HALF_WIDTH:uint = 500;
		/**舞台半高*/
		public static const HALF_HEIGHT:uint = 340;
		/**资源地址*/
		public static const RES_URL:String = "Resource.swf";
		/**配置地址*/
		public static const CONFIG_URL:String = "config.xml";
		/**房间1描述*/
		public static const DISCRIPTION_ROOM1:String = "1万以上进入";
		/**房间2描述*/
		public static const DISCRIPTION_ROOM2:String = "100万以上进入";
		/**快速回复*/
		public static const FAST_REPLY0:String = "快点吧，我等到花儿都谢了！";
		public static const FAST_REPLY1:String = "真倒霉，我的牌真差，又要输了！";
		public static const FAST_REPLY2:String = "各位兄弟姐妹高抬贵手，可怜可怜我吧！";
		public static const FAST_REPLY3:String = "不要走，决战到黎明！";
		public static const FAST_REPLY4:String = "哈哈哈，你们的钱马上就要到我的口袋里啦~~";
		/**游戏豆不足*/
		public static const MONEY_NOT_ENOUGH:String = "对不起，您的游戏豆不足，请兑换或充值。";
		/**游戏中头像坐标位置*/
		public static const USER_COORD:Array = [new Point(38, 48),
												new Point(38, 228),
												new Point(38, 402),
												new Point(290, 538),
					 							new Point(568, 402),
												new Point(568, 228),
												new Point(568, 48),
												new Point(290, 48)];
		/**游戏中玩家第一个牌的位置*/
		public static const CARDS_COORD:Array = [new Point(86, 120),
			new Point(86, 300),
			new Point(86, 474),
			new Point(250, 414),
			new Point(616, 474),
			new Point(616, 300),
			new Point(616, 120),
			new Point(338, 120)];
		/**游戏中下注后注币在中央区的显示位置*/
		public static const RATIO_COORD:Array = [new Point(222, 220),
												 new Point(222, 290),
								                 new Point(222, 360),
												 new Point(346, 360),
												 new Point(470, 360),
											     new Point(470, 290),
			                                     new Point(470, 220),
			                                     new Point(346, 220)];
	}
}