package ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import utils.ResourceUtils;

	/**卡牌背面容器
	 * 5张背面牌，间距25px
	 * */
	public class CardsBackShow extends Sprite
	{
		private var backCardsVec:Vector.<Bitmap>;
		private const HSPACE:int = 25;
		public function CardsBackShow()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);		
			init();	
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);		
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);	
			while(backCardsVec.length > 0){
				(backCardsVec.pop()).bitmapData.dispose();
			}
			backCardsVec = null;
		}
		
		private function init():void{
			backCardsVec = new Vector.<Bitmap>();
			var backCard:Bitmap;
			for(var i:int = 0; i < 5; i++){
				backCard = ResourceUtils.getBitmap(Resource.BACK_CARD);
				addChild(backCard);
				backCard.x = HSPACE * i;
				backCardsVec.push(backCard);
			}
		}
	}
}