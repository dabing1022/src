package
{
	/**
	 * 通信命令
	 */
	public class Command
	{
		/**心跳*/
		public static const HEARTBEAT:String = "1001";
		/**按webService提供的sign值登录*/
		public static const LOGIN_BY_SIGN:String = "1002";
		/**用户登录*/
		public static const NOMAL_LOGIN:String="1003";
		/**联接服务器*/
		public static const CONNECT:String="1004";
		/**断线重连*/
		public static const RECONNECT:String = "1005";
		/**欢迎界面选择房间*/
		public static const CHOOSE_ROOM:String="1006";
		/**选择板凳*/
		public static const CHOOSE_CHAIR:String = "1007";
		/**大厅选择房间*/
		public static const HALL_CHOOSE_ROOM:String = "1008";
		/**在大厅里面的玩家收到的命令，包括有人加入桌子和离开桌子*/
		public static const UPDATE_CHAIR:String = "1009";
		/**游戏中,加入玩家, 为其他已在牌桌玩家发送更新房间座椅*/
		public static const GAMING_ADD_PLAYER:String = "1010";
		/**玩家离开牌桌,为其他已在牌桌玩家发送更新房间座椅*/
		public static const PLAYER_LEAVE_TABLE:String = "1011";
		/**玩家从游戏中返回大厅*/
		public static const  BACK_TO_HALL:String = "1012";
		/**玩家准备OK*/
		public static const  PLAYER_GAME_READY:String = "1013";
		/**下注*/
		public static const  PLAYER_GAME_BET:String = "1014";
		/**聊天*/
		public static const  NOMAL_CHAT:String = "1015";
		/**开始叫庄*/
		public static const START_JIAO_Z:String = "1016";
		/**符合条件的玩家叫庄*/
		public static const PLAYER_JIAO_Z:String = "1017";
		/**系统选择叫庄玩家*/
		public static const SYSTEM_CHOOSE_Z:String = "1018";
		/**更新桌子内部玩家信息*/
		public static const UPDATE_TABLE_PLAYER:String = "1019";
		/**为牌桌内玩家通知，闲家的下注数额*/
		public static const SHOW_PLAYER_BETCOIN:String = "1020";
		/**发牌*/
		public static const SEND_CARDS:String = "1021";
		/**等待亮牌*/
		public static const WAIT_SHOWCARDS:String = "1022";
		/**开始亮牌*/
		public static const START_SHOWCARDS:String = "1023";
		/**游戏结束*/
		public static const GAME_OVER:String = "1024";
		/**快捷回复*/
		public static const FAST_REPLY:String = "1025";
		/**托管*/
		public static const TUO_GUAN:String = "1026";
		/**关闭浏览器*/
		public static const CLOSE:String = "1027";

		
		
		/**错误*/
		public static const ERROR:String = "9999";
		/**命令长度*/
		public static const COMMANDLENGTH:int = 4;
	}
}


