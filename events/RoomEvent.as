package events
{
	import flash.events.Event;
	
	public class RoomEvent extends Event
	{
		public static const CHANGE_ROOM:String = "change_room";
		public var roomId:uint;
		public function RoomEvent(type:String, roomId:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.roomId = roomId;
		}
		
		override public function clone():Event{
			return new RoomEvent(type, roomId, bubbles, cancelable);
		}
	}
}