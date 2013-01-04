package events
{
	import flash.events.Event;
	
	public class UserEvent extends Event
	{
		public static const MONEY_CHANGE:String = "money_change";
		public static const STATE_CHANGE:String = "state_change";
		public static const BACK_TO_HALL:String = "backToHall";
		public static const BACK_TO_WELCOME:String = "backToWelcome";
		//是否显示倒计时
		public static const COUNT_DOWN_SHOW_CHANGE:String = "countDownShowChange";
		/**用户自己手动输入*/
		public static const NOMAL_CHAT:String = "nomal_chat";
		/**用户使用快速回复输入*/
		public static const FAST_CHAT:String = "fast_chat";
		/**每局结束后开始下一局*/
		public static const NEXT_ROUND:String = "next_round";
		/**准备OK*/
		public static const READY_OK:String = "readyOk";
		/**叫庄*/
		public static const JIAO_Z:String = "jiaoZ";
		/**有叫庄资格*/
		public static const CAN_JIAO_Z:String = "canJiaoZ";
		/**没有叫庄资格*/
		public static const CANNOT_JIAO_Z:String = "cannotJiaoZ";
		/**选择不叫庄，包括自己选择、时间到系统帮选择*/
		public static const BU_JIAO_Z:String = "bujiaoZ";
		/**成为庄家*/
		public static const IS_Z:String = "isZ";
		/**确定亮牌*/
		public static const CONFIRM_SHOW_CARDS:String = "confirmShowCards";
		/**托管*/
		public static const TUO_GUAN:String = "tuoguan";
		/**取消托管*/
		public static const CANCEL_TUO_GUAN:String = "cancelTuoguan";
		public var data:Object;
		public function UserEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event{
			return new UserEvent(type, data, bubbles, cancelable);
		}
	}
}