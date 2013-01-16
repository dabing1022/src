package events
{
	import flash.events.Event;
	
	/**
	 * 点券兑换游戏豆、游戏豆兑换点券
	 * */
	public class ExchangeEvent extends Event
	{
		public static const POINT_TO_BEAN:String = "pointToBean";
		public static const BEAN_TO_POINT:String = "beanToPoint";
		public static const CONFIRM_POINT_TO_BEAN:String = "confirmPointToBean";
		public static const CONFIRM_BEAN_TO_POINT:String = "confirmBeanToPoint";
		public var exchangeNum:int;
		public function ExchangeEvent(type:String, exchangeNum:int = 0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.exchangeNum = exchangeNum;
		}
		
		override public function clone():Event{
			return new ExchangeEvent(type, exchangeNum, bubbles, cancelable);
		}
	}
}