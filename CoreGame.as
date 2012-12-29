package
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	
	import events.BetEvent;
	import events.CountDownEvent;
	import events.CustomEvent;
	import events.LoginEvent;
	import events.RoomEvent;
	import events.UserEvent;
	
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import frocessing.color.ColorHSV;
	
	import model.Data;
	import model.GameState;
	import model.LoginData;
	import model.RoomData;
	import model.UserData;
	
	import ui.GamingScreen;
	import ui.HallChairUnit;
	import ui.HallScreen;
	import ui.HallTableUnit;
	import ui.LoginScreen;
	import ui.RoomTableContainer;
	import ui.TipPanel;
	import ui.WelcomeScreen;
	
	import utils.Childhood;
	import utils.CommunicateUtils;
	import utils.DebugConsole;
	import utils.SoundManager;
	
	public class CoreGame extends Sprite
	{
		private var configLoader:URLLoader;
		private var configUrlReq:URLRequest;
		private var ipLoader:URLLoader;
		private var remoteIP:String = "127.0.0.1";
		private var sign:String = null;
		private var getIPUrl:String;
		private var host:String;
		private var port:uint;
		private var socket:Socket;
		private var signTimer:Timer;
		private var heartBeat:int;
		private var gameTimer:Timer;
		
		private var dep:Number = 0;
		private var linearr:Array = new Array();
		private var dotarr:Array = new Array();
		private var draw_mc:Sprite;
		private var color:ColorHSV;
		public function CoreGame()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			loadConfig();
			addLoginScreen();
			
			//loginBySign();
			CommunicateUtils.getInstance().addEventListener(ErrorEvent.ERROR, onCommunicateError);
			
			ExternalInterface.addCallback("close",sendCloseCommand);
			color = new ColorHSV();
			draw_mc = new Sprite();
			addChild( draw_mc );   
			draw_mc.mouseEnabled = false;
			draw_mc.mouseChildren = false;
			startGameTimer();
		}
		
		private function startGameTimer():void{
			gameTimer = new Timer(1000 / 30);
			gameTimer.addEventListener(TimerEvent.TIMER, gameLoop);
			gameTimer.start();
		}
		
		private var temp:int;
		private var temp1:int;
		private function gameLoop(e:TimerEvent):void{
			temp = getTimer() - temp1;
			if(socket && socket.connected && temp > 7000){
				temp1 = getTimer();
				CommunicateUtils.getInstance().sendMessage(socket, Command.HEARTBEAT, "", false);
			}
			
			updateMousefx();
		}
		
		private var loginScreen:LoginScreen;
		private function addLoginScreen():void{
			loginScreen = new LoginScreen();
			addChild(loginScreen);
			loginScreen.addEventListener(LoginEvent.LOGIN_CONFIRM, onLoginConfirm);
		}
		
		private function onLoginConfirm(event:LoginEvent):void
		{
			var loginData:Object = {};
			loginData.username = event.userData.username;
//			loginData.password = event.userData.password;
//			loginData.platform = event.userData.platformId;
//			loginData.username = "3218115";
			if(event.userData.password == "")
				loginData.password = "123456";
			else 
				loginData.password = event.userData.password;
			loginData.platform = 51;
			loginData.ip = remoteIP;
			CommunicateUtils.getInstance().sendMessage(socket, Command.NOMAL_LOGIN, loginData);
		}		
		
		
		private function loginBySign():void{
			var sign:String = stage.loaderInfo.parameters("sign");
			if(sign){
				LoginData.getInstance().sign = sign;
				connectServer();
				signTimer = new Timer(1000);
				signTimer.addEventListener(TimerEvent.TIMER, onSignTimer);
				signTimer.start();
			}
			this.sign = sign;
		}
		
		private function connectServer():Socket
		{
			if (socket == null){
				socket = new Socket();
				socket.addEventListener(Event.CONNECT, onConnect);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
				socket.addEventListener(Event.CLOSE, onClose);
				socket.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			}
			if(!socket.connected){
				socket.connect(host, port);
			}
			return socket;
		}
	
		private function onConnect(e:Event):void{
			DebugConsole.addDebugLog(stage, "连接服务器成功！");
		}
		
		/**在服务器关闭套接字连接时调度*/
		private function onClose(e:Event):void{
			DebugConsole.addDebugLog(stage, "Socket连接关闭！");
			tryReconnect();
		}
		
		/**在出现输入/输出错误并导致发送或加载操作失败时调度*/
		private function onIoError(e:IOErrorEvent):void{
			DebugConsole.addDebugLog(stage, "输入/输出错误并导致发送或加载操作失败！");
			tryReconnect();
		}
		
		/**若对 Socket.connect() 的调用尝试连接到调用方安全沙箱外部的服务器或端口号低于 1024 端口，则进行调度*/
		private function onSecurityError(e:SecurityErrorEvent):void{
			DebugConsole.addDebugLog(stage, "安全沙箱或端口低于1024错误...");
		}
			
		private var len:int = 0;
		private var cmd:String = "";
		private var content:String = "";
		private var run:Boolean = false;
		private function onSocketData(e:ProgressEvent):void{
			try{
				if(len == 0 && socket.bytesAvailable){
					len = socket.readInt();
				}
				while(len != 0 && len <= socket.bytesAvailable && !run){
					run = true;
					cmd = socket.readUTFBytes(Command.COMMANDLENGTH);
					content = socket.readUTFBytes(len - Command.COMMANDLENGTH);
					trace("cmd = " + cmd + " content = " + content);
					processMessage(cmd, content);
					
					if(socket.bytesAvailable){
						len = socket.readInt();
						run = false;
					}else{
						len = 0;
						run = false;
					}
				}
			}catch(error:Error){
				DebugConsole.addDebugLog(stage, "Something wrong happened in onSocketData...");
			}
		}
		
		/**
		 * 处理消息
		 * @param cmd 命令
		 * @param content 内容
		 */
		private function processMessage(cmd:String, content:String):void{
			switch (cmd)
			{
				case Command.HEARTBEAT://心跳包
					onHeartBeat(content);
					break;
				case Command.ERROR:
					onError(content);
					break;
				case Command.NOMAL_LOGIN:
					onLogin(content);
					break;
				case Command.CHOOSE_ROOM:
					onChooseRoom(content);
					break;
				case Command.HALL_CHOOSE_ROOM:
					onHallChooseRoom(content);
					break;
				case Command.CHOOSE_CHAIR:
					onChooseChair(content);
					break;
				case Command.UPDATE_CHAIR:
					onUpdateChair(content);
					break
				case Command.GAMING_ADD_PLAYER:
					onGamingAddPlayer(content);
					break;
				case Command.PLAYER_LEAVE_TABLE:
					onPlayerLeaveTable(content);
					break;
				case Command.BACK_TO_HALL:
					onBackToHall(content);
					break;
				case Command.UPDATE_TABLE_PLAYER:
					onUpdateTablePlayer(content);
					break;
				case Command.START_JIAO_Z:
					onStartJiaoZ(content);
					break;
				case Command.SYSTEM_CHOOSE_Z:
					onSystemChooseZ(content);
					break;
				case Command.SHOW_PLAYER_BETCOIN:
					onShowPlayerBetCoin(content);
					break;
				case Command.SEND_CARDS:
					onSendCards(content);
					break;
				case Command.WAIT_SHOWCARDS://等待亮牌，期间倒计时之内选择牌
					onWaitShowCards(content);
					break;
				case Command.START_SHOWCARDS://统一亮牌
					onStartShowCards(content);
					break;
				case Command.GAME_OVER://游戏结束显示结果面板，并且开始倒计时
					onGameOver(content);
					break;
				case Command.NOMAL_CHAT:
					onNomalChat(content);
					break;
				case Command.FAST_REPLY:
					onFastReply(content);
					break;
			}
		}
		
		private function onFastReply(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().chatData.addFastMessage(obj.nickName, obj.messageId);
		}
		
		private function onNomalChat(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().chatData.addMessage(obj.nickName, obj.message);
		}
		
		private function onGameOver(content:String):void{
			DebugConsole.addDebugLog(stage, "命令接收：Command.GAME_OVER");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			addResultInChat(obj as Array);
			Data.getInstance().updateTablePlayers(obj as Array);
			Data.getInstance().updateMyselfInArr(obj as Array);
			gamingScreen.updateMsgsUserData(obj as Array);
			gamingScreen.switchGameState(GameState.GET_READY_FOR_NEXT, obj as Array);
		}	
		
		private function addResultInChat(resultArr:Array):void
		{
			gamingScreen.chatBox.addResultPre();
			var len:uint = resultArr.length;
			var winCoin:String;
			for(var i:uint = 0; i < len; i++){
				if(resultArr[i].winCoin == 0) continue; //观看者不计入
				winCoin = resultArr[i].winCoin > 0? "+" + resultArr[i].winCoin : resultArr[i].winCoin;
				Data.getInstance().chatData.addMessage(resultArr[i].nickName, winCoin);
			}
		}
		
		private function onStartShowCards(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().updateTablePlayers(obj as Array);
			Data.getInstance().updateMyselfInArr(obj as Array);
			gamingScreen.switchGameState(GameState.FINAL_SHOWCARDS, obj);
		}
		
		private function onWaitShowCards(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userDataArr:Array = obj as Array;
			Data.getInstance().updateTablePlayers(userDataArr);
			Data.getInstance().updateMyselfInArr(userDataArr);
			gamingScreen.updateMsgsUserData(userDataArr);
			if(Data.getInstance().player.state == UserData.USER_WATCH) return; //如果玩家自己是观看者，则不用显示提示确定按钮
			gamingScreen.switchGameState(GameState.WAIT_SHOWCARDS);
		}
		
		private function onSendCards(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateTablePlayer(obj);
			Data.getInstance().updateTablePlayer(obj);
			Data.getInstance().updateMyself(obj);
			gamingScreen.updateMsgUserData(obj);
			gamingScreen.switchGameState(GameState.SEND_CARDS, userData);
		}
		
		private function onShowPlayerBetCoin(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateTablePlayer(obj);
			Data.getInstance().updateTablePlayer(obj);
			gamingScreen.updateMsgUserData(obj);
			if(userData.username != Data.getInstance().player.username)
				gamingScreen.switchGameState(GameState.SHOW_PLAYERS_BETCOIN, userData);
		}
		
		//庄家确定后，庄家等待其他玩家下注，其他玩家10s下注时间
		private function onSystemChooseZ(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userDataArr:Array = obj as Array;
			Data.getInstance().updateTablePlayers(userDataArr);
			gamingScreen.updateMsgsUserData(userDataArr);
			if(Data.getInstance().player.state == UserData.USER_WATCH)	return; //如果自己是观看者，什么也不做
			Data.getInstance().updateMyselfInArr(userDataArr);
			gamingScreen.switchGameState(GameState.USER_BET);
		}
		
		private function onStartJiaoZ(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().updateMyself(obj);
			Data.getInstance().updateTablePlayer(obj);
			gamingScreen.updateMsgUserData(obj);
			gamingScreen.switchGameState(GameState.START_JIAOZ, obj);
		}
		
		private function onUpdateTablePlayer(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateTablePlayer(obj);
			Data.getInstance().updateTablePlayer(obj);
			gamingScreen.updateMsgUserData(obj);
		}
		
		private function onBackToHall(content:String):void{
			clearGamingScreen();
			var roomObj:Object = com.adobe.serialization.json.JSON.decode(content);
			creatRoom(roomObj);
		}
		
        //当玩家从牌桌离开后通知牌桌内的其他玩家
		private function onPlayerLeaveTable(content:String):void{
			DebugConsole.addDebugLog(stage, "命令接收：PLAYER_LEAVE_TABLE");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().removePlayerInList(obj);
			gamingScreen.removePlayer(userData);
		}
		
		private function onGamingAddPlayer(content:String):void{
			DebugConsole.addDebugLog(stage, "命令接收：GAMING_ADD_PLAYER");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().addNewPlayerInList(obj);
			gamingScreen.addNewPlayer(userData);
		}
		
		private function onUpdateChair(content:String):void{
			DebugConsole.addDebugLog(stage, "命令接收：UPDATE_CHAIR");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateChairs(obj);
			if(Data.getInstance().player.roomId == 1){
				chujiRoomTableContainer.update(userData);
			}else if(Data.getInstance().player.roomId == 2){
				gaojiRoomTableContainer.update(userData);
			}
		}
		
		private function onChooseChair(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var usersInfoList:Array = obj as Array;
			Data.getInstance().usersInfoList2gamingPlayersList(usersInfoList);
			tempReleaseHallScreen();
			addGamingScreen();
			Data.getInstance().updateMyselfInArr(usersInfoList);
			gamingScreen.updateMsgsUserData(usersInfoList);
			if(Data.getInstance().player.state == UserData.USER_WATCH){
				DebugConsole.addDebugLog(stage, "玩家本人以观察者身份进入，进入观看状态...");
				gamingScreen.initWatcherView(usersInfoList);
			}
			DebugConsole.addDebugLog(stage, "玩家本人选择了 " + Data.getInstance().player.chairId + " 板凳...");
		}
		
		private var gamingScreen:GamingScreen;
		private function addGamingScreen():void{
			gamingScreen = new GamingScreen();
			addChild(gamingScreen);
			this.swapChildren(gamingScreen, draw_mc);
			gamingScreen.addEventListener(CountDownEvent.TIME_UP, onTimeUpHandler);
			gamingScreen.addEventListener(UserEvent.READY_OK, onReadyOkHandler);
			gamingScreen.addEventListener(UserEvent.JIAO_Z, onJiaoZHandler);
			gamingScreen.addEventListener(UserEvent.BU_JIAO_Z, onJiaoZHandler);
			gamingScreen.addEventListener(BetEvent.BET, onBetHandler);
			gamingScreen.addEventListener(UserEvent.CONFIRM_SHOW_CARDS, onConfirmShowCardsHandler);
			gamingScreen.addEventListener(UserEvent.BACK_TO_HALL, onBackToHallHandler);
			gamingScreen.addEventListener(UserEvent.NOMAL_CHAT, onChatHandler);
			gamingScreen.addEventListener(UserEvent.FAST_CHAT, onChatHandler);
			gamingScreen.addEventListener(UserEvent.TUO_GUAN, onTuoguanHandler);
			gamingScreen.addEventListener(UserEvent.CANCEL_TUO_GUAN, onTuoguanHandler);
			SoundManager.getInstance().playSound(Resource.SND_INTO_TABLE, false);
		}
		
		private function onTuoguanHandler(event:UserEvent):void
		{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			if(event.type == UserEvent.TUO_GUAN){
				obj.tuoguan = true;	
				Data.getInstance().player.isTuoguan = true;
			}else if(event.type == UserEvent.CANCEL_TUO_GUAN){
				obj.tuoguan = false;
				Data.getInstance().player.isTuoguan = false;
			}
			
			
			CommunicateUtils.getInstance().sendMessage(socket, Command.TUO_GUAN, obj);
		}
		
		private function onChatHandler(event:UserEvent):void
		{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			if(event.type == UserEvent.NOMAL_CHAT){
				obj.message = event.data as String;
				CommunicateUtils.getInstance().sendMessage(socket, Command.NOMAL_CHAT, obj);
			}else if(event.type == UserEvent.FAST_CHAT){
				obj.messageId = event.data as int;
				CommunicateUtils.getInstance().sendMessage(socket, Command.FAST_REPLY, obj);
			}
		}
		
		private function onBackToHallHandler(event:UserEvent):void
		{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			CommunicateUtils.getInstance().sendMessage(socket, Command.BACK_TO_HALL, obj);
			DebugConsole.addDebugLog(stage, "向服务器发送返回大厅请求...");
		}		
		
		private function onReadyOkHandler(e:UserEvent):void{
			DebugConsole.addDebugLog(stage, "玩家本人准备OK...");
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			CommunicateUtils.getInstance().sendMessage(socket, Command.PLAYER_GAME_READY, obj);
		}
		
		private function onConfirmShowCardsHandler(event:UserEvent):void
		{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			obj.cards = event.data as Array;
			obj.manualLength = gamingScreen.manualSelectCards.length;
			obj.timeUp = false;
			CommunicateUtils.getInstance().sendMessage(socket, Command.START_SHOWCARDS, obj);
			DebugConsole.addDebugLog(stage, "玩家自己已经确定牌，向服务器发送亮牌数据....");
		}
		
		private function onBetHandler(e:BetEvent):void{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.chairId = Data.getInstance().player.chairId;			
			obj.pid = Data.getInstance().player.pid;
			obj.betCoin = e.betCoin;
			gamingScreen.myMessageBox.hideCountDownAnime();
			gamingScreen.removeRatioBoxes();
			gamingScreen.switchGameState(GameState.SHOW_PLAYERS_BETCOIN, obj);
			CommunicateUtils.getInstance().sendMessage(socket, Command.PLAYER_GAME_BET, obj);
		}
		
		private function onJiaoZHandler(e:UserEvent):void{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			if(e.type == UserEvent.JIAO_Z)
				obj.hasCall = true;
			else if(e.type == UserEvent.BU_JIAO_Z)
				obj.hasCall = false;
			CommunicateUtils.getInstance().sendMessage(socket, Command.PLAYER_JIAO_Z, obj);
		}
		
		
		private function onTimeUpHandler(e:CountDownEvent):void{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			switch(e.countDownType){
				case UserData.USER_WAIT_FOR_READY:
					DebugConsole.addDebugLog(stage, "玩家准备状态倒计时结束...");
					CommunicateUtils.getInstance().sendMessage(socket, Command.BACK_TO_HALL, obj);
					DebugConsole.addDebugLog(stage, "UserWaitForReady--Time is up!!!");
					break;
				case UserData.USER_WAIT_BET:
					DebugConsole.addDebugLog(stage, "玩家下注状态倒计时结束...");
					obj.betCoin = Data.getInstance().player.betCoinArr[0];
					CommunicateUtils.getInstance().sendMessage(socket, Command.PLAYER_GAME_BET, obj);
					obj.chairId = Data.getInstance().player.chairId;
					gamingScreen.removeRatioBoxes();
					gamingScreen.showPlayersBetCoin(obj);
					break;
				case UserData.USER_WAIT_SHOWCARDS:
					DebugConsole.addDebugLog(stage, "玩家等待亮牌状态倒计时结束...");
					if(gamingScreen.manualSelectCards.length >  0){//玩家手动选择了牌
						obj.cards = gamingScreen.getManualCardsToSever();
						gamingScreen.showDecisionCards(1, gamingScreen.manualSelectCards); 
						obj.manualLength = gamingScreen.manualSelectCards.length;
					}else{
						obj.cards = Data.getInstance().player.cards;
						gamingScreen.showDecisionCards(2);
						obj.manualLength = 0;
					}
					obj.timeUp = true;
					CommunicateUtils.getInstance().sendMessage(socket, Command.START_SHOWCARDS, obj);
					break;
				case UserData.USER_JIAO_Z:
					DebugConsole.addDebugLog(stage, "玩家叫庄状态倒计时结束...");
					obj.hasCall = false;
					gamingScreen.removeRatioBoxes();
					CommunicateUtils.getInstance().sendMessage(socket, Command.PLAYER_JIAO_Z, obj);
					gamingScreen.hideJiaoZButton();
					break;
			}
		}
		
		private function clearGamingScreen():void{
			removeChild(gamingScreen);
			gamingScreen.removeEventListener(CountDownEvent.TIME_UP, onTimeUpHandler);
			gamingScreen.removeEventListener(UserEvent.READY_OK, onReadyOkHandler);
			gamingScreen.removeEventListener(UserEvent.JIAO_Z, onJiaoZHandler);
			gamingScreen.removeEventListener(UserEvent.BU_JIAO_Z, onJiaoZHandler);
			gamingScreen.removeEventListener(UserEvent.CONFIRM_SHOW_CARDS, onConfirmShowCardsHandler);
			gamingScreen.removeEventListener(UserEvent.BACK_TO_HALL, onBackToHallHandler);
			gamingScreen.removeEventListener(BetEvent.BET, onBetHandler);
			gamingScreen.removeEventListener(UserEvent.NOMAL_CHAT, onChatHandler);
			gamingScreen.removeEventListener(UserEvent.FAST_CHAT, onChatHandler);
			gamingScreen.removeEventListener(UserEvent.TUO_GUAN, onTuoguanHandler);
			gamingScreen.removeEventListener(UserEvent.CANCEL_TUO_GUAN, onTuoguanHandler);
			gamingScreen.dispose();
			gamingScreen = null;
		}
		
		private var hallScreen:HallScreen;
		private var chujiRoomTableContainer:RoomTableContainer;
		private var gaojiRoomTableContainer:RoomTableContainer;
		private function onChooseRoom(content:String):void{
			clearWelcomeScreen();
			var roomObj:Object = com.adobe.serialization.json.JSON.decode(content);
			creatRoom(roomObj);
		}
		
		private function creatRoom(roomObj:Object):void{
			Data.getInstance().player.roomId = roomObj.roomId;
			
			if(hallScreen == null){
				hallScreen = new HallScreen();
				addChild(hallScreen);
				this.swapChildren(hallScreen, draw_mc);
			}
			if(hallScreen && !hallScreen.parent){
				addChild(hallScreen);
				this.swapChildren(hallScreen, draw_mc);				
			}
			
			var roomData:RoomData = new RoomData();
			roomData.init(roomObj);
			if(Data.getInstance().player.roomId == 1){
				if(chujiRoomTableContainer)	
					chujiRoomTableContainer.setRoom(roomData);
				else 
					chujiRoomTableContainer = new RoomTableContainer(roomData);
				hallScreen.scrollPane.source = chujiRoomTableContainer;
			}else if(Data.getInstance().player.roomId == 2){
				if(gaojiRoomTableContainer)
					gaojiRoomTableContainer.setRoom(roomData);
				else
					gaojiRoomTableContainer = new RoomTableContainer(roomData);
				hallScreen.scrollPane.source = gaojiRoomTableContainer;
			}
			
			hallScreen.addEventListener(CustomEvent.BACK_TO_WELCOME, onBackToWelcomeHandler);
			hallScreen.addEventListener(RoomEvent.CHANGE_ROOM, onHallChangeRoomHandler);
			hallScreen.addEventListener(CustomEvent.CHOOSE_CHAIR, onChooseChairHandler);
		}
		
		private function onBackToWelcomeHandler(e:CustomEvent):void{
			tempReleaseHallScreen();
			addWelcomeScreen();
		}
		
		private function tempReleaseHallScreen():void{
			removeChild(hallScreen);
			hallScreen.removeEventListener(CustomEvent.BACK_TO_WELCOME, onBackToWelcomeHandler);
			hallScreen.removeEventListener(RoomEvent.CHANGE_ROOM, onHallChangeRoomHandler);
			hallScreen.removeEventListener(CustomEvent.CHOOSE_CHAIR, onChooseChairHandler);
		}
		
		private function onChooseChairHandler(e:CustomEvent):void{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			obj.tableId = e.data.tableId;
			obj.chairId = e.data.chairId;
			CommunicateUtils.getInstance().sendMessage(socket, Command.CHOOSE_CHAIR, obj);
			DebugConsole.addDebugLog(stage, "玩家本人选择板凳进入牌桌...");
		}
		
		private function onHallChooseRoom(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var roomData:RoomData = new RoomData();
			roomData.init(obj);
			//Data.getInstance().player.roomId = obj.roomId;
			
			if(roomData.roomId == 1){
				if(chujiRoomTableContainer){
					trace("更新房间1信息...");
					chujiRoomTableContainer.setRoom(roomData);
				}else{
					trace("初始化房间1信息...");
					chujiRoomTableContainer = new RoomTableContainer(roomData);
				}
				hallScreen.scrollPane.source = chujiRoomTableContainer;
			}else if(roomData.roomId == 2){
				if(gaojiRoomTableContainer){
					trace("更新房间2信息...");
					gaojiRoomTableContainer.setRoom(roomData);
				}else{
					trace("初始化房间2信息...");
					gaojiRoomTableContainer = new RoomTableContainer(roomData);
				}
				hallScreen.scrollPane.source = gaojiRoomTableContainer;
			}
		}
		
		private function onHallChangeRoomHandler(e:RoomEvent):void{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			obj.roomId = e.roomId;
			CommunicateUtils.getInstance().sendMessage(socket, Command.HALL_CHOOSE_ROOM, obj);
		}
		
		private function clearWelcomeScreen():void{
			if(welcomeScreen && welcomeScreen.parent){
				removeChild(welcomeScreen);
				welcomeScreen.removeEventListener(CustomEvent.CHOOSE_ROOM, onChooseRoomHandler);
				welcomeScreen.dispose();
				welcomeScreen = null;
			}
		}
		
		private function onLogin(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().player.avarter = obj.avarter;
			Data.getInstance().player.nickName = obj.nickName;
			Data.getInstance().player.username = obj.username;
			Data.getInstance().player.money = obj.userCoin;
			Data.getInstance().player.pid = obj.pid;
			DebugConsole.addDebugLog(stage, "用户登录成功！");
			clearLoginScreen();
			addWelcomeScreen();
		}
		
		private function clearLoginScreen():void{
			if(loginScreen && loginScreen.parent){
				removeChild(loginScreen);
				loginScreen.removeEventListener(LoginEvent.LOGIN_CONFIRM, onLoginConfirm);
				loginScreen.dispose();
				loginScreen = null;
			}
		}
		
		private var welcomeScreen:WelcomeScreen;
		private function addWelcomeScreen():void{
			welcomeScreen = new WelcomeScreen();
			addChild(welcomeScreen);
			this.swapChildren(welcomeScreen, draw_mc);
			welcomeScreen.addEventListener(CustomEvent.CHOOSE_ROOM, onChooseRoomHandler);
		}
		
		private function onChooseRoomHandler(e:CustomEvent):void{
			var obj:Object = {};
			obj.pid = Data.getInstance().player.pid;
			obj.username = Data.getInstance().player.username;
			obj.roomId = e.data.roomId;
			CommunicateUtils.getInstance().sendMessage(socket, Command.CHOOSE_ROOM, obj);
		}
		
		private function onHeartBeat(content:String):void{
			heartBeat = getTimer();
			socketConnected = true;
			reconnect = true;
		}
			
		
		private var socketConnected:Boolean = false;
		private function onSignTimer(e:TimerEvent):void{
			try{
				if(socketConnected){
					sendLoginBySign();
					releaseSignTimer();
				}
				connectServer();
				CommunicateUtils.getInstance().sendMessage(socket, Command.HEARTBEAT, "", false);
			}catch(e:Error){
				DebugConsole.addDebugLog(stage, "SignTimer发生错误...");
			}
		}
		
		private function sendLoginBySign():void{
			var obj:Object = {};
			obj.sign = this.sign;
			obj.ip = remoteIP;
			CommunicateUtils.getInstance().sendMessage(socket, Command.LOGIN_BY_SIGN, obj);
		}
		
		private function releaseSignTimer():void{
			this.sign = "undefined";
			if(signTimer){
				signTimer.removeEventListener(TimerEvent.TIMER, onSignTimer);
				signTimer.stop();
			}
		}
		
		private function onCommunicateError(event:ErrorEvent):void
		{
			DebugConsole.addDebugLog(stage, "连接服务器失败，重连中...");
			tryReconnect();
		}		
		
		
		private function loadConfig():void
		{
			configLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, onLoadConfigComplete);
			configLoader.load(new URLRequest(Const.CONFIG_URL));
		}
		
		private function onLoadConfigComplete(event:Event):void
		{
			var configXml:XML = new XML(configLoader.data);
			host = configXml.host;//主机
			port = configXml.port;//端口
			Childhood.chargeUrl = configXml.chargeUrl;//充值链接
			Childhood.playDiscriptionUrl = configXml.playDiscriptionUrl;//游戏说明按钮
			Childhood.personalCenterUrl = configXml.personalCenterUrl;
			DebugConsole.addDebugLog(stage, "host: " + host + ", port: " + port);
			//getIPUrl = configXml.getIPUrl;
//			ipLoader = new URLLoader();
//			ipLoader.addEventListener(Event.COMPLETE, onLoadIPComplete);
//			ipLoader.load(new URLRequest(getIPUrl));
			DebugConsole.addDebugLog(stage, "资源配置文件加载成功...");
			DebugConsole.addDebugLog(stage, "充值地址： " + Childhood.chargeUrl);
			connectServer();
		}
		
		private function onLoadIPComplete(e:Event):void{
			var ip:String = String(ipLoader.data);
			remoteIP = ip;
			DebugConsole.addDebugLog(stage, "RemoteIp: " + remoteIP);
		}
		
		/**重连是否成功*/
		private var reconnect:Boolean = false; 
		private var reconnectTimer:Timer;
		private var isTryingConnect:Boolean = false;
		private function tryReconnect():void{
			if(isTryingConnect)	return;
			if(reconnectTimer)	return;
			isTryingConnect = true;
			reconnect = false;
			//do sth  到登录界面
			DebugConsole.addDebugLog(stage, "重新连接中，请等待...");
			reconnectTimer = new Timer(1000);
			reconnectTimer.addEventListener(TimerEvent.TIMER, tryReconnectTimer);
			reconnectTimer.start();
		}
		
		private function onError(content:String):void{
			switch(content){
				case ErrorCode.NO_USER:
					DebugConsole.addDebugLog(stage, "错误！找不到此玩家！");
					break;
				case ErrorCode.USER_LOGINED:
					DebugConsole.addDebugLog(stage, "错误！用户已经登录！");
					break;
				case ErrorCode.USER_LOCKED:
					DebugConsole.addDebugLog(stage, "错误！帐号已被禁用！");
					break;
				case ErrorCode.USER_ON_LOGIN:
					DebugConsole.addDebugLog(stage, "Error--user on login.");
					break;
				case ErrorCode.ROOM_CANNT_FIND:
					DebugConsole.addDebugLog(stage, "Error--room cannot find.");
					break;
				case ErrorCode.ROOM_FULL:
					DebugConsole.addDebugLog(stage, "Error--room full.");
					break;
				case ErrorCode.TABLE_COIN_SHORTAGE:
					DebugConsole.addDebugLog(stage, "游戏豆不足以左下牌桌进行游戏！");
					TipPanel.getInstance().show(hallScreen, Const.MONEY_NOT_ENOUGH);
					break;
				case ErrorCode.ROOM_COIN_FULL:
					DebugConsole.addDebugLog(stage, "Error--room coin full.");
					break;
				case ErrorCode.TABLE_JOIN_ERROR:
					DebugConsole.addDebugLog(stage, "错误！进入牌桌出错！");
					break;
				case ErrorCode.NEXT_TURN_COIN_SHORTAGE:
					DebugConsole.addDebugLog(stage, "游戏豆不足以进行下轮比赛，请充值！");
					TipPanel.getInstance().show(gamingScreen, Const.MONEY_NOT_ENOUGH);
					break;
			}
		}
		
		private function tryReconnectTimer(e:TimerEvent):void{
			if(!reconnect){//重连没连上
				try{
					connectServer();
					CommunicateUtils.getInstance().sendMessage(socket,Command.HEARTBEAT,"",false);
				}catch(e:Error){}
			}else{//重连连接上
				reconnectTimer.removeEventListener(TimerEvent.TIMER,tryReconnectTimer);
				reconnectTimer.stop();
				reconnectTimer = null;
				
				var obj:Object = new Object();
				//如果存在sign登录
				var s:String = stage.loaderInfo.parameters["sign"];
				obj.sign = s;
				//obj.username = username;
				obj.ip = remoteIP;
				CommunicateUtils.getInstance().sendMessage(socket,Command.RECONNECT,obj);
			}
		}
		
		/**发送关闭命令*/
		private function sendCloseCommand():void{
			if(socket && Data.getInstance().player.username){
				var obj:Object = {};
				obj.username = Data.getInstance().player.username;
				obj.pid = Data.getInstance().player.pid;
				CommunicateUtils.getInstance().sendMessage(socket, Command.CLOSE, obj);
				trace("关闭浏览器...");
			}
		}
		
		private function updateMousefx():void{
			color.h++;
			
			var glow:GlowFilter = new GlowFilter( color.value, 1, 16, 16, 2, 3, false, false );
			draw_mc.filters = [ glow ];   
			
			var _obj:Object = new Object();
			
			if ( stage.mouseX != 0 && stage.mouseX != 0 )
			{
				_obj.x = stage.mouseX;
				_obj.y = stage.mouseY;
				dotarr.push( _obj );
			}
			if ( dotarr.length > 10 )
			{
				dotarr.splice( 0,1 );
			}
			
			var _g:Graphics = draw_mc.graphics;
			_g.clear();
			_g.lineStyle( 0, 0xff0000, 100, true, "none", "round", "round", 1 );                
			var _prevPoint:Point = null;
			var _dotLength:int = dotarr.length;     
			
			if ( _dotLength <= 0 ) return;
			
			for ( var i:int = 1; i < _dotLength; ++i )
			{        
				var _prevObj:Object = dotarr[i - 1];                                    
				var _currentObj:Object = dotarr[i];
				var a:uint = 0;
				_g.lineStyle( i / 1.2  , 0xffffff, 1, true, "none", "round", "round", 1 );   
				var _point:Point = new Point( _prevObj.x + ( _currentObj.x - _prevObj.x ) / 2, _prevObj.y + ( _currentObj.y - _prevObj.y ) / 2 );                
				
				if ( _prevPoint )
				{
					_g.moveTo( _prevPoint.x,_prevPoint.y );
					_g.curveTo( _prevObj.x,_prevObj.y,_point.x,_point.y );
				} else {
					_g.moveTo( _prevObj.x,_prevObj.y );
					_g.lineTo( _point.x,_point.y );
				}
				_prevPoint = _point;
				
			}
			
			if ( _currentObj )
			{
				_g.lineTo( _currentObj.x, _currentObj.y );
			}
		}
	}
}
