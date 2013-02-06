package ui
{
	import events.CountDownEvent;
	import events.UserEvent;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.utils.Timer;
	
	import model.CountDownData;
	import model.Data;
	import model.UserData;
	
	import utils.DebugConsole;
	import utils.ResourceUtils;
	
	/**
	 * 玩家信息，包括头像，昵称，金豆数，以及状态、倒计时等信息
	 * */
	public class UserMessageBox extends Sprite
	{
		/**用户信息背景*/
		private var boxBg:Bitmap;
		/**用户头像*/
		private var avarter:Bitmap;
		/**倒计时动画*/
		private var countDownAnime:MovieClip;
		/**准备了举手状态*/
		private var handUp:Bitmap;
		/**昵称和状态文本*/
		private var nickNameAndStatusTxt:TextField;
		/**元宝图片*/
		private var moneySymbol:Bitmap;
		/**游戏币文本*/
		private var moneyTxt:TextField;
		private const PLEASE_WAIT:String = "游戏中，请等待片刻...";
		private const WAITING:String = "观看等待中...";
		private const WAIT_OTHERS_JIAO_Z:String = "请等待其他玩家抢庄...";
		private const WAIT_OTHERS_BET:String = "请等待其他玩家下注...";
		private var countDownTimer:Timer;
		private var isMySelf:Boolean;
		private var _userData:UserData;
		private var zSymbolAnime:MovieClip;
		public function UserMessageBox(userData:UserData)
		{
			super();
			_userData = userData;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}
		
		private function init():void{
			isMySelf = Data.getInstance().player.username == _userData.username? true : false;
			initCountDownTimer();
			
			boxBg = ResourceUtils.getBitmap(Resource.USER_MESSAGE_BOX_BG);
			addChild(boxBg);
			
			avarter = ResourceUtils.getBitmap(_userData.avarter);
			addChild(avarter);
			avarter.x = 8.5;
			avarter.y = 7.5;
			
			handUp = ResourceUtils.getBitmap(Resource.HAND_UP);
			addChild(handUp);
			handUp.x = 60;
			handUp.y = 8;
			handUp.visible = false;
			
			nickNameAndStatusTxt = new TextField();
			with(nickNameAndStatusTxt){
				//玩家刚进入桌子的时候有2个状态，一个是观看状态，一个是等待准备开始状态
				//观看状态无倒计时，等待准备开始状态伴随10s倒计时
				if(_userData.state == UserData.USER_WATCH){
					text = isMySelf?PLEASE_WAIT:WAITING;
				}else if(_userData.state == UserData.USER_WAIT_FOR_READY){
					text = _userData.nickName;
				}
				x = 75;
				y = 8;
				width = 150;
				height = 30;
				selectable = false;
				autoSize = TextFieldAutoSize.LEFT;
				textColor = 0xffffff;
				type = TextFieldType.DYNAMIC;
			}
			addChild(nickNameAndStatusTxt);
			
			moneySymbol = ResourceUtils.getBitmap(Resource.MONEY_SYMBOL);
			addChild(moneySymbol);
			moneySymbol.x = 60;
			moneySymbol.y = 32;
			
			moneyTxt = new TextField();
			with(moneyTxt){
				text = _userData.money;
				x = 78;
				y = 28;
				width = 100;
				height = 30;
				textColor = 0xffff00;
				autoSize = TextFieldAutoSize.LEFT;
				selectable = false;
			}
			addChild(moneyTxt);
			
			countDownAnime = ResourceUtils.getMovieClip(Resource.COUNT_DOWN_SHOW_ANIME);
			addChild(countDownAnime);
			countDownAnime.stop();
			countDownAnime.x = 20;
			countDownAnime.y = 25;
			if(_userData.showCountDown){
				countDownAnime.visible = true;
				var index:uint = 300 - 300 * (_userData.remainCountDownTime / _userData.totalCountTime);
				countDownAnime.gotoAndPlay(index);
				if(isMySelf)
					countDownTimer.start();
			}else{
				countDownAnime.visible = false;
				countDownAnime.stop();
			}
			
			addZsymbolAnime();
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			_userData.addEventListener(UserEvent.STATE_CHANGE, onStateChange);
			_userData.addEventListener(UserEvent.COUNT_DOWN_SHOW_CHANGE, onCountDownShowChange);
			_userData.addEventListener(UserEvent.MONEY_CHANGE, onMoneyChange);
			_userData.addEventListener(UserEvent.IS_Z, onIsZ);
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeChildren();
			
			boxBg.bitmapData.dispose();
			avarter.bitmapData.dispose();
			handUp.bitmapData.dispose();
			moneySymbol.bitmapData.dispose();
			boxBg.bitmapData = null;
			avarter.bitmapData = null;
			handUp.bitmapData = null;
			moneySymbol.bitmapData = null;
			boxBg = null;
			avarter = null;
			handUp = null;
			nickNameAndStatusTxt = null;
			moneySymbol = null;
			moneyTxt = null;
			if(countDownTimer){
				countDownTimer.stop();
				countDownTimer.removeEventListener(TimerEvent.TIMER, onCountDownTimer);
				countDownTimer = null;
			}
			countDownAnime.stop();
			countDownAnime = null;
			zSymbolAnime.stop();
			zSymbolAnime = null;
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			_userData.removeEventListener(UserEvent.STATE_CHANGE, onStateChange);
			_userData.removeEventListener(UserEvent.COUNT_DOWN_SHOW_CHANGE, onCountDownShowChange);
			_userData.removeEventListener(UserEvent.MONEY_CHANGE, onMoneyChange);
			_userData.removeEventListener(UserEvent.IS_Z, onIsZ);
		}
		
		private function addZsymbolAnime():void{
			zSymbolAnime = ResourceUtils.getMovieClip(Resource.IS_Z_ANIME);
			addChild(zSymbolAnime);
			zSymbolAnime.x = this.x - 15;
			zSymbolAnime.y = this.y + 65;
			zSymbolAnime.visible = _userData.isZ;
			zSymbolAnime.stop();
		}
		
		private function onIsZ(e:UserEvent):void{
			if(e.data.isZ){
				zSymbolAnime.visible= true;
				zSymbolAnime.play();
			}else{
				zSymbolAnime.visible= false;
				zSymbolAnime.stop();
			}
		}
		
		public function hideZanime():void{
			zSymbolAnime.visible= false;
			zSymbolAnime.stop();
		}
		
		//倒计时用来统计自己的倒计时时间
		private function initCountDownTimer():void{
			if(isMySelf){
				countDownTimer = new Timer(1000 / 30);
				countDownTimer.addEventListener(TimerEvent.TIMER, onCountDownTimer);
			}
		}
		
		private function onCountDownTimer(e:TimerEvent):void{
			if(!countDownAnime)		return;
			if(countDownAnime.visible && countDownAnime.currentFrame == countDownAnime.totalFrames){
				switch(_userData.state){
					case UserData.USER_WAIT_FOR_READY:
						dispatchEvent(new CountDownEvent(CountDownEvent.TIME_UP, UserData.USER_WAIT_FOR_READY, true));
						break;
					case UserData.USER_WAIT_BET:
						dispatchEvent(new CountDownEvent(CountDownEvent.TIME_UP, UserData.USER_WAIT_BET, true));
						break;
					case UserData.USER_WAIT_SHOWCARDS:
						dispatchEvent(new CountDownEvent(CountDownEvent.TIME_UP, UserData.USER_WAIT_SHOWCARDS, true));
						DebugConsole.addDebugLog(stage, "倒计时时间到派发亮牌事件");
						break;
					case UserData.USER_JIAO_Z:
						dispatchEvent(new CountDownEvent(CountDownEvent.TIME_UP, UserData.USER_JIAO_Z, true));
				}
				hideCountDownAnime();
			}
		}
		
		public function hideCountDownAnime():void{
			countDownAnime.visible = false;
			countDownAnime.stop();
			if(isMySelf)
				countDownTimer.reset();
		}
		
		public function showHandUp():void{
			handUp.visible = true;
		}
		
		private function onStateChange(e:UserEvent):void{
			switch(e.data.state){
				case UserData.USER_READY:
					handUp.visible = true;
					nickNameAndStatusTxt.text = _userData.nickName;
					break;
				case UserData.USER_JIAO_Z:
					handUp.visible = false;
					if(isMySelf && !_userData.canJiaoZ){
						nickNameAndStatusTxt.text = WAIT_OTHERS_JIAO_Z;
					}else{
						nickNameAndStatusTxt.text = _userData.nickName;
					}
					break;
				case UserData.USER_SHOWCARDS:
				case UserData.USER_WAIT_FOR_READY:
				case UserData.USER_BET:
				case UserData.USER_WAIT_SHOWCARDS:
					handUp.visible = false;
					nickNameAndStatusTxt.text = _userData.nickName;
					break;
				case UserData.USER_WAIT_BET:
					handUp.visible = false;
					if(isMySelf && _userData.isZ)
						nickNameAndStatusTxt.text = WAIT_OTHERS_BET;
					else
						nickNameAndStatusTxt.text = _userData.nickName;
					break;
				case UserData.USER_WATCH:
					nickNameAndStatusTxt.text = isMySelf? PLEASE_WAIT : WAITING;
					break;
			}
		}
		
		private function onCountDownShowChange(e:UserEvent):void{
			if(!countDownAnime)		return;
			if(e.data.showCountDown == true){
				countDownAnime.visible = true;
				var index:uint = 300 - 300 * (_userData.remainCountDownTime / _userData.totalCountTime);
				countDownAnime.gotoAndPlay(index);
				if(isMySelf){
					countDownTimer.start();
					DebugConsole.addDebugLog(stage, "倒计时开始...");
				}
			}else{
				hideCountDownAnime();
				if(isMySelf)
					DebugConsole.addDebugLog(stage, "倒计时结束重置...");
			}
		}
		
		private function onMoneyChange(e:UserEvent):void{
			moneyTxt.text = e.data.money;
		}
		
		public function updateUserData(obj:Object):void{
			_userData.username = obj.hasOwnProperty("username")?obj.username:_userData.username;
			_userData.roomId = obj.hasOwnProperty("roomId")?obj.roomId:_userData.roomId;
			_userData.money = obj.hasOwnProperty("userCoin")?obj.userCoin:_userData.money;
			_userData.showCountDown = obj.hasOwnProperty("showCD")?obj.showCD:_userData.showCountDown;
			_userData.betCoinArr = obj.hasOwnProperty("betCoinArray")?obj.betCoinArray:_userData.betCoinArr;
			_userData.state = obj.hasOwnProperty("state")?obj.state:_userData.state;
			_userData.avarter = obj.hasOwnProperty("avarter")?obj.avarter:_userData.avarter;
			_userData.betCoin = obj.hasOwnProperty("betCoin")?obj.betCoin:_userData.betCoin;
			_userData.cards = obj.hasOwnProperty("cards")?obj.cards:_userData.cards;
			_userData.chairId = obj.hasOwnProperty("chairId")?obj.chairId:_userData.chairId;
			_userData.nickName = obj.hasOwnProperty("nickName")?obj.nickName:_userData.nickName;
			_userData.pid = obj.hasOwnProperty("pid")?obj.pid:_userData.pid;
			_userData.canJiaoZ = obj.hasOwnProperty("chooseMakers")?obj.chooseMakers:_userData.canJiaoZ;
			_userData.isZ = obj.hasOwnProperty("makers")?obj.makers:_userData.isZ;
			_userData.sex = obj.hasOwnProperty("sex")?obj.sex:_userData.sex;
			_userData.tableId = obj.hasOwnProperty("tableId")?obj.tableId:_userData.tableId;
			_userData.isTuoguan = obj.hasOwnProperty("tuoguan")?obj.tuoguan:_userData.isTuoguan;
			_userData.remainCountDownTime = obj.hasOwnProperty("cdNum")?obj.cdNum:_userData.remainCountDownTime;
			_userData.totalCountTime = obj.hasOwnProperty("cdCount")?obj.cdCount:_userData.totalCountTime;
			_userData.cardType = obj.hasOwnProperty("cardsSize")?obj.cardsSize:_userData.cardType;
			_userData.showCards = obj.hasOwnProperty("showCards")?obj.showCards:_userData.showCards;
			_userData.winCoin = obj.hasOwnProperty("winCoin")?obj.winCoin:_userData.winCoin;
		}
		
		public function get userData():UserData
		{
			return _userData;
		}
		
		public function set userData(value:UserData):void
		{
			_userData = value;
		}
	}
}
