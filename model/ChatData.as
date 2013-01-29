package model
{
	import events.ChatEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import utils.DebugConsole;

	public class ChatData extends EventDispatcher
	{
		private var data:Object;
		private var _lastSendTime:uint;
		public static const MIN_TIME_INTERVAL:uint = 1000;
		public function ChatData()
		{
			data = {};
		}
		
		public function addMessage(nickName:String, message:String):void{
			data.nickName = nickName;
			data.message = message;
			dispatchEvent(new ChatEvent(ChatEvent.DATA_CHANGE));
		}
		
		public function addFastMessage(nickName:String, messageId:int):void{
			var message:String = "";
			data.nickName = nickName;
			switch(messageId){
				case 0:
					message = Const.FAST_REPLY0;
					break;
				case 1:
					message = Const.FAST_REPLY1;
					break;
				case 2:
					message = Const.FAST_REPLY2;
					break;
				case 3:
					message = Const.FAST_REPLY3;
					break;
				case 4:
					message = Const.FAST_REPLY4;
					break;
			}
			data.message = message;
			dispatchEvent(new ChatEvent(ChatEvent.DATA_CHANGE));
		}

		public function getLastMessage():Object
		{
			return this.data;
		}
		
		public function get lastSendTime():uint
		{
			return _lastSendTime;
		}

		public function set lastSendTime(value:uint):void
		{
			_lastSendTime = value;
		}
	}
}
