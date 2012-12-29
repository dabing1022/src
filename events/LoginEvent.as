package events
{
	import flash.events.Event;
	
	/**登录事件*/
	public class LoginEvent extends Event
	{
		public static const LOGIN_CONFIRM:String = "login confirm";
		public static const LOGIN_CANCEL:String = "login cancel";
		public var userData:Object;
		
		public function LoginEvent(type:String, userData:Object, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.userData = userData;
		}
		
		override public function clone():Event
		{
			return new LoginEvent(type, userData, bubbles, cancelable);
		}
	}
}


