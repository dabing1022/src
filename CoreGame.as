package
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	
	import events.BetEvent;
	import events.CountDownEvent;
	import events.CustomEvent;
	import events.ExchangeEvent;
	import events.LoginEvent;
	import events.RoomEvent;
	import events.UserEvent;
	
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.SimpleButton;
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
	
	import model.Data;
	import model.GameState;
	import model.LoginData;
	import model.RoomData;
	import model.UserData;
	
	import ui.ExchangePanel;
	import ui.GamingScreen;
	import ui.HallChairUnit;
	import ui.HallScreen;
	import ui.HallTableUnit;
	import ui.Loading;
	import ui.LoginScreen;
	import ui.RoomTableContainer;
	import ui.SimpleTip;
	import ui.TipPanel;
	import ui.WarnTipPanel;
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
		
		private var point2beanPanel:ExchangePanel;
		private var bean2pointPanel:ExchangePanel;
		public function CoreGame()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			SimpleTip.getInstance().hide();
			
			loadConfig();
			
			CommunicateUtils.getInstance().addEventListener(ErrorEvent.ERROR, onCommunicateError);
			
			if(ExternalInterface.available){
				ExternalInterface.addCallback("close",sendCloseCommand);
				ExternalInterface.addCallback("sendMsgByJsEnter", sendMsgByJsEnter);
			}
			startGameTimer();
			
			//用于断线处理
			this.addEventListener(UserEvent.BACK_TO_WELCOME, onBackToWelcome);
			//用于点券兑换游戏豆
			this.addEventListener(ExchangeEvent.POINT_TO_BEAN, onAskForExchangeHandler);
			//用于游戏豆兑换点券
			this.addEventListener(ExchangeEvent.BEAN_TO_POINT, onAskForExchangeHandler);
			this.addEventListener(ExchangeEvent.CONFIRM_POINT_TO_BEAN, onConfirmExchange);
			this.addEventListener(ExchangeEvent.CONFIRM_BEAN_TO_POINT, onConfirmExchange);
			this.addEventListener(ExchangeEvent.CANCEL, onCancelExchange);
		}
		
		private function sendMsgByJsEnter():void{
			if(gamingScreen && this.contains(gamingScreen)){
				gamingScreen.chatBox.sendMessage();
			}
		}
		
		private function startGameTimer():void{
			gameTimer = new Timer(1000 / 30);
			gameTimer.addEventListener(TimerEvent.TIMER, gameLoop);
			gameTimer.start();
		}
		
		private function gameLoop(e:TimerEvent):void{
			sendHeartBeat();
			if(gamingScreen && this.contains(gamingScreen))
				gamingScreen.update();
			
			if(!isTryingConnect && Data.getInstance().player.username && Data.getInstance().player.username.length > 0){//已登录
				var takeTime:int = getTimer() - heartBeat;
				if(takeTime > 30000){
					clearSocket();
					tryReconnect();
				}
			}
		}
		
		private var temp:int;
		private var temp1:int;
		private function sendHeartBeat():void{
			temp = getTimer() - temp1;
			if(socket && socket.connected && temp > 7000){
				temp1 = getTimer();
				CommunicateUtils.getInstance().sendMessage(socket, Command.HEARTBEAT, "", false);
			}
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
			loginData.password = event.userData.password;
			loginData.platform = event.userData.platformId;
			loginData.ip = remoteIP;
			CommunicateUtils.getInstance().sendMessage(socket, Command.NOMAL_LOGIN, loginData);
		}		
		
		private function login():void{
			var sign:String = this.stage.loaderInfo.parameters["sign"];
			var pid:int = this.stage.loaderInfo.parameters["pid"];
			if(sign && pid){
				DebugConsole.addDebugLog(stage, "sign=" + sign);
				LoginData.getInstance().sign = sign;
				LoginData.getInstance().pid = pid;
				connectServer();
				signTimer = new Timer(1000);
				signTimer.addEventListener(TimerEvent.TIMER, onSignTimer);
				signTimer.start();
				this.sign = sign;
			}else{
				connectServer();
				addLoginScreen();
			}
		}
		
		private function onHeartBeat(content:String):void{
			heartBeat = getTimer();
			socketConnected = true;
			reconnect = true;
			isTryingConnect = false;
		}
		
		
		private var socketConnected:Boolean = false;
		private function onSignTimer(e:TimerEvent):void{
			try{
				if(socketConnected){
					sendLoginBySign();
					releaseSignTimer();
				}
				connectServer();
				CommunicateUtils.getInstance().sendMessage(socket,Command.HEARTBEAT,"",false);
			}catch(e:Error){
				DebugConsole.addDebugLog(stage, "SignTimer发生错误...");
			}
		}
		
		private function sendLoginBySign():void{
			var obj:Object = {};
			obj.sign = this.sign;
			obj.pid = LoginData.getInstance().pid;
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
			reconnect = true;
			socketConnected = true;
			heartBeat = getTimer();
			DebugConsole.addDebugLog(stage, "连接服务器成功！");
		}
		
		/**在服务器关闭套接字连接时调度*/
		private var delayShowOfflineTipTimer:Timer;
		private function onClose(e:Event):void{
			SimpleTip.getInstance().hide();
			socketConnected = false;
			//3s后显示断线警告框
			if(delayShowOfflineTipTimer == null){
				delayShowOfflineTipTimer = new Timer(3000, 1);
				delayShowOfflineTipTimer.addEventListener(TimerEvent.TIMER, onShowWarnOffline);
				delayShowOfflineTipTimer.start(); 
			}
			
			DebugConsole.addDebugLog(stage, "Socket连接关闭！");
			tryReconnect();
		}
		
		private var warnOffLine:WarnTipPanel;
		private function onShowWarnOffline(e:TimerEvent):void{
			releaseDelayShowOfflineTimer();
			
			warnOffLine = new WarnTipPanel(WarnTipPanel.OFFLINE);
			addChild(warnOffLine);
		}
		
		private function releaseDelayShowOfflineTimer():void{
			if(delayShowOfflineTipTimer){
				delayShowOfflineTipTimer.stop();
				delayShowOfflineTipTimer.removeEventListener(TimerEvent.TIMER, onShowWarnOffline);
				delayShowOfflineTipTimer = null;
			}
		}
		
		private function removeWarnOffline():void{
			if(warnOffLine && this.contains(warnOffLine)){
				removeChild(warnOffLine);
				warnOffLine = null;
			}
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
				var warnTipPanel:WarnTipPanel = new WarnTipPanel(WarnTipPanel.DATA_ERROR);
				addChild(warnTipPanel);
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
				case Command.OFFLINE_RESUME_GAME:
					onOfflineResumeGame(content);
					break;
				case Command.OFFLINE_LOGIN:
					onOfflineLogin(content);
					break;
				case Command.POINT_TO_BEAN://点券兑换游戏豆
					onPointToBean(content);
					break;
				case Command.BEAN_TO_POINT://游戏豆兑换点券
					onBeanToPoint(content);
					break;
				case Command.CONFIRM_POINT_TO_BEAN:
					onConfirmPointToBean(content);
					break;
				case Command.CONFIRM_BEAN_TO_POINT:
					onConfirmBeanToPoint(content);
					break;
			}
		}
		
		private function onConfirmBeanToPoint(content:String):void
		{
			SimpleTip.getInstance().hide();
			hideExchangePanel();
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().player.money = obj.userCoin;
			if(gamingScreen && gamingScreen.parent){
				gamingScreen.updateMyMsgMoney(obj.userCoin);
				gamingScreen.updateGridMyMoney(obj.userCoin);
			}
			var warnTipPanel:WarnTipPanel = new WarnTipPanel(WarnTipPanel.EXCHANGE_SUCCESS);
			addChild(warnTipPanel);
		}
		
		private function onConfirmPointToBean(content:String):void
		{
			SimpleTip.getInstance().hide();
			hideExchangePanel();
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().player.money = obj.userCoin;
			if(gamingScreen && gamingScreen.parent){
				gamingScreen.updateMyMsgMoney(obj.userCoin);
				gamingScreen.updateGridMyMoney(obj.userCoin);
			}
			var warnTipPanel:WarnTipPanel = new WarnTipPanel(WarnTipPanel.EXCHANGE_SUCCESS);
			addChild(warnTipPanel);
		}
		
		private function hideExchangePanel():void{
			if(point2beanPanel && this.contains(point2beanPanel)){
				removeChild(point2beanPanel);
				point2beanPanel = null;
			}
			if(bean2pointPanel && this.contains(bean2pointPanel)){
				removeChild(bean2pointPanel);
				bean2pointPanel = null;
			}
		}
		
		private function onBeanToPoint(content:String):void{
			SimpleTip.getInstance().hide();
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var nickName:String = Data.getInstance().player.nickName;
			var pointNum:int = obj.pointNum;
			var beanNum:int = obj.beanNum;
			var rateNum:int = obj.rateNum;
			
			if(point2beanPanel && point2beanPanel.parent){
				removeChild(point2beanPanel);
				point2beanPanel = null;
			}
			if(bean2pointPanel == null){
				bean2pointPanel = new ExchangePanel(ExchangePanel.BEAN_TO_POINT, nickName, pointNum, beanNum, rateNum);
			}
			addChild(bean2pointPanel);
			bean2pointPanel.x = Const.WIDTH - bean2pointPanel.width >> 1;
			bean2pointPanel.y = Const.HEIGHT - bean2pointPanel.height >> 1;
		}
		
		private function onPointToBean(content:String):void{
			SimpleTip.getInstance().hide();
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var nickName:String = Data.getInstance().player.nickName;
			var pointNum:int = obj.pointNum;
			var beanNum:int = obj.beanNum;
			var rateNum:int = obj.rateNum;
			
			if(bean2pointPanel && bean2pointPanel.parent){
				removeChild(bean2pointPanel);
				bean2pointPanel = null;				
			}
			if(point2beanPanel == null){
				point2beanPanel = new ExchangePanel(ExchangePanel.POINT_TO_BEAN, nickName, pointNum, beanNum, rateNum);
			}
			addChild(point2beanPanel);
			point2beanPanel.x = Const.WIDTH - point2beanPanel.width >> 1;
			point2beanPanel.y = Const.HEIGHT - point2beanPanel.height >> 1;
		}
		
		private function onOfflineLogin(content:String):void{
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().player.avarter = obj.avarter;
			Data.getInstance().player.nickName = obj.nickName;
			Data.getInstance().player.username = obj.username;
			Data.getInstance().player.money = obj.userCoin;
			Data.getInstance().player.pid = obj.pid;
			isTryingConnect = false;
		}
		
		private function onOfflineResumeGame(content:String):void{
			DebugConsole.addDebugLog(stage, "~~~Command.OFFLINE_RESUME_GAME");
			removeWarnOffline();
			if(gamingScreen && this.contains(gamingScreen))
				clearGamingScreen();
			
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var usersInfoList:Array = obj as Array;
			Data.getInstance().usersInfoList2gamingPlayersList(usersInfoList);
			addGamingScreen();
			Data.getInstance().updateMyselfInArr(usersInfoList);
			gamingScreen.updateMsgsUserData(usersInfoList);
			gamingScreen.initOfflineLoginView(usersInfoList);
				
			if(Data.getInstance().player.state == UserData.USER_WATCH){
				DebugConsole.addDebugLog(stage, "玩家本人以观察者身份进入，进入观看状态...");
				gamingScreen.initWatcherView(usersInfoList);
			}
			
			DebugConsole.addDebugLog(stage, "玩家已经恢复游戏...");
			breakLine = false;
		}
		
		private function onFastReply(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.FAST_REPLY");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().chatData.addFastMessage(obj.nickName, obj.messageId);
		}
		
		private function onNomalChat(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.NOMAL_CHAT");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().chatData.addMessage(obj.nickName, obj.message);
		}
		
		private function onGameOver(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.GAME_OVER");
			DebugConsole.addDebugLog(stage, content);
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
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.START_SHOWCARDS");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().updateTablePlayers(obj as Array);
			Data.getInstance().updateMyselfInArr(obj as Array);
			gamingScreen.switchGameState(GameState.FINAL_SHOWCARDS, obj);
		}
		
		private function onWaitShowCards(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.WAIT_SHOWCARDS");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userDataArr:Array = obj as Array;
			Data.getInstance().updateTablePlayers(userDataArr);
			Data.getInstance().updateMyselfInArr(userDataArr);
			gamingScreen.updateMsgsUserData(userDataArr);
			if(Data.getInstance().player.state == UserData.USER_WATCH) return; //如果玩家自己是观看者，则不用显示提示确定按钮
			gamingScreen.switchGameState(GameState.WAIT_SHOWCARDS);
		}
		
		private function onSendCards(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.SEND_CARDS");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateTablePlayer(obj);
			Data.getInstance().updateTablePlayer(obj);
			Data.getInstance().updateMyself(obj);
			gamingScreen.updateMsgUserData(obj);
			gamingScreen.switchGameState(GameState.SEND_CARDS, userData);
		}
		
		private function onShowPlayerBetCoin(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.SHOW_PLAYER_BETCOIN");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateTablePlayer(obj);
			Data.getInstance().updateTablePlayer(obj);
			gamingScreen.updateMsgUserData(obj);
			if(userData.username != Data.getInstance().player.username)
				gamingScreen.switchGameState(GameState.SHOW_PLAYERS_BETCOIN, userData);
		}
		
		//庄家确定后，庄家等待其他玩家下注，其他玩家10s下注时间
		private function onSystemChooseZ(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.SYSTEM_CHOOSE_Z");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userDataArr:Array = obj as Array;
			Data.getInstance().updateTablePlayers(userDataArr);
			gamingScreen.updateMsgsUserData(userDataArr);
			if(Data.getInstance().player.state == UserData.USER_WATCH)	return; //如果自己是观看者，什么也不做
			Data.getInstance().updateMyselfInArr(userDataArr);
			gamingScreen.switchGameState(GameState.USER_BET);
		}
		
		private function onStartJiaoZ(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.START_JIAO_Z");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			Data.getInstance().updateMyself(obj);
			Data.getInstance().updateTablePlayer(obj);
			gamingScreen.updateMsgUserData(obj);
			gamingScreen.switchGameState(GameState.START_JIAOZ, obj);
		}
		
		private function onUpdateTablePlayer(content:String):void{
			//假如玩家在收到此命令的时候刚好返回到了大厅则不处理
			securityInHall();
			if(!gamingScreen)	return;
			
			DebugConsole.addDebugLog(stage, "~~~Command.UPDATE_TABLE_PLAYER");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateTablePlayer(obj);
			Data.getInstance().updateTablePlayer(obj);
			gamingScreen.updateMsgUserData(obj);
		}
		
		private function onBackToHall(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.BACK_TO_HALL");
			clearGamingScreen();
			SimpleTip.getInstance().showTip(this, "正在加载房间信息，请稍候...");
			var roomObj:Object = com.adobe.serialization.json.JSON.decode(content);
			creatRoom(roomObj);
			SimpleTip.getInstance().hide();
		}
		
		//当玩家从牌桌离开后通知牌桌内的其他玩家
		private function onPlayerLeaveTable(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.PLAYER_LEAVE_TABLE");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().removePlayerInList(obj);
			gamingScreen.removePlayer(userData);
		}
		
		private function onGamingAddPlayer(content:String):void{
			securityInHall();
			if(!gamingScreen)	return;
			DebugConsole.addDebugLog(stage, "~~~Command.GAMING_ADD_PLAYER");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().addNewPlayerInList(obj);
			gamingScreen.addNewPlayer(userData);
		}
		
		private function onUpdateChair(content:String):void{
			//如果恰巧收到这个命令的时候玩家进去游戏里面，则不处理
			securityInGaming();
			if(!hallScreen )		return;
			DebugConsole.addDebugLog(stage, "~~~Command.UPDATE_CHAIR");
			
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var userData:UserData = Data.getInstance().objToUserDataInUpdateChairs(obj);
			if(Data.getInstance().player.roomId == 1){
				chujiRoomTableContainer.update(userData);
			}else if(Data.getInstance().player.roomId == 2){
				gaojiRoomTableContainer.update(userData);
			}
		}
		
		private function securityInGaming():void{
			if(gamingScreen && this.contains(gamingScreen))
				return;
		}
		
		private function securityInHall():void{
			if(hallScreen && this.contains(hallScreen))
				return;
		}
		
		private function onChooseChair(content:String):void{
			DebugConsole.addDebugLog(stage, "~~~Command.CHOOSE_CHAIR");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var usersInfoList:Array = obj as Array;
			
			tempReleaseHallScreen();
			Data.getInstance().usersInfoList2gamingPlayersList(usersInfoList);
			addGamingScreen();
			
			SimpleTip.getInstance().showTip(this, "初始化玩家信息完成...");
			SimpleTip.getInstance().hide();
			
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
			gamingScreen.addEventListener(UserEvent.BACK_TO_WELCOME, onBackToWelcome);
			SoundManager.getInstance().playSound(Resource.SND_INTO_TABLE, false);
			DebugConsole.addDebugLog(stage, "玩家本人进入牌桌后的状态为：" + Data.getInstance().player.state);
		}
		
		private function onAskForExchangeHandler(event:ExchangeEvent):void
		{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			if(event.type == ExchangeEvent.POINT_TO_BEAN)
				CommunicateUtils.getInstance().sendMessage(socket, Command.POINT_TO_BEAN, obj);
			else if(event.type == ExchangeEvent.BEAN_TO_POINT)
				CommunicateUtils.getInstance().sendMessage(socket, Command.BEAN_TO_POINT, obj);
			SimpleTip.getInstance().showTip(this, "正在查询...");
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
			SimpleTip.getInstance().showTip(this, "正在返回大厅，请稍候...");
			DebugConsole.addDebugLog(stage, "向服务器发送返回大厅请求...");
		}		
		
		private function onReadyOkHandler(e:UserEvent=null):void{
			DebugConsole.addDebugLog(stage, "玩家本人准备OK...");
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			TipPanel.getInstance().hide();
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
					gamingScreen.hideGetReadyBtn();
					//为方便压力测试，本来要退出桌子回到大厅
					CommunicateUtils.getInstance().sendMessage(socket, Command.BACK_TO_HALL, obj);
					SimpleTip.getInstance().showTip(this, "正在返回大厅，请稍候...");
					//onReadyOkHandler();//压力test更改
					
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
						gamingScreen.showDecisionCards(1, gamingScreen.manualSelectCards, true); 
						obj.manualLength = gamingScreen.manualSelectCards.length;
					}else{
						obj.cards = Data.getInstance().player.cards;
						gamingScreen.showDecisionCards(2, null, true);
						obj.manualLength = 0;
					}
					obj.timeUp = true;
					gamingScreen.hideTipAndConfirmBtns();
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
			if(gamingScreen && gamingScreen.parent){
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
				gamingScreen.removeEventListener(UserEvent.BACK_TO_WELCOME, onBackToWelcome);
				gamingScreen.dispose();
				gamingScreen = null;
			}
		}
		
		//是否掉线了，正常情况默认下为没掉线false
		private var breakLine:Boolean = false;
		private function onBackToWelcome(e:UserEvent):void{
			if(hallScreen && this.contains(hallScreen))	{
				tempReleaseHallScreen();
				addWelcomeScreen();
			}else if(gamingScreen && this.contains(gamingScreen)){
				clearGamingScreen();
				addWelcomeScreen();
			}
			breakLine = true;
		}
		
		private var hallScreen:HallScreen;
		private var chujiRoomTableContainer:RoomTableContainer;
		private var gaojiRoomTableContainer:RoomTableContainer;
		private function onChooseRoom(content:String):void{
			clearWelcomeScreen();
			var roomObj:Object = com.adobe.serialization.json.JSON.decode(content);
			creatRoom(roomObj);
			SimpleTip.getInstance().hide();
			breakLine = false;
		}
		
		private function creatRoom(roomObj:Object):void{
			Data.getInstance().player.roomId = roomObj.roomId;
			
			if(hallScreen == null){
				hallScreen = new HallScreen();
				addChild(hallScreen);
			}
			if(hallScreen && !hallScreen.parent){
				addChild(hallScreen);
			}
			
			var roomData:RoomData = new RoomData();
			roomData.init(roomObj);
			if(Data.getInstance().player.roomId == 1){
				if(chujiRoomTableContainer)	
					chujiRoomTableContainer.setRoom(roomData);
				else 
					chujiRoomTableContainer = new RoomTableContainer(roomData);
				hallScreen.scrollPane.source = chujiRoomTableContainer;
				DebugConsole.addDebugLog(stage, "玩家选择了初级场进入...");
			}else if(Data.getInstance().player.roomId == 2){
				if(gaojiRoomTableContainer)
					gaojiRoomTableContainer.setRoom(roomData);
				else
					gaojiRoomTableContainer = new RoomTableContainer(roomData);
				hallScreen.scrollPane.source = gaojiRoomTableContainer;
				DebugConsole.addDebugLog(stage, "玩家选择了高级场进入...");
			}
			
			hallScreen.addEventListener(CustomEvent.BACK_TO_WELCOME, onBackToWelcomeHandler);
			hallScreen.addEventListener(RoomEvent.CHANGE_ROOM, onHallChangeRoomHandler);
			hallScreen.addEventListener(CustomEvent.CHOOSE_CHAIR, onChooseChairHandler);
			hallScreen.addEventListener(UserEvent.BACK_TO_WELCOME, onBackToWelcome);
		}
		
		private function onBackToWelcomeHandler(e:CustomEvent):void{
			tempReleaseHallScreen();
			addWelcomeScreen();
		}
		
		private function onCancelExchange(e:ExchangeEvent):void{
			SimpleTip.getInstance().hide();
			hideExchangePanel();
		}
		
		private function onChooseChairHandler(e:CustomEvent):void{
			try{
				var obj:Object = {};
				obj.username = Data.getInstance().player.username;
				obj.pid = Data.getInstance().player.pid;
				obj.tableId = e.data.tableId;
				obj.chairId = e.data.chairId;
				CommunicateUtils.getInstance().sendMessage(socket, Command.CHOOSE_CHAIR, obj);
				DebugConsole.addDebugLog(stage, "玩家本人选择板凳进入牌桌...");
				SimpleTip.getInstance().showTip(this, "正在初始化桌子内部玩家信息...");
			}catch(e:Error){
			
			}
		}
		
		private function tempReleaseHallScreen():void{
			removeChild(hallScreen);
			hallScreen.removeEventListener(CustomEvent.BACK_TO_WELCOME, onBackToWelcomeHandler);
			hallScreen.removeEventListener(RoomEvent.CHANGE_ROOM, onHallChangeRoomHandler);
			hallScreen.removeEventListener(CustomEvent.CHOOSE_CHAIR, onChooseChairHandler);
			hallScreen.removeEventListener(UserEvent.BACK_TO_WELCOME, onBackToWelcome);
		}
		
		private function onHallChooseRoom(content:String):void{
			SimpleTip.getInstance().showTip(this, "连接房间服务器成功......");
			SimpleTip.getInstance().showTip(this, "正在更新房间内数据......");
			var obj:Object = com.adobe.serialization.json.JSON.decode(content);
			var roomData:RoomData = new RoomData();
			roomData.init(obj);
			
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
			SimpleTip.getInstance().showTip(this, "房间数据更新完毕......");
			SimpleTip.getInstance().hide();
		}
		
		private function onHallChangeRoomHandler(e:RoomEvent):void{
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			obj.roomId = e.roomId;
			CommunicateUtils.getInstance().sendMessage(socket, Command.HALL_CHOOSE_ROOM, obj);
			SimpleTip.getInstance().showTip(this, "正在连接房间服务器中......");
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
			dispatchEvent(new CustomEvent(CustomEvent.CORE_GAME_LOAD_COMPLETE));
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
			welcomeScreen.addEventListener(CustomEvent.CHOOSE_ROOM, onChooseRoomHandler);
		}
		
		private function onChooseRoomHandler(e:CustomEvent):void{
			var obj:Object = {};
			obj.pid = Data.getInstance().player.pid;
			obj.username = Data.getInstance().player.username;
			obj.roomId = e.data.roomId;
			obj.nomalIn = !breakLine;  //nomalIn  true 正常进入房间  false断线重连成功后进入房间
			CommunicateUtils.getInstance().sendMessage(socket, Command.CHOOSE_ROOM, obj);
			DebugConsole.addDebugLog(stage, "玩家从欢迎界面发送选择房间命令到服务器..." + obj.nomalIn);
			SimpleTip.getInstance().showTip(this, "正在连接房间服务器中......");
		}
		
		private function onConfirmExchange(e:ExchangeEvent):void{
			SimpleTip.getInstance().showTip(this, "正在处理兑换，请稍候...");
			var obj:Object = {};
			obj.username = Data.getInstance().player.username;
			obj.pid = Data.getInstance().player.pid;
			obj.account = e.exchangeNum;
			if(gamingScreen && this.contains(gamingScreen)){
				obj.isGamingExchange = true;
			}else{
				obj.isGamingExchange = false;
			}
			if(e.type == ExchangeEvent.CONFIRM_POINT_TO_BEAN){
				CommunicateUtils.getInstance().sendMessage(socket, Command.CONFIRM_POINT_TO_BEAN, obj);
			}else if(e.type == ExchangeEvent.CONFIRM_BEAN_TO_POINT){
				CommunicateUtils.getInstance().sendMessage(socket, Command.CONFIRM_BEAN_TO_POINT, obj);
			}
		}
		
		private function onCommunicateError(event:ErrorEvent):void
		{
			DebugConsole.addDebugLog(stage, "通信出错，进行重连...");
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
			var s:String = this.stage.loaderInfo.parameters["sign"];
			var pid:String = this.stage.loaderInfo.parameters["pid"];
			var chargePid:String = "p" + pid;
			DebugConsole.addDebugLog(stage, chargePid);
			var configXml:XML = new XML(configLoader.data);
			host = configXml.host;//主机
			port = configXml.port;//端口
			Childhood.playDiscriptionUrl = configXml.playDiscriptionUrl;//游戏说明按钮
			Childhood.chargeUrl = (s != "") ? (configXml.chargeUrl.child(chargePid) + "?sign=" + s) : configXml.chargeUrl.child(chargePid);//充值链接
			//Childhood.personalCenterUrl = (s != "") ?(configXml.personalCenterUrl.child(chargePid) + "?sign=" + s) : configXml.personalCenterUrl.child(chargePid);//个人中心
			DebugConsole.addDebugLog(stage, "资源配置文件加载成功...");
			login();
		}
		
		private function onLoadIPComplete(e:Event):void{
			var ip:String = String(ipLoader.data);
			remoteIP = ip;
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
			
			clearSocket();
			
			DebugConsole.addDebugLog(stage, "重新连接中，请等待...");
			reconnectTimer = new Timer(1000);
			reconnectTimer.addEventListener(TimerEvent.TIMER, tryReconnectTimer);
			reconnectTimer.start();
		}
		
		private function clearSocket():void{
			if(socket != null){
				try{
					socket.close();
					socket.removeEventListener(Event.CONNECT, onConnect);
					socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
					socket.removeEventListener(Event.CLOSE, onClose);
					socket.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
					socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
					socket = null;
				}catch(e:Error){
					DebugConsole.addDebugLog(stage, "关闭socket出错...");
				}
			}
		}
		
		private function onError(content:String):void{
			SimpleTip.getInstance().hide();
			var warnTipPanel:WarnTipPanel;
			switch(content){
				case ErrorCode.NO_USER:
					DebugConsole.addDebugLog(stage, "错误！找不到此玩家！");
					break;
				case ErrorCode.USER_LOGINED:
					warnTipPanel = new WarnTipPanel(WarnTipPanel.USER_LOGINED);
					addChild(warnTipPanel);
					DebugConsole.addDebugLog(stage, "错误！用户已经登录！");
					dispatchEvent(new CustomEvent(CustomEvent.USER_LOGINED));
					break;
				case ErrorCode.USER_LOCKED:
					DebugConsole.addDebugLog(stage, "错误！帐号已被禁用！");
					break;
				case ErrorCode.USER_ON_LOGIN:
					DebugConsole.addDebugLog(stage, "Error--user on login.");
					warnTipPanel = new WarnTipPanel(WarnTipPanel.RECONNECT_ERROR);
					addChild(warnTipPanel);
					break;
				case ErrorCode.ROOM_CANNT_FIND:
					DebugConsole.addDebugLog(stage, "Error--room cannot find.");
					break;
				case ErrorCode.ROOM_FULL:
					DebugConsole.addDebugLog(stage, "Error--room full.");
					break;
				case ErrorCode.TABLE_COIN_SHORTAGE:
					DebugConsole.addDebugLog(stage, "游戏豆不足以坐下牌桌进行游戏！");
					TipPanel.getInstance().show(this, Const.MONEY_NOT_ENOUGH);
					break;
				case ErrorCode.TABLE_JOIN_ERROR:
					DebugConsole.addDebugLog(stage, "错误！进入牌桌出错！");
					break;
				case ErrorCode.NEXT_TURN_COIN_SHORTAGE:
					DebugConsole.addDebugLog(stage, "游戏豆不足以进行下轮比赛，请充值！");
					if(gamingScreen && this.contains(gamingScreen))
						TipPanel.getInstance().show(gamingScreen, Const.MONEY_NOT_ENOUGH);
					break;
				case ErrorCode.EXCHANGE_SHORTAGE:
					DebugConsole.addDebugLog(stage, "兑换余额不足！");
					warnTipPanel = new WarnTipPanel(WarnTipPanel.EXCHANGE_SHORTAGE);
					addChild(warnTipPanel);
					break;
				case ErrorCode.EXCHANGE_ERROR:
					DebugConsole.addDebugLog(stage, "兑换失败！");
					warnTipPanel = new WarnTipPanel(WarnTipPanel.EXCHANGE_ERROR);
					addChild(warnTipPanel);
					break;
				case ErrorCode.EXCHANGE_BUSY:
					DebugConsole.addDebugLog(stage, "服务器忙，兑换失败！");
					warnTipPanel = new WarnTipPanel(WarnTipPanel.EXCHANGE_BUSY);
					addChild(warnTipPanel);
					break;
				case ErrorCode.RECONNECT_ERROR:
					DebugConsole.addDebugLog(stage, "重连失败！");
					warnTipPanel = new WarnTipPanel(WarnTipPanel.RECONNECT_ERROR);
					addChild(warnTipPanel);
					break;
			}
		}
		
		private function tryReconnectTimer(e:TimerEvent):void{
			if(!reconnect){//重连没连上
				try{
					DebugConsole.addDebugLog(stage, "重连还没连上，重连中...");
					connectServer();
					CommunicateUtils.getInstance().sendMessage(socket,Command.HEARTBEAT,"",false);
				}catch(e:Error){}
			}else{//重连连接上
				DebugConsole.addDebugLog(stage, "重连连接上了...");
				reconnectTimer.removeEventListener(TimerEvent.TIMER,tryReconnectTimer);
				reconnectTimer.stop();
				reconnectTimer = null;
				
				releaseDelayShowOfflineTimer();
				removeWarnOffline();
				SimpleTip.getInstance().hide();
				
				var obj:Object = {};
				obj.username = Data.getInstance().player.username;
				obj.pid = Data.getInstance().player.pid;
				isTryingConnect = false;
				CommunicateUtils.getInstance().sendMessage(socket, Command.RECONNECT, obj);
				DebugConsole.addDebugLog(stage, "sendMessage-username:" + obj.username + ", pid:" + obj.pid);
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
	}
}
