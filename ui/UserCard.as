package ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import model.CardData;
	
	import utils.CardUtils;
	import utils.ResourceUtils;
	
	/**
	 * 玩家牌
	 * */
	public class UserCard extends Sprite
	{
		private var _cardData:CardData;
		private var _backCard:Bitmap;
		private var _frontCard:Bitmap;
		private var _isFront:Boolean;
		public var isUp:Boolean;
		public function UserCard(cardData:CardData = null, showFront:Boolean = false)
		{
			super();
			_cardData = cardData;
			_isFront = showFront;
			isUp = false;
			
			if(_cardData){
				_frontCard = new Bitmap(CardUtils.getInstance().cardMap[_cardData.key]);
				addChild(_frontCard);
				_frontCard.visible = _isFront;
			}
			
			if(!_isFront){
				_backCard = ResourceUtils.getBitmap(Resource.BACK_CARD);
				addChild(_backCard);
			}
		}

		public function get isFront():Boolean
		{
			return _isFront;
		}

		public function set isFront(value:Boolean):void
		{
			_isFront = value;
		}

		public function get cardData():CardData
		{
			return _cardData;
		}

		public function set cardData(value:CardData):void
		{
			_cardData = value;
		}
	}
}
