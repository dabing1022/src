package ui
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import model.CardData;
	import model.CardType;
	
	import utils.CardUtils;
	import utils.ResourceUtils;
	
	/**
	 * 用来呈现玩家最后亮的牌的容器
	 * */
	public class CardsResultShowBox extends Sprite
	{
		private var _isMySelf:Boolean;
		private var _cards:Array;
		private var _cardType:int;
		private var _hSpace:uint;
		private var _vSpace:uint;
		private var cardTypeShow:DisplayObject;
		public function CardsResultShowBox(cardType:int, cards:Array, isMySelf:Boolean = false)
		{
			super();
			_cardType = cardType;
			_cards = cards;
			_isMySelf = isMySelf;
			
			if(_isMySelf){
				_hSpace = 40;
				_vSpace = 36;
			}else{
				_hSpace = 25;
				_vSpace = 30;
			}
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			addCards();
			addCardTypeImg();
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			removeChildren();
			if(cardTypeShow is MovieClip){
				MovieClip(cardTypeShow).stop();
			}else if(cardTypeShow is Bitmap){
				Bitmap(cardTypeShow).bitmapData.dispose();
				Bitmap(cardTypeShow).bitmapData = null;
			}
			cardTypeShow = null;
		}
		
		private function addCards():void{
			var i:uint, j:uint;
			var cardData:CardData;
			var userCard:Bitmap;
			//牌型为无牛
			if(_cardType == CardType.NO_NIU || _cardType == CardType.WU_HUA_NIU)
			{
				for(i = 0; i < 5; i++){
					cardData = new CardData(_cards[i].color, _cards[i].value);
					userCard = new Bitmap(CardUtils.getInstance().cardMap[cardData.key]);
					addChild(userCard);
					userCard.x = _hSpace * i;
					userCard.y = 0;
				}
			}else if(_cardType == CardType.SI_ZHA){
				if(_cards[0].color == CardData.COLOR_GUI)//双鬼炸
				{
					for(i = 2; i < 5; i++){
						cardData = new CardData(_cards[i].color, _cards[i].value);
						userCard = new Bitmap(CardUtils.getInstance().cardMap[cardData.key]);
						addChild(userCard);
						userCard.x = _hSpace + _hSpace * (i - 2);
						userCard.y = 0;
					}
					for(j = 0; j < 2; j++){
						cardData = new CardData(_cards[j].color, _cards[j].value);
						userCard = new Bitmap(CardUtils.getInstance().cardMap[cardData.key]);
						addChild(userCard);
						userCard.x = _hSpace * 1.5 + _hSpace * j;
						userCard.y = _vSpace;
					}
				}else//4个同值炸
				{
					cardData = new CardData(_cards[4].color, _cards[4].value);
					userCard = new Bitmap(CardUtils.getInstance().cardMap[cardData.key]);
					addChild(userCard);
					userCard.x = _hSpace * 2;
					userCard.y = 0;
					for(j = 0; j < 4; j++){
						cardData = _cards[i];
						userCard = CardUtils.getInstance().cardMap[cardData.key];
						addChild(userCard);
						userCard.x = _hSpace * 0.5 + _hSpace * j;
						userCard.y = _vSpace;
					}
				}
			}else{
				for(i = 3; i < 5; i++){
					cardData = new CardData(_cards[i].color, _cards[i].value);
					userCard = new Bitmap(CardUtils.getInstance().cardMap[cardData.key]);
					addChild(userCard);
					userCard.x = _hSpace * (i - 3) + _hSpace * 1.5;
					userCard.y = 0;
				}
				for(j = 0; j < 3; j++){
					cardData = new CardData(_cards[j].color, _cards[j].value);
					userCard = new Bitmap(CardUtils.getInstance().cardMap[cardData.key]);
					addChild(userCard);
					userCard.x = _hSpace * j + _hSpace;
					userCard.y = _vSpace;
				}
			}
		}
		
		private function addCardTypeImg():void{
			var resName:String = CardUtils.getInstance().mapCardTypeToResName[_cardType];
			if(_cardType == CardType.NIU_NIU || _cardType == CardType.SI_ZHA || _cardType == CardType.WU_HUA_NIU){
				cardTypeShow = ResourceUtils.getMovieClip(resName);
			}else{
				cardTypeShow = ResourceUtils.getBitmap(resName);
				cardTypeShow.y = 20;
			}
			addChild(cardTypeShow);
			if(_cardType == CardType.NO_NIU || _cardType == CardType.WU_HUA_NIU){
				cardTypeShow.x = 127;
				cardTypeShow.y = 26;
			}else{
				cardTypeShow.x = 120;
				cardTypeShow.y = 50;
			}
		}
	}
}