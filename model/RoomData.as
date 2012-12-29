package model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import ui.HallChairUnit;
	
	public class RoomData extends EventDispatcher
	{
		private var _roomId:uint;
		private var _tableNum:uint;
		private var _players:Array;
		public function RoomData(target:IEventDispatcher=null)
		{
			super(target);
			_players = new Array();
		}
		
		public function init(value:Object):void{
			_roomId = value.roomId;
			_tableNum = value.tableNum;
			if(value.hasOwnProperty("players"))
				_players = value.players as Array;
				
		}

		public function get roomId():uint
		{
			return _roomId;
		}

		public function set roomId(value:uint):void
		{
			_roomId = value;
		}

		public function get tableNum():uint
		{
			return _tableNum;
		}

		public function set tableNum(value:uint):void
		{
			_tableNum = value;
		}

		public function get players():Array
		{
			return _players;
		}

		public function set players(value:Array):void
		{
			_players = value;
		}
	}
}