package model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class TableData extends EventDispatcher
	{
		private var _roomId:uint;
		private var _tableId:uint;
		private var _state:int;
		/**没人*/
		public static const NO_PLAYER:uint = 1;
		/**游戏中*/
		public static const GAMING:uint = 2;
		/**准备中*/
		public static const WAITING:uint = 3;
		public function TableData(target:IEventDispatcher=null)
		{
			super(target);
		}

		public function get roomId():uint
		{
			return _roomId;
		}

		public function set roomId(value:uint):void
		{
			_roomId = value;
		}

		public function get tableId():uint
		{
			return _tableId;
		}

		public function set tableId(value:uint):void
		{
			_tableId = value;
		}

		public function get state():int
		{
			return _state;
		}

		public function set state(value:int):void
		{
			_state = value;
		}
	}
}