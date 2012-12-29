package model
{
	public class GameState
	{
		/**玩家下注阶段*/
		public static const USER_BET:uint = 0;
		/**为玩家展示玩家下注数额，动画形式*/
		public static const SHOW_PLAYERS_BETCOIN:uint = 1;
		/**发牌动画阶段*/
		public static const SEND_CARDS:uint = 2;
		/**等待亮牌*/
		public static const WAIT_SHOWCARDS:uint = 3;
		/**开始叫庄*/
		public static const START_JIAOZ:uint = 4;
		/**最后统一亮牌*/
		public static const FINAL_SHOWCARDS:uint = 5;
		/**伴随着最后统计结果面板的出现，进去准备下一轮的倒计时*/
		public static const GET_READY_FOR_NEXT:uint = 6;
	}
}