package ui
{
	import events.CustomEvent;
	import events.ExchangeEvent;
	import events.RoomEvent;
	
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import model.Data;
	
	import utils.Childhood;
	import utils.DebugConsole;
	import utils.ResourceUtils;
	
	/**
	 * 大厅界面，包括用户头像，桌子等信息
	 * */
	public class HallScreen extends Sprite
	{
		private var hallMainBg:Bitmap;
		private var avatarInfo:AvatarInfo;
		
		private var chujiBtn:AnimeButton;
		private var gaojiBtn:AnimeButton;
		private var fastInChairBtn:AnimeButton;
		
		/**点券（平台金币）兑换游戏豆按钮*/
		private var point2beanBtn:AnimeButton;
		/**游戏豆兑换点券（平台金币）按钮*/
		private var bean2pointBtn:AnimeButton;
		private var addRepoBtn:AnimeButton;
		private var chargeBtn:AnimeButton;
		private var systemHelpBtn:AnimeButton;
		private var systemBackToWelcomBtn:AnimeButton;
		private var chatByQQBtn:AnimeButton;
		
		private var scrollPaneBg:Shape;
		public var scrollPane:ScrollPane;
		
		private var publicTestLogo:Bitmap;
		public function HallScreen()
		{
			super();
			hallMainBg = ResourceUtils.getBitmap(Resource.HALL_MAIN_BG);
			addChild(hallMainBg);
			
			chujiBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.HALL_CHUJI_BUTTON1),
									   ResourceUtils.getBitmapData(Resource.HALL_CHUJI_BUTTON2),
				                       ResourceUtils.getBitmapData(Resource.HALL_CHUJI_BUTTON2));
			addChild(chujiBtn);
			chujiBtn.x = 14;
			chujiBtn.y = 70;
			
			gaojiBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.HALL_GAOJI_BUTTON1),
				                       ResourceUtils.getBitmapData(Resource.HALL_GAOJI_BUTTON2),
				                       ResourceUtils.getBitmapData(Resource.HALL_GAOJI_BUTTON2));
			addChild(gaojiBtn);
			gaojiBtn.x = 130;
			gaojiBtn.y = 70;
			
			fastInChairBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.FAST_IN_CHAIR_BUTTON1),
				                             ResourceUtils.getBitmapData(Resource.FAST_IN_CHAIR_BUTTON2),
			                              	 ResourceUtils.getBitmapData(Resource.FAST_IN_CHAIR_BUTTON1));
			//addChild(fastInChairBtn);
			fastInChairBtn.x = 880;
			fastInChairBtn.y = 74;
			
			point2beanBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.POINT_TO_BEAN_BUTTON1),
				ResourceUtils.getBitmapData(Resource.POINT_TO_BEAN_BUTTON2),
				ResourceUtils.getBitmapData(Resource.POINT_TO_BEAN_BUTTON1), 530, 8);
			addChild(point2beanBtn);
			
			bean2pointBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.BEAN_TO_POINT_BUTTON1),
				ResourceUtils.getBitmapData(Resource.BEAN_TO_POINT_BUTTON2),
				ResourceUtils.getBitmapData(Resource.BEAN_TO_POINT_BUTTON1), 640, 8);
			addChild(bean2pointBtn);
			
			//游戏充值
			chargeBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CHARGE_MONEY_BUTTON1),
										ResourceUtils.getBitmapData(Resource.CHARGE_MONEY_BUTTON2),
										ResourceUtils.getBitmapData(Resource.CHARGE_MONEY_BUTTON1));
			addChild(chargeBtn);
			chargeBtn.x = 750;
			chargeBtn.y = 8;
			
			//加入收藏
			/*addRepoBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.ADD_REPO_BUTTON1),
										 ResourceUtils.getBitmapData(Resource.ADD_REPO_BUTTON2),
				                         ResourceUtils.getBitmapData(Resource.ADD_REPO_BUTTON1));
			addChild(addRepoBtn);
			addRepoBtn.x = 860;
			addRepoBtn.y = 8;*/
			
			//客服qq交谈
			chatByQQBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CHAT_BY_QQ_BUTTON1),
										  ResourceUtils.getBitmapData(Resource.CHAT_BY_QQ_BUTTON2),
				                          ResourceUtils.getBitmapData(Resource.CHAT_BY_QQ_BUTTON1));
			addChild(chatByQQBtn);
			chatByQQBtn.x = 860;
			chatByQQBtn.y = 8;
			
			addScrollPaneBg();
			addScrollPane();
			addSystemBtns();
			
			publicTestLogo = ResourceUtils.getBitmap(Resource.PUBLIC_TEST_LOGO);
			addChild(publicTestLogo);
			publicTestLogo.x = 380;
			publicTestLogo.y = 8;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void{
			avatarInfo = AvatarInfo.getInstance();
			addChild(avatarInfo);
			avatarInfo.x = 20;
			avatarInfo.y = 2;
			setRoomButtonState();
			addEventListeners();
		}
		
		private function addSystemBtns():void{
			systemHelpBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.SYSTEM_HELP),
									        ResourceUtils.getBitmapData(Resource.SYSTEM_HELP),
				                            ResourceUtils.getBitmapData(Resource.SYSTEM_HELP));
			addChild(systemHelpBtn);
			systemHelpBtn.x = 920;
			systemHelpBtn.y = 50;
			
			systemBackToWelcomBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.SYSTEM_BACK_TO_WELCOME),
				                                    ResourceUtils.getBitmapData(Resource.SYSTEM_BACK_TO_WELCOME),
				                                    ResourceUtils.getBitmapData(Resource.SYSTEM_BACK_TO_WELCOME));
			addChild(systemBackToWelcomBtn);
			systemBackToWelcomBtn.x = 950;
			systemBackToWelcomBtn.y = 50;
			
			MessageTip.getInstance().register(systemHelpBtn, "游戏玩法说明");
			MessageTip.getInstance().register(systemBackToWelcomBtn, "返回");
		}
		
		private function setRoomButtonState():void{
			if(Data.getInstance().player.roomId == 1){
				chujiBtn.upState = ResourceUtils.getBitmap(Resource.HALL_CHUJI_BUTTON2);
				gaojiBtn.upState = ResourceUtils.getBitmap(Resource.HALL_GAOJI_BUTTON1);
			}else if(Data.getInstance().player.roomId == 2){
				gaojiBtn.upState = ResourceUtils.getBitmap(Resource.HALL_GAOJI_BUTTON2);
				chujiBtn.upState = ResourceUtils.getBitmap(Resource.HALL_CHUJI_BUTTON1);
			}
		}
		
		private function onChangeRoom(e:RoomEvent):void{
			Data.getInstance().player.roomId = e.roomId;
			setRoomButtonState();
		}
		
		private function addScrollPane():void
		{
			scrollPane = new ScrollPane();
			scrollPane.x = 6;
			scrollPane.y = 102;
			scrollPane.width = 986;
			scrollPane.height = 578;
			addChild(scrollPane);
			scrollPane.verticalScrollPolicy = ScrollPolicy.AUTO;
		}
		
		private function addScrollPaneBg():void{
			scrollPaneBg = new Shape();
			scrollPaneBg.graphics.beginFill(0x666666);
			scrollPaneBg.graphics.drawRect(6, 102, 986, 578);
			scrollPaneBg.graphics.endFill();
			addChild(scrollPaneBg);
		}
		
		private function addEventListeners():void{
			chujiBtn.addEventListener(MouseEvent.CLICK, onChooseChujiRoomHandler);
			gaojiBtn.addEventListener(MouseEvent.CLICK, onChooseGaojiRoomHandler);
			
			point2beanBtn.addEventListener(MouseEvent.CLICK, onExchangeHandler);
			bean2pointBtn.addEventListener(MouseEvent.CLICK, onExchangeHandler);
			chargeBtn.addEventListener(MouseEvent.CLICK, onChargeMoney);
			//addRepoBtn.addEventListener(MouseEvent.CLICK, onAddRepo);
			chatByQQBtn.addEventListener(MouseEvent.CLICK, onChatByQQHandler);
			
			systemHelpBtn.addEventListener(MouseEvent.CLICK, onSystemHelpHandler);
			systemBackToWelcomBtn.addEventListener(MouseEvent.CLICK, onSystemBackToWelcomeHandler);
		}
		
		private function onChatByQQHandler(event:MouseEvent):void{
			Childhood.chatByQQ();
		}
		
		private function onExchangeHandler(event:MouseEvent):void
		{
			if(event.currentTarget == point2beanBtn)
				dispatchEvent(new ExchangeEvent(ExchangeEvent.POINT_TO_BEAN, 0, true));
			else if(event.currentTarget == bean2pointBtn)
				dispatchEvent(new ExchangeEvent(ExchangeEvent.BEAN_TO_POINT, 0, true));
		}
		
		private function onSystemHelpHandler(e:MouseEvent):void{
			Childhood.openPlayDiscriptionUrl();
		}
		
		private function onSystemBackToWelcomeHandler(e:MouseEvent):void{
			dispatchEvent(new CustomEvent(CustomEvent.BACK_TO_WELCOME));
		}
		
		private function onChooseChujiRoomHandler(e:MouseEvent):void{
			if(Data.getInstance().player.roomId == 2){
				dispatchEvent(new RoomEvent(RoomEvent.CHANGE_ROOM, 1));
				DebugConsole.addDebugLog(stage, "玩家在大厅中选择了初级场进入...");				
			}
			Data.getInstance().player.roomId = 1;
			setRoomButtonState();
		}
		
		private function onChooseGaojiRoomHandler(e:MouseEvent):void{
			if(Data.getInstance().player.roomId == 1){
				dispatchEvent(new RoomEvent(RoomEvent.CHANGE_ROOM, 2));
				DebugConsole.addDebugLog(stage, "玩家在大厅中选择了高级场进入...");			
			}
			Data.getInstance().player.roomId = 2;
			setRoomButtonState();
		}
		
		private function onChargeMoney(e:MouseEvent):void{
			Childhood.openChargeUrl();
			DebugConsole.addDebugLog(stage, "您打开了充值链接。");
		}
		
		private function onAddRepo(e:MouseEvent):void{
			if(ExternalInterface.available){
				DebugConsole.addDebugLog(stage, "您打开了加入收藏设置。");
				ExternalInterface.call("bookmark");
			}
		}
	}
}