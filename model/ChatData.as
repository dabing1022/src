package model
{
	import events.ChatEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class ChatData extends EventDispatcher
	{
		private var _nickNameList:Vector.<String>;
		private var _messageList:Vector.<String>;
		private var _lastSendTime:uint;
		public static const MIN_TIME_INTERVAL:uint = 1000;
		public function ChatData()
		{
			_nickNameList = new Vector.<String>();
			_messageList = new Vector.<String>();
		}
		
		public function addMessage(nickName:String, message:String):void{
			_nickNameList.push(nickName);
			_messageList.push(message);
			dispatchEvent(new ChatEvent(ChatEvent.DATA_CHANGE));
		}
		
		public function addFastMessage(nickName:String, messageId:int):void{
			var message:String = "";
			_nickNameList.push(nickName);
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
			_messageList.push(message);
			dispatchEvent(new ChatEvent(ChatEvent.DATA_CHANGE));
		}

		public function getLastMessage():Object
		{
			var obj:Object = {};
			obj.nickName = _nickNameList.shift();
			obj.message = _messageList.shift();
			return obj;
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
