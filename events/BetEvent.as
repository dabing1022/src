package events
{
	import flash.events.Event;
	
	public class BetEvent extends Event
	{
		public static const BET:String = "bet";
		public var betCoin:uint;
		public function BetEvent(type:String, betCoin:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.betCoin = betCoin;
		}
		
		override public function clone():Event{
			return new BetEvent(type, betCoin, bubbles, cancelable);
		}
	}
}