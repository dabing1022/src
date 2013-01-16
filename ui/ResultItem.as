package ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import utils.CardUtils;
	import utils.ResourceUtils;
	
	/**
	 * 结果面板数据单项显示
	 * */
	public class ResultItem extends Sprite
	{
		private var nickNameTxt:TextField;
		private var cardTypeTxt:TextField;
		private var coinTxt:TextField;
		private var isZAnime:MovieClip;
		public function ResultItem(nickName:String = "玩家", cardType:String = "牌型", coin:String = "金币", isZ:Boolean = false)
		{
			super();
			
			nickNameTxt = new TextField();
			with(nickNameTxt){
				width = 108;
				height = 20;
				textColor = 0xffff00;
				autoSize = TextFieldAutoSize.CENTER;
				text = nickName;
			}
			addChild(nickNameTxt);
			
			cardTypeTxt = new TextField();
			with(cardTypeTxt){
				width = 60;
				height = 20;
				x = 125;
				textColor = 0xffff00;
				autoSize = TextFieldAutoSize.CENTER;
				if(cardType == "牌型")
					text = cardType;
				else
					text = CardUtils.getInstance().mapCardTypeToTxt[cardType];
			}
			addChild(cardTypeTxt);
			
			coinTxt = new TextField();
			with(coinTxt){
				width = 82;
				height = 20;
				x = 193;
				textColor = 0xffff00;
				autoSize = TextFieldAutoSize.CENTER;
				text = coin;
			}
			addChild(coinTxt);
			
			if(isZ){
				isZAnime = ResourceUtils.getMovieClip(Resource.IS_Z_ANIME);
				addChild(isZAnime);
				isZAnime.scaleX = isZAnime.scaleY = 0.4;
				isZAnime.x = -10;
				isZAnime.y = -2;
			}
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			dispose();
		}
		
		public function dispose():void{
			removeChildren();
			if(isZAnime){
				isZAnime.stop();
				isZAnime = null;
			}
			nickNameTxt = null;
			cardTypeTxt = null;
			coinTxt = null;
		}
	}
}