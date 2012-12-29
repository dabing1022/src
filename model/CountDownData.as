package model
{
	import events.CustomEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.getTimer;
	
	/**
	 * 倒计时数据
	 * */
	public class CountDownData extends EventDispatcher
	{
		private var _startTime:int;
		private var _currTime:int;
		private var _endTime:int;
		private var _remoteTime:int;
		private var _remoteTimeOver:Boolean;
		private static var _instance:CountDownData;
		public function CountDownData(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function initTime(remoteTime:int):void{
			_remoteTime = remoteTime * 1000;
			_startTime = getTimer();
			_endTime = _startTime + _remoteTime;
		}
		
		/**
		 * 获得倒计时剩余时间
		 * @return int 返回的单位是秒
		 **/
		public function getRemainTime():int{
			var remainTime:int = _endTime - getTimer();
			if(remainTime <= 0)
				dispatchEvent(new CustomEvent(CustomEvent.TIME_UP));
			return remainTime >= 0? remainTime / 1000 : 0;
		}
		
		public static function getInstance():CountDownData{
			if(_instance == null)
				_instance = new CountDownData();
			return _instance;
		}

		public function get startTime():int
		{
			return _startTime;
		}

		public function set startTime(value:int):void
		{
			_startTime = value;
		}

		public function get currTime():int
		{
			return _currTime;
		}

		public function set currTime(value:int):void
		{
			_currTime = value;
		}

		public function get endTime():int
		{
			return _endTime;
		}

		public function set endTime(value:int):void
		{
			_endTime = value;
		}

		public function get remoteTime():int
		{
			return _remoteTime;
		}

		public function set remoteTime(value:int):void
		{
			_remoteTime = value;
		}

		public function get remoteTimeOver():Boolean
		{
			return _remoteTimeOver;
		}

		public function set remoteTimeOver(value:Boolean):void
		{
			_remoteTimeOver = value;
		}


	}
}