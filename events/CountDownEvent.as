package events
{
	import flash.events.Event;
	
	/**
	 * 倒计时事件
	 * */
	public class CountDownEvent extends Event
	{
		public static const TIME_UP:String = "timeIsUp";
		public var countDownType:int;
		public function CountDownEvent(type:String, countDownType:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.countDownType = countDownType;
		}
		
		override public function clone():Event{
			return new CountDownEvent(type, countDownType, bubbles, cancelable);
		}
	}
}