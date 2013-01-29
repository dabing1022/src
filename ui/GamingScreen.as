package ui
{
	import com.greensock.TweenLite;
	
	import events.BetEvent;
	import events.ExchangeEvent;
	import events.RoomEvent;
	import events.UserEvent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import model.CardData;
	import model.CardType;
	import model.Data;
	import model.GameState;
	import model.UserData;
	
	import utils.CardUtils;
	import utils.Childhood;
	import utils.DebugConsole;
	import utils.ResourceUtils;
	import utils.SoundManager;
	
	/**
	 * 游戏进行中界面
	 * */
	public class GamingScreen extends Sprite
	{
		private var gamingBg:Bitmap;
		private var myCardsBg:Bitmap;
		private var mapUserToMsgBox:Dictionary;
		public var myMessageBox:UserMessageBox;
		//下注信息盒子列表
		private var ratioBoxList:Vector.<RatioBox>;
		/*--------------buttons------------------*/
        /**准备按钮*/
		private var pleaseGetReadyBtn:AnimeButton;
		/**出牌提示按钮*/
		private var showCardsTipBtn:AnimeButton;
		/**出牌确定按钮*/
		private var showCardsConfirmBtn:AnimeButton;
		/**托管按钮*/
		private var tuoguanBtn:AnimeButton;
		/**取消托管*/
		private var cancelTuoguanBtn:AnimeButton;		
		/**叫庄按钮*/
		private var jiaoZBtn:AnimeButton;
		/**不叫庄按钮*/
		private var bujiaoZBtn:AnimeButton;
		/**声效*/
		private var soundOnBtn:SimpleButton;
		private var soundOffBtn:SimpleButton;
		/**点券兑换游戏豆按钮*/
		private var pointToBeanBtn:AnimeButton;
		/**离开房间按钮*/
		private var backToHallButton:SimpleButton;
		
		/*----------右侧功能，包括用户列表和聊天----------------*/
		private var playersDG:PlayerDataGrid;
		public var chatBox:ChatBox;
		private var posIdVec:Vector.<int>;
		private var myCardsVec:Vector.<UserCard>;
		private var othersCardsVec:Vector.<UserCard>;
		/**显示牌型的图片*/
		private var cardTypeShow:DisplayObject;
		/**手动选择的牌*/
		public var manualSelectCards:Vector.<UserCard>;
		private var mapUserNameToRatioBox:Dictionary;
		private var cardsResultShowVec:Vector.<CardsResultShowBox>;
		/**观看者眼中看玩家的背面牌列表*/
		private var cardsBackInWatcherViewList:Vector.<CardsBackShow>;
		private var cardsFrontInWatcherViewList:Vector.<CardsResultShowBox>;
		private var showTipConfirmTimer:Timer = new Timer(1000, 1); //收到发牌命令后1s后显示提示和确定按钮
		private var resultPanel:ResultPanel;
		public function GamingScreen()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			mapUserToMsgBox = new Dictionary();
			ratioBoxList = new Vector.<RatioBox>();
			myCardsVec = new Vector.<UserCard>();
			othersCardsVec = new Vector.<UserCard>();
			posIdVec = new Vector.<int>();
			posIdVec.push(0, 1, 2, 3, 4, 5, 6, 7);
			manualSelectCards = new Vector.<UserCard>();
			mapUserNameToRatioBox = new Dictionary();
			cardsResultShowVec = new Vector.<CardsResultShowBox>();
			cardsBackInWatcherViewList = new Vector.<CardsBackShow>();
			cardsFrontInWatcherViewList = new Vector.<CardsResultShowBox>();
			
			addBg();
			addPlayersDG();
			addChatBox();
			addAvatarInfo();
			addPlayersMessageBox();
			addMyCardsBg();
			addBtns();
			addEventListeners();
		}	
		
		/**加入背景图*/
		private function addBg():void{
			gamingBg = ResourceUtils.getBitmap(Resource.GAMING_BG);
			addChild(gamingBg);
		}

		private function addPlayersDG():void{
			playersDG = new PlayerDataGrid();
			addChild(playersDG);
		}

		private function addChatBox():void{
			chatBox = new ChatBox();
			chatBox.x = 793;
			chatBox.y = 292;
			addChild(chatBox);
		}

		/**加入玩家头像信息*/
		private function addAvatarInfo():void{
			addChild(AvatarInfo.getInstance());
			AvatarInfo.getInstance().x = 795;
			AvatarInfo.getInstance().y = 29;
		}
		
		/**加入玩家的信息盒子*/
		private function addPlayersMessageBox():void{
			var myUsername:String = Data.getInstance().player.username;
			var len:uint = Data.getInstance().gamingPlayersList.length;
			var i:uint;
			var myChairId:uint;
			var chairId:uint;
			var userData:UserData;
			for(i = 0; i < len; i++){
				if(myUsername == Data.getInstance().gamingPlayersList[i].username){
					Data.getInstance().player.chairId = Data.getInstance().gamingPlayersList[i].chairId;
					//获得玩家的状态用来决定是否显示卡牌背景和准备按钮
					Data.getInstance().player.state = Data.getInstance().gamingPlayersList[i].state;
					myChairId = Data.getInstance().player.chairId;
					Data.getInstance().gamingPlayersList[i].gamingPosId = 3;
					break;
				}
			}
			
			for(i = 0; i < len; i++){
				chairId = Data.getInstance().gamingPlayersList[i].chairId;
				if(myChairId == chairId)	continue;
				Data.getInstance().gamingPlayersList[i].gamingPosId = ((chairId + 8 - myChairId) + 3) % 8;
			}
			
			for(i = 0; i < len; i++){
				userData = Data.getInstance().gamingPlayersList[i];
				var playerMessageBox:UserMessageBox = new UserMessageBox(userData);
				addChild(playerMessageBox);
				if(userData.username == myUsername)
					myMessageBox = playerMessageBox;
				playerMessageBox.x = Const.USER_COORD[userData.gamingPosId].x;
				playerMessageBox.y = Const.USER_COORD[userData.gamingPosId].y;
				mapUserToMsgBox[userData.username] = playerMessageBox;
				playersDG.addItemInDp(userData);
			}
			
			chatBox.addWelcomeMessage(Data.getInstance().player.nickName);
		}

		private function addMyCardsBg():void{
			myCardsBg = ResourceUtils.getBitmap(Resource.PLAYER_CARDS_BG);
			myCardsBg.x = 224;
			myCardsBg.y = 352;
			addChild(myCardsBg);
			if(Data.getInstance().player.state == UserData.USER_WATCH)
				myCardsBg.visible = false;
			else
				myCardsBg.visible = true;
		}

		private function addBtns():void{
			pleaseGetReadyBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.PLEASE_GET_READY_BUTTON1),
				ResourceUtils.getBitmapData(Resource.PLEASE_GET_READY_BUTTON2),
				ResourceUtils.getBitmapData(Resource.PLEASE_GET_READY_BUTTON1));
			if(Data.getInstance().player.state == UserData.USER_WAIT_FOR_READY && Data.getInstance().gamingPlayersList.length == 1)
				pleaseGetReadyBtn.visible = true;
			else
				pleaseGetReadyBtn.visible = false;
			addChild(pleaseGetReadyBtn);
			pleaseGetReadyBtn.focusRect = false;
			pleaseGetReadyBtn.x = 345;
			pleaseGetReadyBtn.y = 494;
			
			showCardsTipBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.SHOW_CARDS_TIP_BUTTON1),
				ResourceUtils.getBitmapData(Resource.SHOW_CARDS_TIP_BUTTON2),
				ResourceUtils.getBitmapData(Resource.SHOW_CARDS_TIP_BUTTON1), 264, 498);
			addChild(showCardsTipBtn);
			showCardsTipBtn.visible = false;
			
			showCardsConfirmBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.SHOW_CARDS_CONFIRM_BUTTON1),
				ResourceUtils.getBitmapData(Resource.SHOW_CARDS_CONFIRM_BUTTON2),
				ResourceUtils.getBitmapData(Resource.SHOW_CARDS_CONFIRM_BUTTON1), 400, 498);
			addChild(showCardsConfirmBtn);
			showCardsConfirmBtn.visible = false;
			
			jiaoZBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.JIAO_Z_BUTTON1),
				ResourceUtils.getBitmapData(Resource.JIAO_Z_BUTTON2),
				ResourceUtils.getBitmapData(Resource.JIAO_Z_BUTTON1), 265, 450);
			addChild(jiaoZBtn);
			jiaoZBtn.visible = false;
			
			bujiaoZBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.BUJIAO_Z_BUTTON1),
				ResourceUtils.getBitmapData(Resource.BUJIAO_Z_BUTTON2),
				ResourceUtils.getBitmapData(Resource.BUJIAO_Z_BUTTON1), 420, 450);
			addChild(bujiaoZBtn);
			bujiaoZBtn.visible = false;
			
			tuoguanBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.AUTO_PLAY),
				ResourceUtils.getBitmapData(Resource.AUTO_PLAY),
				ResourceUtils.getBitmapData(Resource.AUTO_PLAY), 540, 590);
			addChild(tuoguanBtn);
			tuoguanBtn.visible = false;
//			tuoguanBtn.visible = true;
			
			cancelTuoguanBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CANCEL_AUTO_PLAY),
				ResourceUtils.getBitmapData(Resource.CANCEL_AUTO_PLAY),
				ResourceUtils.getBitmapData(Resource.CANCEL_AUTO_PLAY), 540, 590);
			addChild(cancelTuoguanBtn);
			cancelTuoguanBtn.visible = false;
			
			soundOnBtn = ResourceUtils.getButton(Resource.SOUND_ON_BUTTON);
			addChild(soundOnBtn);
			soundOnBtn.x = 12;
			soundOnBtn.y = 590;
			soundOnBtn.visible = SoundManager.getInstance().soundMute;
			
			soundOffBtn = ResourceUtils.getButton(Resource.SOUND_OFF_BUTTON);
			addChild(soundOffBtn);
			soundOffBtn.x = 12;
			soundOffBtn.y = 590;
			soundOffBtn.visible = !soundOnBtn.visible;
			
			backToHallButton = ResourceUtils.getButton(Resource.BACK_TO_HALL_BUTTON);
			addChild(backToHallButton);
			backToHallButton.x = 12;
			backToHallButton.y = 620;
			
			pointToBeanBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.GAMING_CHARGE_BUTTON1),
										 ResourceUtils.getBitmapData(Resource.GAMING_CHARGE_BUTTON2),
										 ResourceUtils.getBitmapData(Resource.GAMING_CHARGE_BUTTON1), 110, 620);
			addChild(pointToBeanBtn);
		}

		private function addEventListeners():void{
			pleaseGetReadyBtn.addEventListener(MouseEvent.CLICK, onPleaseGetReadyHandler);
			showCardsTipBtn.addEventListener(MouseEvent.CLICK, onShowCardsTip);
			showCardsConfirmBtn.addEventListener(MouseEvent.CLICK, onShowCardsConfirm);
			jiaoZBtn.addEventListener(MouseEvent.CLICK, onJiaoZ);
			bujiaoZBtn.addEventListener(MouseEvent.CLICK, onJiaoZ);
			soundOnBtn.addEventListener(MouseEvent.CLICK, onOpenSoundHandler);
			soundOffBtn.addEventListener(MouseEvent.CLICK, onCloseSoundHandler);
			backToHallButton.addEventListener(MouseEvent.CLICK, onBackToHallHandler);
			pointToBeanBtn.addEventListener(MouseEvent.CLICK, onExchangePanelHandler);
//			tuoguanBtn.addEventListener(MouseEvent.CLICK, onTuoguanHandler);
//			cancelTuoguanBtn.addEventListener(MouseEvent.CLICK, onTuoguanHandler);
			
			showTipConfirmTimer.addEventListener(TimerEvent.TIMER, onShowTipAndConfirmBtns);
			Data.getInstance().player.addEventListener(UserEvent.STATE_CHANGE, onMyStateChangeHandler);
			Data.getInstance().player.addEventListener(UserEvent.CAN_JIAO_Z, onCanOrNotJiaoZ);
			Data.getInstance().player.addEventListener(UserEvent.CANNOT_JIAO_Z, onCanOrNotJiaoZ);
		}
/*----------------------------------------------------------------------------------------------------------------------*/
		private function onExchangePanelHandler(e:MouseEvent):void{
			dispatchEvent(new ExchangeEvent(ExchangeEvent.POINT_TO_BEAN, 0, true));
		}
		
		
		private function onTuoguanHandler(event:MouseEvent):void
		{
			if(event.currentTarget == tuoguanBtn){
				tuoguanBtn.visible = false;
				cancelTuoguanBtn.visible = true;
				dispatchEvent(new UserEvent(UserEvent.TUO_GUAN, null, true));
			}else{
				tuoguanBtn.visible = true;
				cancelTuoguanBtn.visible = false;
				dispatchEvent(new UserEvent(UserEvent.CANCEL_TUO_GUAN, null, true));
			}
		}
		
		/**有新玩家加入*/
		public function addNewPlayer(userData:UserData):void{
			var chairId:uint = userData.chairId;
			userData.gamingPosId = ((chairId + 8 - Data.getInstance().player.chairId) + 3) % 8;
			var playerMessageBox:UserMessageBox = new UserMessageBox(userData);
			addChild(playerMessageBox);
			playerMessageBox.x = Const.USER_COORD[userData.gamingPosId].x;
			playerMessageBox.y = Const.USER_COORD[userData.gamingPosId].y;
			mapUserToMsgBox[userData.username] = playerMessageBox;
			
			playersDG.addItemInDp(userData);
			chatBox.addWelcomeMessage(userData.nickName);
		}
		
		public function removePlayer(userData:UserData):void{
			if(!userData)	return;
			removeChild(mapUserToMsgBox[userData.username]);
			delete mapUserToMsgBox[userData.username];
			
			//如果玩家离开，该玩家对应有赢的注，也要移除
			if(mapUserNameToRatioBox.hasOwnProperty(userData.username)){
				var ratioBox:RatioBox = mapUserNameToRatioBox[userData.username];
				ratioBox.parent.removeChild(ratioBox);
				ratioBox.dispose();
				delete mapUserNameToRatioBox[userData.username];
			}
			
			playersDG.removeItemInDp(userData);
			chatBox.addLeaveMessage(userData.nickName);
		}
		
		public function switchGameState(state:uint, data:Object = null):void{
			switch(state){
				case GameState.START_JIAOZ:
					startJiaoZ(data);
					break;
				case GameState.USER_BET:
					stepIntoBetPhase();
					break;
				case GameState.SHOW_PLAYERS_BETCOIN:
					showPlayersBetCoin(data);
					break;
				case GameState.SEND_CARDS:
					sendCards(data);
					break;
				case GameState.WAIT_SHOWCARDS:
					waitShowCards();
					break;
				case GameState.FINAL_SHOWCARDS:
					finalShowCards(data);
					break;
				case GameState.GET_READY_FOR_NEXT:
					getReadyForNext(data as Array);
					break;
			}
		}
		
		private function getReadyForNext(resultData:Array):void{
			resultPanel = new ResultPanel(resultData);
			addChild(resultPanel);
			resultPanel.x = 242;
			resultPanel.y = 140;
			resultPanel.addEventListener(UserEvent.READY_OK, onNextTurnOkHandler);
			SoundManager.getInstance().playSound(Resource.SND_RESULT_YOU_NIU, false);
			if(Data.getInstance().player.cardType == CardType.NO_NIU){
				SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);
			}
		}
		
		private function finalShowCards(data:Object):void{
			DebugConsole.addDebugLog(stage, "最后一起亮牌！");
			removeOthersBackCards();//先将其他的背面牌移除
			
			var arr:Array = data as Array;
			var len:uint = arr.length;
			var i:uint;
			var cardsResultShowBox:CardsResultShowBox;
			var cardsShowPoint:Point = new Point();
			var desPoint:Point = new Point();
			var ratioBox:RatioBox;
			for(i = 0; i < len; i++){
				if(mapUserNameToRatioBox.hasOwnProperty(arr[i].username)){
					ratioBox = mapUserNameToRatioBox[arr[i].username];
					if(arr[i].winCoin > 0){
						ratioBox.setRatio(arr[i].winCoin);
						desPoint.x = mapUserToMsgBox[arr[i].username].x;
						desPoint.y = mapUserToMsgBox[arr[i].username].y + 50;
						TweenLite.to(ratioBox, 0.5, {x:desPoint.x, y:desPoint.y}); 
					}else{
						ratioBox.parent.removeChild(ratioBox);
						ratioBox.dispose();
						delete mapUserNameToRatioBox[arr[i].username];
					}
				}else{
					if(arr[i].makers && arr[i].winCoin > 0){
						var myRatioBox:RatioBox = new RatioBox(arr[i].winCoin, 1);
						addChild(myRatioBox);
						var posId:uint = chairIdToPosId(arr[i].chairId);
						myRatioBox.x = Const.RATIO_COORD[posId].x;
						myRatioBox.y = Const.RATIO_COORD[posId].y;
						desPoint.x = mapUserToMsgBox[arr[i].username].x;
						desPoint.y = mapUserToMsgBox[arr[i].username].y + 50;
						mapUserNameToRatioBox[arr[i].username] = myRatioBox;
						TweenLite.to(myRatioBox, 0.5, {x:desPoint.x, y:desPoint.y}); 
					}
				}
				//显示亮的卡牌
				if(arr[i].username == Data.getInstance().player.username) continue;
				var gamingPosId:uint = chairIdToPosId(arr[i].chairId);
				cardsShowPoint = Const.CARDS_COORD[gamingPosId];
				cardsResultShowBox = new CardsResultShowBox(arr[i].cardsSize, arr[i].showCards, false);
				addChild(cardsResultShowBox);
				cardsResultShowBox.x = cardsShowPoint.x;
				cardsResultShowBox.y = cardsShowPoint.y;
				cardsResultShowVec.push(cardsResultShowBox);
			}
		}
		
		private function removeCardResultShow():void{
			while(cardsResultShowVec.length > 0){
				removeChild(cardsResultShowVec.pop());
			}
			if(cardResultShowBox && cardResultShowBox.parent)
				removeChild(cardResultShowBox);
			while(cardsFrontInWatcherViewList.length > 0){
				removeChild(cardsFrontInWatcherViewList.pop());
			}
		}
		
		private function removeWinRatioBoxes():void{
			var len:uint = Data.getInstance().gamingPlayersList.length;
			var username:String;
			var ratioBox:RatioBox;
			for(var i:int = 0; i < len; i++){
				username = Data.getInstance().gamingPlayersList[i].username;
				if(mapUserNameToRatioBox.hasOwnProperty(username)){
					ratioBox = mapUserNameToRatioBox[username];
					ratioBox.parent.removeChild(ratioBox);
					ratioBox.dispose();
					delete mapUserNameToRatioBox[username];
				}
			}
		}
		
		private function waitShowCards():void{
			showTipAndConfirmBtns();
		}
		
		private function showTipAndConfirmBtns():void{
			showTipConfirmTimer.start();
		}
		
		public function hideGetReadyBtn():void{
			pleaseGetReadyBtn.visible = false;
			getReady();
		}
		
		private function onShowTipAndConfirmBtns(event:TimerEvent):void
		{
			showCardsTipBtn.visible = showCardsConfirmBtn.visible = true;
		}
		
		public function hideTipAndConfirmBtns():void{
			showCardsTipBtn.visible = showCardsConfirmBtn.visible = false;
			showTipConfirmTimer.reset();
		}
		
		private function sendCards(userData:Object):void{
			DebugConsole.addDebugLog(stage, "本局庄家在游戏中的POS_ID为： " + Data.getInstance().Z_PosId);
			var cardsArr:Array = userData.cards;
			var playersNum:uint = 8;
			var cardsNum:uint = playersNum * 5;
			var turn:uint;
			var posId:uint;
			var space:uint;
			var gamingPlayersPosIdVec:Vector.<int> = getGamingPlayersPosIdVec();	
			var cardIndex:uint = 0;
			var j:uint = 0;
			for(var i:int = 0; i < cardsNum; i++){
				posId = (i + Data.getInstance().Z_PosId) % playersNum;
				if(!judgeValueIsInVec(posId, gamingPlayersPosIdVec)){
					continue;
				}else{
					var userCard:UserCard;
					if(posId == 3){
						var cardData:CardData = new CardData(cardsArr[cardIndex].color, cardsArr[cardIndex].value);
						userCard = new UserCard(cardData, true);
						cardIndex++;
						space = 62; //玩家本人牌距
						myCardsVec.push(userCard);
						userCard.addEventListener(MouseEvent.CLICK, onChooseCardToShow);
						userCard.buttonMode = true;
					}else{
						userCard = new UserCard(null, false);
						space = 22; //其他玩家的牌距
						othersCardsVec.push(userCard);
					}
					j++;
				}
				
				addChild(userCard);
				userCard.visible = false;
				userCard.x = 360;
				userCard.y = 290;
				
				turn = i / playersNum;
				TweenLite.to(userCard, 0.5, {x:Const.CARDS_COORD[posId].x + space * turn,
											 y:Const.CARDS_COORD[posId].y,
											 delay: j * 0.08, 
											 onStart:onStartSendCards,
											 onStartParams:[userCard]});
			}
		}
		
		/**最后统一亮牌的时候移除其他人的背面的牌*/
		private function removeOthersBackCards():void{
			while(othersCardsVec.length > 0){
                var userCard:UserCard = othersCardsVec.pop();
				removeChild(userCard);
			}
			while(cardsBackInWatcherViewList.length > 0){
				var cardsBackShow:CardsBackShow = cardsBackInWatcherViewList.pop();
				removeChild(cardsBackShow);
			}
		}
		
		//得到正在玩的玩家的posId,排除观看者和无人位置
		private function getGamingPlayersPosIdVec():Vector.<int>{
			var gamingPlayersPosIdVec:Vector.<int> = new Vector.<int>();
			var len:uint = Data.getInstance().gamingPlayersList.length;
			var i:uint;
			for(i = 0; i < len; i++){
				if(Data.getInstance().gamingPlayersList[i].state != UserData.USER_WATCH){
					var posId:uint = chairIdToPosId(Data.getInstance().gamingPlayersList[i].chairId);
					gamingPlayersPosIdVec.push(posId);
				}
			}
			return gamingPlayersPosIdVec;
		}
		
		private function judgeValueIsInVec(value:uint, vec:Vector.<int>):Boolean{
			if(vec.indexOf(value) == -1)
				return false;
			return true;
		}
		
		private function onStartSendCards(userCard:UserCard):void{
			userCard.visible = true;
			SoundManager.getInstance().playSound(Resource.SND_SEND_CARDS, false);
		}
		
		public function showPlayersBetCoin(userData:Object):void{
			var ratioBox:RatioBox = new RatioBox(userData.betCoin, 1);
			addChild(ratioBox);
			ratioBox.x = mapUserToMsgBox[userData.username].x + 30;
			ratioBox.y = mapUserToMsgBox[userData.username].y + 30;
			var chairId:uint = userData.chairId;
			var gamingPosId:uint = chairIdToPosId(chairId);
			var desX:uint = Const.RATIO_COORD[gamingPosId].x;
			var desY:uint = Const.RATIO_COORD[gamingPosId].y;
			mapUserNameToRatioBox[userData.username] = ratioBox;
			TweenLite.to(ratioBox, 0.5, {x:desX, y:desY, onStart:playBetCoinSound});
		}
		
		private function playBetCoinSound():void{
			SoundManager.getInstance().playSound(Resource.SND_BET_COIN, false);
		}
		
		private function chairIdToPosId(chairId:uint):uint{
			return ((chairId + 8 - Data.getInstance().player.chairId) + 3) % 8;
		}
		
		private function stepIntoBetPhase():void{
			//如果自己是庄家，则不用下注
			if(!Data.getInstance().player.isZ)
				placeRatioBox();
		}
		
		private function placeRatioBox():void{
			DebugConsole.addDebugLog(stage, "展示下注数额...");
			var arr:Array = Data.getInstance().player.betCoinArr;
			for(var i:uint = 0; i < 4; i++){
				var ratioBox:RatioBox = new RatioBox(arr[i], 2);
				ratioBox.x = 252 + 75 * i;
				ratioBox.y = 440;
				addChild(ratioBox);
				ratioBoxList.push(ratioBox);
			}
		}
		
		public function removeRatioBoxes():void{
			while(ratioBoxList.length > 0){
				var ratioBox:RatioBox = ratioBoxList.pop();
				removeChild(ratioBox);
				ratioBox.dispose();
				ratioBox = null;
			}
		}
		
		public function updateMyMsgMoney(money:int):void{
			mapUserToMsgBox[Data.getInstance().player.username].userData.money = money;
		}
		
		public function updateGridMyMoney(money:int):void{
			playersDG.updateItemMoney(Data.getInstance().player.username, money);
		}
		
		public function updateMsgUserData(obj:Object):void{
			mapUserToMsgBox[obj.username].updateUserData(obj);
			
			playersDG.updateItemInDp(obj);
		}
		
		public function updateMsgsUserData(userArr:Array):void{
			var len:uint = userArr.length;
			var user:Object = {};
			for(var i:uint = 0; i < len; i++){
				user = userArr[i];
				mapUserToMsgBox[user.username].updateUserData(user);
				//将庄家的位置id保存起来
				if(user.makers){
					Data.getInstance().Z_PosId = chairIdToPosId(user.chairId);
				}
			}
		}
		
		private function startJiaoZ(data:Object):void{
			mapUserToMsgBox[data.username].updateUserData(data);
		}
		
		private function onBackToHallHandler(event:MouseEvent):void
		{
			dispatchEvent(new UserEvent(UserEvent.BACK_TO_HALL));			
		}
		
		/*---------------------------------Event handlers----------------------------------*/
		
		private function onJiaoZ(e:MouseEvent):void{
			if(e.target == jiaoZBtn)
				dispatchEvent(new UserEvent(UserEvent.JIAO_Z));
			else if(e.target == bujiaoZBtn)
				dispatchEvent(new UserEvent(UserEvent.BU_JIAO_Z));
			hideJiaoZButton();
			myMessageBox.hideCountDownAnime();
		}
		
		private function onOpenSoundHandler(e:MouseEvent):void{
			soundOnBtn.visible = false;
			soundOffBtn.visible = true;
			SoundManager.getInstance().muteSound();
		}
		
		private function onCloseSoundHandler(e:MouseEvent):void{
			soundOnBtn.visible = true;
			soundOffBtn.visible = false;
			SoundManager.getInstance().muteSound();
		}
		
		/**选择牌决定是否要展示*/
		private function onChooseCardToShow(e:MouseEvent):void{
			var userCard:UserCard = e.currentTarget as UserCard;
			userCard.y = userCard.isUp?userCard.y + 8 : userCard.y - 8;
			userCard.isUp = !userCard.isUp;
			if(userCard.isUp){
				manualSelectCards.push(userCard);
			}else{
				manualSelectCards.splice(manualSelectCards.indexOf(userCard), 1);
			}
			SoundManager.getInstance().playSound(Resource.SND_CHOOSE_CARD, false);
			if(!cardAnalysis)	return;
			if(!cardAnalysis.cardsIndex)	return;
			if(manualSelectCards.length != cardAnalysis.cardsIndex.length)
				disposeCardTypeShow();
		}
		
		/**将玩家手动选择的牌放在前面加上剩余的凑成数组发送服务端*/
		public function getManualCardsToSever():Array{
			var playerCards:Array = Childhood.clone(Data.getInstance().player.cards);
			var cardsIndex:Array = new Array();
			var len:uint = manualSelectCards.length;
			var i:uint;
			for(i = 0; i < len; i++){
				if(myCardsVec.indexOf(manualSelectCards[i]) != -1){
					cardsIndex[i] = myCardsVec.indexOf(manualSelectCards[i]);
				}
			}
			
			for(i = 0; i < len; i++){
				var index:int = cardsIndex[i];
				var tempDelete:Object = playerCards[index];
				playerCards.splice(index, 1); //将索引index处元素删除
				playerCards.splice(i, 0, tempDelete); //在i位置出增加刚才删除的元素
			}
			
			return playerCards;
		}
		
		private function onCanOrNotJiaoZ(e:UserEvent):void{
			if(e.type == UserEvent.CAN_JIAO_Z && Data.getInstance().player.state == UserData.USER_JIAO_Z){
				jiaoZBtn.visible = true;
				bujiaoZBtn.visible = true;
			}else if(e.type == UserEvent.CANNOT_JIAO_Z && Data.getInstance().player.state == UserData.USER_JIAO_Z){
				hideJiaoZButton();
				myCardsBg.visible = false;
			}
		}
		
		/**玩家本人的牌结果*/
		private var cardResultShowBox:CardsResultShowBox;
		private var confirmLock:Boolean = false;
		private function onShowCardsConfirm(e:MouseEvent = null):void{
			showDecisionCards(1, manualSelectCards, false);
			hideTipAndConfirmBtns();
			myMessageBox.hideCountDownAnime();
			DebugConsole.addDebugLog(stage, "亮牌确定后隐藏倒计时...");
		}
		
		private function onPleaseGetReadyHandler(e:MouseEvent = null):void{
			dispatchEvent(new UserEvent(UserEvent.READY_OK, null, true));
			getReady();
		}
		
		private function onNextTurnOkHandler(e:UserEvent):void{
			dispatchEvent(new UserEvent(UserEvent.READY_OK, null, true));
			getReady();
		}
		
		public function getReady():void{
			reset();
			myMessageBox.showHandUp();
			removeRatioBoxes();
			//移除赢的钱
			removeWinRatioBoxes();
			//移除结果面板
			if(resultPanel && this.contains(resultPanel)){
				removeChild(resultPanel);
				resultPanel.dispose();
				resultPanel = null;
			}
			//移除亮的牌
			removeCardResultShow();
			//清除庄的动画
			clearZ();
			myCardsBg.visible = false;
			pleaseGetReadyBtn.visible = false;
			myMessageBox.hideCountDownAnime();
			SoundManager.getInstance().playSound(Resource.SND_GET_READY, false);
			
			var userObj:Object = {};
			userObj.username = Data.getInstance().player.username;
			userObj.state = UserData.USER_READY;
			userObj.userCoin = Data.getInstance().player.money;
			playersDG.updateItemInDp(userObj);
		}
		
		private function clearZ():void
		{
			var len:uint = Data.getInstance().gamingPlayersList.length;
			var user:UserData;
			for(var i:uint = 0; i < len; i++){
				user = Data.getInstance().gamingPlayersList[i];
				if(user.isZ){
					var msgBox:UserMessageBox = mapUserToMsgBox[user.username];
					msgBox.hideZanime();
					break;
				}
			}
		}
		
		private function reset():void{
			confirmLock = false;
			//清空手动选择的牌数组
			manualSelectCards.splice(0, manualSelectCards.length);
		}
		
		public function hideJiaoZButton():void{
			jiaoZBtn.visible = false;
			bujiaoZBtn.visible = false;
		}
	
		public function hideGetReadyButton():void{
			pleaseGetReadyBtn.visible = false;
		}
		
		public function initOfflineLoginView(userList:Array):void{
			DebugConsole.addDebugLog(stage, "玩家本人断线重连，初始化下注和卡牌信息...");
			var len:int = userList.length;
			var i:int,j:int,k:int;
			//01.如果非庄家如果已经下注，则动画显示下注
			for(i = 0; i < len; i++){
				if(userList[i].makers == true){
					Data.getInstance().Z_PosId = chairIdToPosId(userList[i].chairId);
					continue;
				}
				if(userList[i].username == Data.getInstance().player.username && userList[i].state == UserData.USER_WAIT_BET){
					placeRatioBox();
					continue;
				}
				if(userList[i].state == UserData.USER_BET || userList[i].state == UserData.USER_WAIT_SHOWCARDS
					|| userList[i].state == UserData.USER_SHOWCARDS){
					DebugConsole.addDebugLog(stage, "玩家关闭浏览器重新进入显示下注信息...");
					showPlayersBetCoin(userList[i]);
				}
			}
			
			//02.如果玩家已发牌，但只要有玩家未亮牌，除下玩家自己，则显示背面牌
			var cardsBackShow:CardsBackShow;
			var playersNum:uint = 8;
			var posId:uint;
			var somebodyWaitShowCards:Boolean = checkSomebodyWaitShowCards(userList);
			for(j = 0; j < len; j++){
				if(somebodyWaitShowCards){
					posId = chairIdToPosId(userList[j].chairId);
					var userCard:UserCard;
					if(userList[j].username == Data.getInstance().player.username && userList[j].state == UserData.USER_WAIT_SHOWCARDS){
						var cardsArr:Array = userList[j].cards;
						for(i = 0; i < 5; i++){
							var cardData:CardData = new CardData(cardsArr[i].color, cardsArr[i].value);
							userCard = new UserCard(cardData, true);
							addChild(userCard);
							this.swapChildren(userCard, showCardsTipBtn);
							userCard.x = Const.CARDS_COORD[3].x + 62 * i;
							userCard.y = Const.CARDS_COORD[3].y;
							myCardsVec.push(userCard);
							userCard.addEventListener(MouseEvent.CLICK, onChooseCardToShow);
							userCard.buttonMode = true;
						}
						myCardsBg.visible = true;
						showCardsTipBtn.visible = showCardsConfirmBtn.visible = true;
						DebugConsole.addDebugLog(stage, "已经恢复玩家本人未亮牌...");
					}else if(userList[j].username == Data.getInstance().player.username && userList[j].state == UserData.USER_SHOWCARDS){
						cardResultShowBox = new CardsResultShowBox(userList[i].cardsSize, userList[i].showCards, true);
						addChild(cardResultShowBox);
						cardResultShowBox.x = Const.CARDS_COORD[3].x + 40;
						cardResultShowBox.y = Const.CARDS_COORD[3].y;
						myCardsBg.visible = true;
						this.swapChildren(cardResultShowBox, pleaseGetReadyBtn);
						DebugConsole.addDebugLog(stage, "已经恢复玩家本人亮的牌...");
					}else{
						if(userList[j].state == UserData.USER_WATCH)
							continue;
						for(k = 0; k < 5; k++){
							userCard = new UserCard(null, false);
							addChild(userCard);
							userCard.x = Const.CARDS_COORD[posId].x + 22 * k;
							userCard.y = Const.CARDS_COORD[posId].y;
							othersCardsVec.push(userCard);
						}
						DebugConsole.addDebugLog(stage, "已经恢复其他玩家背面牌...");
					}
				}
			}
			
			if(somebodyWaitShowCards)
				return;
			
			//03.如果玩家已亮牌，则显示亮牌
			for(i = 0; i < len; i++){
				if(userList[i].state == UserData.USER_SHOWCARDS){
					posId = chairIdToPosId(userList[i].chairId);
					DebugConsole.addDebugLog(stage, "玩家断线重连进去后, " + userList[i].username + ", posId:" + posId);
					if(userList[i].username == Data.getInstance().player.username){
						cardResultShowBox = new CardsResultShowBox(userList[i].cardsSize, userList[i].showCards, true);
						addChild(cardResultShowBox);
						cardResultShowBox.x = Const.CARDS_COORD[3].x + 40;
						cardResultShowBox.y = Const.CARDS_COORD[3].y;
						myCardsBg.visible = true;
						this.swapChildren(cardResultShowBox, pleaseGetReadyBtn);
						DebugConsole.addDebugLog(stage, "玩家断线重连进去后显示的自己的牌数据...");
					}else{
						var cardsResultShow:CardsResultShowBox = new CardsResultShowBox(userList[i].cardsSize, userList[i].showCards, false);
						addChild(cardsResultShow);
						cardsResultShow.x = Const.CARDS_COORD[posId].x;
						cardsResultShow.y = Const.CARDS_COORD[posId].y;
						cardsFrontInWatcherViewList.push(cardsResultShow);
						DebugConsole.addDebugLog(stage, "玩家断线重连进去后显示的其他人的牌数据...");
					}
				}
			}
		}
		
		private function checkSomebodyWaitShowCards(userList:Array):Boolean{
			var len:uint = userList.length;
			for(var i:uint = 0; i < len; i++){
				if(userList[i].state == UserData.USER_WAIT_SHOWCARDS)
					return true;
			}
			return false;
		}
		
		public function initWatcherView(userList:Array):void{
			var len:int = userList.length;
			var i:int;
			//01.如果非庄家如果已经下注，则动画显示下注
			for(i = 0; i < len; i++){
				if(userList[i].makers == true){
					Data.getInstance().Z_PosId = chairIdToPosId(userList[i].chairId);
					continue;
				}
				if(userList[i].state == UserData.USER_BET || userList[i].state == UserData.USER_WAIT_SHOWCARDS
					|| userList[i].state == UserData.USER_SHOWCARDS){
					DebugConsole.addDebugLog(stage, "玩家本人为观看者，播放下注数额动画...");
					showPlayersBetCoin(userList[i]);
				}
			}
			
			//02.如果玩家已发牌，但未亮牌，则显示背面牌
			var posId:int;
			var cardsBackShow:CardsBackShow;
			var somebodyWaitShowCards:Boolean = checkSomebodyWaitShowCards(userList);
			for(i = 0; i < len; i++){
				if(somebodyWaitShowCards){
					DebugConsole.addDebugLog(stage, "玩家本人为观看者，展示正在玩的玩家的牌背面...");
					if(userList[i].state == UserData.USER_WATCH)
						continue;
					posId = chairIdToPosId(userList[i].chairId);
					cardsBackShow = new CardsBackShow();
					addChild(cardsBackShow);
					cardsBackShow.x = Const.CARDS_COORD[posId].x;
					cardsBackShow.y = Const.CARDS_COORD[posId].y;
					cardsBackInWatcherViewList.push(cardsBackShow);
				}
			}
			
			if(somebodyWaitShowCards)
				return;
			
			//03.如果玩家已亮牌，则显示亮牌
			for(i = 0; i < len; i++){	
				if(userList[i].state == UserData.USER_SHOWCARDS){
					DebugConsole.addDebugLog(stage, "玩家本人为观看者，展示正在玩的玩家的牌正面结果...");
					posId = chairIdToPosId(userList[i].chairId);
					var cardsResultShow:CardsResultShowBox = new CardsResultShowBox(userList[i].cardsSize, userList[i].showCards, false);
					addChild(cardsResultShow);
					cardsResultShow.x = Const.CARDS_COORD[posId].x;
					cardsResultShow.y = Const.CARDS_COORD[posId].y;
					cardsFrontInWatcherViewList.push(cardsResultShow);
				}
			}
		}
		
		/**
		 * 系统分析的结果
		 * cardAnalysis
		 * <li>cardAnalysis.cardType牌型</li>
		 * <li>cardAnalysis.cardsIndex构成牌型的牌的索引数组</li>
		 * */
		private var soundName:String = null;
		private var cardAnalysis:Object = null;
		private function onShowCardsTip(e:MouseEvent = null):void{
			if(!confirmLock){
				pushDownManualCards();
				cardAnalysis = CardUtils.getInstance().analysisCards(Data.getInstance().player.cards);
				DebugConsole.addDebugLog(stage, "CardType: " + cardAnalysis.cardType + ", CardIndex: " + cardAnalysis.cardsIndex);
				//根据牌型对牌进行弹出操作
				popCardsByType(cardAnalysis);
				
				if(cardTypeShow && contains(cardTypeShow) && soundName){
					SoundManager.getInstance().playSound(soundName, false);
					return;
				}
				var resName:String = CardUtils.getInstance().mapCardTypeToResName[cardAnalysis.cardType];
				if(cardAnalysis.cardType == CardType.SI_ZHA){
					soundName = Resource.SND_BOMB;
					cardTypeShow = ResourceUtils.getMovieClip(resName);
				}else if(cardAnalysis.cardType == CardType.WU_HUA_NIU){
					soundName = Data.getInstance().player.sex == 0?Resource.SND_WU_HUA_NIU_FEMALE:Resource.SND_WU_HUA_NIU_MALE;
					cardTypeShow = ResourceUtils.getMovieClip(resName);
				}else{
					soundName = Data.getInstance().player.sex == 0?"female" + cardAnalysis.cardType : "male" + cardAnalysis.cardType;				
					if(cardAnalysis.cardType == CardType.NIU_NIU){
						cardTypeShow = ResourceUtils.getMovieClip(resName);
					}else{
						cardTypeShow = ResourceUtils.getBitmap(resName);
					}
					if(cardAnalysis.cardType == CardType.NO_NIU){
						SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);
					}
				}
				SoundManager.getInstance().playSound(soundName, false);
				addChild(cardTypeShow);
				cardTypeShow.x = 510;
				cardTypeShow.y = 390;
			}
		}
		
        //根据牌的分析返回结果将牌弹出
		private function popCardsByType(cardObj:Object):void{
			if(cardObj.cardType == CardType.NO_NIU)	return;
			var cardsIndex:Array = cardObj.cardsIndex;
			var len:uint = cardsIndex.length;
			var index:int;
			for(var i:uint = 0; i < len; i++){
				index = cardsIndex[i];
				myCardsVec[index].y = myCardsVec[index].isUp?myCardsVec[index].y : myCardsVec[index].y - 8;
				myCardsVec[index].isUp = true;
				manualSelectCards.push(myCardsVec[index]);
			}
		}
		
		private function pushDownManualCards():void{
			var len:uint = manualSelectCards.length;
			if(len > 0){
				for(var i:uint = 0; i < len; i++){
					manualSelectCards[i].y = manualSelectCards[i].isUp?manualSelectCards[i].y += 8 :manualSelectCards[i].y;
					manualSelectCards[i].isUp = false;
				}
			}
			manualSelectCards.splice(0, manualSelectCards.length);
		}
		
		/**将牌数据格式化后发送给服务器*/
		public function normalizeCards():Array{
			var playerCards:Array = Childhood.clone(Data.getInstance().player.cards);
			if(cardAnalysis.cardsIndex){
				var cardsIndex:Array = cardAnalysis.cardsIndex;
				var len:int = cardsIndex.length;
				var index:int;
				var tempDelete:Object;
				for(var i:int = 0; i < len; i++){
					index = cardsIndex[i];
					tempDelete = playerCards[index];
					playerCards.splice(index, 1); //将索引index处元素删除
					playerCards.splice(i, 0, tempDelete); //在i位置出增加刚才删除的元素
				}
			}
			return playerCards;
		}
		
		public function update():void{
			if(Data.getInstance().gamingPlayersList.length == 1){
				backToHallButton.visible = true;
			}
		}
		
		/**
		 * @param type
		 * <li>1 表示手动选择牌或者选择提示然后点击确定，附带第二个参数：牌数组
		 * <li>2 表示倒计时时间到，如果没有手动选牌系统自动判定为无牛</li>
		 * @param cards:Vector.<UserCard> 用户牌数组
		 * */
		public function showDecisionCards(type:uint, cards:Vector.<UserCard> = null, timeUp:Boolean = false):void{
			removeSystemSendsCards();
			if(type == 1 && !confirmLock){
				confirmLock = true;
				cardAnalysis = CardUtils.getInstance().analysisCards(Data.getInstance().player.cards);
				var popNum:uint = cards.length;
				var i:uint;
				var cardType:int;
				var cardsToServer:Array;
				var soundName:String;
				switch(popNum){
					case 0:
					case 1:
						cardType = CardType.NO_NIU;
						cardsToServer = Data.getInstance().player.cards;
						soundName = Data.getInstance().player.sex == 0?"female" + cardType:"male" + cardType;
						SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);
						break;
					case 2:
						if(cards[0].cardData.color == CardData.COLOR_GUI && cards[1].cardData.color == CardData.COLOR_GUI){
							cardType = CardType.SI_ZHA;
							cardsToServer = normalizeCards();
							soundName = Resource.SND_BOMB;
						}else{
							cardType = CardType.NO_NIU;
							cardsToServer = Data.getInstance().player.cards;
							soundName = Data.getInstance().player.sex == 0?"female" + cardType:"male" + cardType;
							SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);	
						}
						break;
					case 3:
						var temp3:int;
						for(i = 0; i < popNum; i++){
							temp3 += CardUtils.getInstance().getNiuValue(cards[i].cardData.value);
						}
						if(temp3 % 10 == 0){
							cardType = cardAnalysis.cardType;
							cardsToServer = normalizeCards();
							soundName = Data.getInstance().player.sex == 0?"female" + cardType:"male" + cardType;
						}else{
							cardType = CardType.NO_NIU;
							cardsToServer = Data.getInstance().player.cards;
							soundName = Data.getInstance().player.sex == 0?"female" + cardType:"male" + cardType;
							SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);	
						}
						break;
					case 4:
						var sameValue:int = cards[0].cardData.value;
						if(cards[0].cardData.value == sameValue
							&& cards[1].cardData.value == sameValue
							&& cards[2].cardData.value == sameValue
							&& cards[3].cardData.value == sameValue){
							cardType = CardType.SI_ZHA;
							cardsToServer = normalizeCards();
							soundName = Resource.SND_BOMB;
						}else{
							cardType = CardType.NO_NIU;
							cardsToServer = Data.getInstance().player.cards;
							soundName = Data.getInstance().player.sex == 0?"female" + cardType:"male" + cardType;
							SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);
						}
						break;
					case 5:
						if(isUserCardsInRange(cards, 11, 13)){
							cardType = CardType.WU_HUA_NIU;
							cardsToServer = Data.getInstance().player.cards;
							soundName = Data.getInstance().player.sex == 0?Resource.SND_WU_HUA_NIU_FEMALE:Resource.SND_WU_HUA_NIU_MALE;							
						}
						else{
							cardType = CardType.NO_NIU;
							cardsToServer = Data.getInstance().player.cards;
							soundName = Data.getInstance().player.sex == 0?"female" + cardType:"male" + cardType;
							SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);
						}
						break;
				}
				SoundManager.getInstance().playSound(soundName, false);
				cardResultShowBox = new CardsResultShowBox(cardType, cardsToServer, true);
				addChild(cardResultShowBox);
				cardResultShowBox.x = Const.CARDS_COORD[3].x + 40;
				cardResultShowBox.y = Const.CARDS_COORD[3].y;
				if(!timeUp)
					dispatchEvent(new UserEvent(UserEvent.CONFIRM_SHOW_CARDS, cardsToServer));
				this.swapChildren(cardResultShowBox, showCardsTipBtn);
				this.swapChildren(cardResultShowBox, pleaseGetReadyBtn);
			}else if(type == 2 && !confirmLock){
				confirmLock = true;
				
				soundName = Data.getInstance().player.sex == 0?"female" + CardType.NO_NIU:"male" + CardType.NO_NIU;
				SoundManager.getInstance().playSound(soundName, false);
				SoundManager.getInstance().playSound(Resource.SND_RESULT_NO_NIU, false);
				cardResultShowBox = new CardsResultShowBox(CardType.NO_NIU, Data.getInstance().player.cards, true);
				addChild(cardResultShowBox);
				cardResultShowBox.x = Const.CARDS_COORD[3].x + 20;
				cardResultShowBox.y = Const.CARDS_COORD[3].y;
				this.swapChildren(cardResultShowBox, showCardsTipBtn);
			}
		}
		
		private function isUserCardsInRange(cards:Vector.<UserCard>, min:uint, max:uint):Boolean{
			var len:uint = cards.length;
			var num:uint = 0;
			for(var i:uint = 0; i < len; i++){
				if(cards[i].cardData.value >= min && cards[i].cardData.value <= max){
					num++;
				}
			}
			if(num == len)
				return true;
			return false;
		}
		
		//移除系统给自己发的牌以及牌型提示
		private function removeSystemSendsCards():void{
			while(myCardsVec.length > 0){
                var userCard:UserCard = myCardsVec.pop();
                userCard.removeEventListener(MouseEvent.CLICK, onChooseCardToShow);
				removeChild(userCard);
			}
			
			disposeCardTypeShow();
		}
		
		private function disposeCardTypeShow():void
		{
			if(cardTypeShow){
				removeChild(cardTypeShow);
				if(cardTypeShow is MovieClip){
					MovieClip(cardTypeShow).stop();
					cardTypeShow = null;
				}else if(cardTypeShow is Bitmap){
					Bitmap(cardTypeShow).bitmapData.dispose();
					Bitmap(cardTypeShow).bitmapData = null;
					cardTypeShow = null;
				}
			}
		}
		
		private function onMyStateChangeHandler(e:UserEvent):void{
			switch(e.data.state){
				case UserData.USER_WATCH:
					myCardsBg.visible = false;
					backToHallButton.visible = true;
					hideJiaoZButton();
					break;
				case UserData.USER_WAIT_BET:
					hideJiaoZButton();
					myCardsBg.visible = true;
					backToHallButton.visible = false;
					break;
				case UserData.USER_BET:
					myCardsBg.visible = true;
					hideJiaoZButton();
					backToHallButton.visible = false;
					break;
				case UserData.USER_WAIT_SHOWCARDS:
					myCardsBg.visible = true;
					showTipAndConfirmBtns();
					hideJiaoZButton();
					backToHallButton.visible = false;
					break;
				case UserData.USER_SHOWCARDS:
					myCardsBg.visible = true;
					hideTipAndConfirmBtns();
					hideJiaoZButton();
					backToHallButton.visible = false;
					break;
				case UserData.USER_WAIT_FOR_READY:
					myCardsBg.visible = true;
					pleaseGetReadyBtn.visible = true;
					hideTipAndConfirmBtns();
					backToHallButton.visible = true;
					hideJiaoZButton();
					break;
				case UserData.USER_READY:
					myCardsBg.visible = true;
					hideTipAndConfirmBtns();
					pleaseGetReadyBtn.visible = false;
					hideJiaoZButton();
					break;
				case UserData.USER_JIAO_Z:
					myCardsBg.visible = true;
					backToHallButton.visible = false;
					hideTipAndConfirmBtns();
					break;
			}
		}
		
		private function removeEventListeners():void{
			pleaseGetReadyBtn.removeEventListener(MouseEvent.CLICK, onPleaseGetReadyHandler);
			showCardsTipBtn.removeEventListener(MouseEvent.CLICK, onShowCardsTip);
			showCardsConfirmBtn.removeEventListener(MouseEvent.CLICK, onShowCardsConfirm);
			jiaoZBtn.removeEventListener(MouseEvent.CLICK, onJiaoZ);
			bujiaoZBtn.removeEventListener(MouseEvent.CLICK, onJiaoZ);
			soundOnBtn.removeEventListener(MouseEvent.CLICK, onOpenSoundHandler);
			soundOffBtn.removeEventListener(MouseEvent.CLICK, onCloseSoundHandler);
			backToHallButton.removeEventListener(MouseEvent.CLICK, onBackToHallHandler);
			pointToBeanBtn.removeEventListener(MouseEvent.CLICK, onExchangePanelHandler);
//			tuoguanBtn.removeEventListener(MouseEvent.CLICK, onTuoguanHandler);
//			cancelTuoguanBtn.removeEventListener(MouseEvent.CLICK, onTuoguanHandler);
			
			showTipConfirmTimer.removeEventListener(TimerEvent.TIMER, onShowTipAndConfirmBtns);
			Data.getInstance().player.removeEventListener(UserEvent.STATE_CHANGE, onMyStateChangeHandler);
			Data.getInstance().player.removeEventListener(UserEvent.CAN_JIAO_Z, onCanOrNotJiaoZ);
			Data.getInstance().player.removeEventListener(UserEvent.CANNOT_JIAO_Z, onCanOrNotJiaoZ);
		}
		
		public function dispose():void{
			removeChildren();
			gamingBg.bitmapData.dispose();
			myCardsBg.bitmapData.dispose();
			gamingBg.bitmapData = null;
			myCardsBg.bitmapData = null;
			gamingBg = null;
			myCardsBg = null;
			
			removeEventListeners();
			pleaseGetReadyBtn.dispose();
			showCardsConfirmBtn.dispose();
			showCardsTipBtn.dispose();
			pleaseGetReadyBtn = null;
			showCardsConfirmBtn = null;
			showCardsTipBtn = null;
			
			manualSelectCards.splice(0, manualSelectCards.length);
			manualSelectCards = null;
		}
	}
}
