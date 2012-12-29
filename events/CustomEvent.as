package events
{
	import flash.events.Event;
	
	public class CustomEvent extends Event
	{
		public static const PRELOAD_COMPLETE:String = "preload_complete";
		public static const BACK_TO_WELCOME:String = "back_to_welcome";
		public static const CHOOSE_ROOM:String = "choose_room";
		public static const CHOOSE_CHAIR:String = "choose_chair";
		/**倒计时时间到*/		
		public static const TIME_UP:String = "timeUp";
		public var data:Object;
		public function CustomEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event{
			return new CustomEvent(type, data, bubbles, cancelable);
		}
	}
}