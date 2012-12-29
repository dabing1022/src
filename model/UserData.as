package model
{
	import events.RoomEvent;
	import events.UserEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class UserData extends EventDispatcher
	{
		private var _roomId:int;
		private var _tableId:int;
		private var _chairId:int;
		private var _gamingPosId:int;
		private var _username:String;
		private var _nickName:String;
		private var _password:String;
		private var _platformId:int;
		private var _sex:uint;//0女1男
		private var _money:int;
		/**是否是庄家*/
		private var _isZ:Boolean;
		private var _canJiaoZ:Boolean;
		private var _isTuoguan:Boolean;
		private var _isOffLine:Boolean;
		/**当前玩家头像，默认为8*/
		public  var avarter:String = "gtouxiang8.gif";
		/**最终下注*/
		private var _betCoin:uint;
		private var _betCoinArr:Array;
		private var _cards:Array;
		private var _state:uint;
		/**剩余倒计时时间*/
		public var remainCountDownTime:uint;
		/**倒计时总时间*/
		public var totalCountTime:uint;
		private var _showCountDown:Boolean;
		private var _cardType:int;
		private var _showCards:Array;
		private var _winCoin:int;
		/**观看状态*/
		public static const USER_WATCH:uint = 2;
		/**等待准备*/
		public static const USER_WAIT_FOR_READY:uint = 3;
		/**准备状态*/
		public static const USER_READY:uint = 4;
		/**等待下注*/
		public static const USER_WAIT_BET:uint = 5;
		/**已经下注*/
		public static const USER_BET:uint = 6;
		/**等待摊牌*/
		public static const USER_WAIT_SHOWCARDS:uint = 7;
		/**已经摊牌*/
		public static const USER_SHOWCARDS:uint = 8;
		/**叫庄时间*/
		public static const USER_JIAO_Z:uint = 9;

		public function UserData(target:IEventDispatcher=null)
		{
			super(target);
			_betCoinArr = new Array();
			_cards = new Array();
			_showCards = new Array();
		}

		public function get username():String
		{
			return _username;
		}

		public function set username(value:String):void
		{
			_username = value;
		}

		public function get nickName():String
		{
			return _nickName;
		}

		public function set nickName(value:String):void
		{
			_nickName = value;
		}

		public function get money():int
		{
			return _money;
		}

		public function set money(value:int):void
		{
			_money = value;
			var obj:Object = {};
			obj.money = _money;
			dispatchEvent(new UserEvent(UserEvent.MONEY_CHANGE, obj));
		}

		/**玩家是否是庄家*/
		public function get isZ():Boolean
		{
			return _isZ;
		}

		public function set isZ(value:Boolean):void
		{
			_isZ = value;
			var obj:Object = {};
			obj.isZ = _isZ;
			dispatchEvent(new UserEvent(UserEvent.IS_Z, obj));
		}

		public function get isTuoguan():Boolean
		{
			return _isTuoguan;
		}

		public function set isTuoguan(value:Boolean):void
		{
			_isTuoguan = value;
		}

		public function get isOffLine():Boolean
		{
			return _isOffLine;
		}

		public function set isOffLine(value:Boolean):void
		{
			_isOffLine = value;
		}

		public function get roomId():int
		{
			return _roomId;
		}

		public function set roomId(value:int):void
		{
			_roomId = value;
		}

		public function get tableId():int
		{
			return _tableId;
		}

		public function set tableId(value:int):void
		{
			_tableId = value;
		}

		public function get chairId():int
		{
			return _chairId;
		}

		public function set chairId(value:int):void
		{
			_chairId = value;
		}

		public function get pid():int
		{
			return _platformId;
		}

		public function set pid(value:int):void
		{
			_platformId = value;
		}

		public function get state():uint
		{
			return _state;
		}

		public function set state(value:uint):void
		{
			_state = value;
			var obj:Object = {};
			obj.state = _state;
			dispatchEvent(new UserEvent(UserEvent.STATE_CHANGE, obj));
		}

		public function get sex():uint
		{
			return _sex;
		}

		public function set sex(value:uint):void
		{
			_sex = value;
		}

		/**最终下注*/
		public function get betCoin():uint
		{
			return _betCoin;
		}
		/**最终下注*/
		public function set betCoin(value:uint):void
		{
			_betCoin = value;
		}

		public function get cards():Array
		{
			return _cards;
		}

		public function set cards(value:Array):void
		{
			_cards = value;
		}

		public function get gamingPosId():int
		{
			return _gamingPosId;
		}

		public function set gamingPosId(value:int):void
		{
			_gamingPosId = value;
		}

		public function get showCountDown():Boolean
		{
			return _showCountDown;
		}

		public function set showCountDown(value:Boolean):void
		{
			_showCountDown = value;
			var obj:Object = {};
			obj.showCountDown = _showCountDown;
			dispatchEvent(new UserEvent(UserEvent.COUNT_DOWN_SHOW_CHANGE, obj));
		}

		/**是否具有叫庄的资格*/
		public function get canJiaoZ():Boolean
		{
			return _canJiaoZ;
		}

		/**
		 * @private
		 */
		public function set canJiaoZ(value:Boolean):void
		{
			_canJiaoZ = value;
			if(_canJiaoZ){
				dispatchEvent(new UserEvent(UserEvent.CAN_JIAO_Z));
			}
			else{
				dispatchEvent(new UserEvent(UserEvent.CANNOT_JIAO_Z));
			}
		}

		public function get betCoinArr():Array
		{
			return _betCoinArr;
		}

		public function set betCoinArr(value:Array):void
		{
			_betCoinArr = value;
		}

		public function get cardType():int
		{
			return _cardType;
		}

		public function set cardType(value:int):void
		{
			_cardType = value;
		}

		public function get showCards():Array
		{
			return _showCards;
		}

		public function set showCards(value:Array):void
		{
			_showCards = value;
		}

		public function get winCoin():int
		{
			return _winCoin;
		}

		public function set winCoin(value:int):void
		{
			_winCoin = value;
		}


	}
}