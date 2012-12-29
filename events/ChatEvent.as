package events
{
	import flash.events.Event;
	
	/**聊天事件*/
	public class ChatEvent extends Event
	{
		public static const DATA_CHANGE:String = "dataChange";
		public function ChatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event{
			return new ChatEvent(type, bubbles, cancelable);
		}
	}
}