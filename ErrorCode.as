package
{
	public class ErrorCode
	{
		/**找不到用户*/
		public static const NO_USER:String = "er001";
		/**用户已登录*/
		public static const USER_LOGINED:String = "er002";
		/**账号被禁用*/
		public static const USER_LOCKED:String = "er003";	
		/**用户未登录*/
		public static const USER_ON_LOGIN:String = "er004";
		/**游戏房间不存在*/
		public static const ROOM_CANNT_FIND:String = "er005";
		/**游戏房间满人*/	
		public static const ROOM_FULL:String = "er006";	
		/**金币不足无法进入桌子*/	
		public static const TABLE_COIN_SHORTAGE:String = "er007";	
		/**金币过多无法进入游戏房间*/	
		public static const ROOM_COIN_FULL:String = "er008";
		/**玩家加入牌桌出错*/	
		public static const TABLE_JOIN_ERROR:String = "er009";
		/**金币不足无法进行下次游戏*/
		public static const NEXT_TURN_COIN_SHORTAGE:String = "er010";
	}
}