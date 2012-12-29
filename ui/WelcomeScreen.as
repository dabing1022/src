package ui
{
	import events.CustomEvent;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import utils.Childhood;
	import utils.DebugConsole;
	import utils.ResourceUtils;

	/**
	 * 欢迎界面
	 * 包括用户头像、充值、初级场、高级场等
	 * */
	public class WelcomeScreen extends Sprite
	{
		private var bg:Shape;
		private var avatarInfo:AvatarInfo;
		private var welcomeBg:Bitmap;
		private var animeLogo:MovieClip;
		private var chujiRoomBtn:AnimeButton;
		private var gaojiRoomBtn:AnimeButton;
		private var roomDiscription:RoomDiscription;
		private var addRepoBtn:AnimeButton;
		private var chargeBtn:AnimeButton;
		public function WelcomeScreen()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
		}
		
		private function init():void{
			addBg();
			welcomeBg = ResourceUtils.getBitmap(Resource.WELCOME_BG);
			addChild(welcomeBg);
			
			avatarInfo = AvatarInfo.getInstance();
			addChild(avatarInfo);
			
			animeLogo = ResourceUtils.getMovieClip(Resource.ANIME_LOGO);
			animeLogo.cacheAsBitmap = true;
			animeLogo.mouseEnabled = false;
			animeLogo.mouseChildren = false;
			addChild(animeLogo);
			animeLogo.x = 500;
			animeLogo.y = 360;
			
			chujiRoomBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CHUJI_ROOM_BUTTON1), 
				ResourceUtils.getBitmapData(Resource.CHUJI_ROOM_BUTTON2),
				ResourceUtils.getBitmapData(Resource.CHUJI_ROOM_BUTTON1));
			addChild(chujiRoomBtn);
			chujiRoomBtn.x = 224;
			chujiRoomBtn.y = 500;
			
			gaojiRoomBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.GAOJI_ROOM_BUTTON1),
				ResourceUtils.getBitmapData(Resource.GAOJI_ROOM_BUTTON2),
				ResourceUtils.getBitmapData(Resource.GAOJI_ROOM_BUTTON1));
			addChild(gaojiRoomBtn);
			gaojiRoomBtn.x = 556;
			gaojiRoomBtn.y = 500;
			
			roomDiscription = new RoomDiscription(chujiRoomBtn, 1);
			addChild(roomDiscription);
			roomDiscription.visible = false;
			
			//游戏充值
			chargeBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CHARGE_MONEY_BUTTON1),
										ResourceUtils.getBitmapData(Resource.CHARGE_MONEY_BUTTON2),
										ResourceUtils.getBitmapData(Resource.CHARGE_MONEY_BUTTON1));
			addChild(chargeBtn);
			chargeBtn.x = 690;
			chargeBtn.y = 8;
			
			//加入收藏
			addRepoBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.ADD_REPO_BUTTON1),
									     ResourceUtils.getBitmapData(Resource.ADD_REPO_BUTTON2),
				                         ResourceUtils.getBitmapData(Resource.ADD_REPO_BUTTON1));
			addChild(addRepoBtn);
			addRepoBtn.x = 820;
			addRepoBtn.y = 8;
			addEventListeners();
		}
		
		private function addBg():void{
			bg = new Shape();
			bg.graphics.beginFill(0x660000);
			bg.graphics.drawRect(0, 0, Const.WIDTH, Const.HEIGHT);
			bg.graphics.endFill();
			addChild(bg);
		}
		
		private function addEventListeners():void{
			chujiRoomBtn.addEventListener(MouseEvent.CLICK, onChooseRoom);
			gaojiRoomBtn.addEventListener(MouseEvent.CLICK, onChooseRoom);
			chujiRoomBtn.addEventListener(MouseEvent.MOUSE_OVER, showDiscription);
			gaojiRoomBtn.addEventListener(MouseEvent.MOUSE_OVER, showDiscription);
			chujiRoomBtn.addEventListener(MouseEvent.MOUSE_OUT, hideDiscription);
			gaojiRoomBtn.addEventListener(MouseEvent.MOUSE_OUT, hideDiscription);
			chargeBtn.addEventListener(MouseEvent.CLICK, onChargeMoney);
			addRepoBtn.addEventListener(MouseEvent.CLICK, onAddRepo);
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
		
		private function onChooseRoom(e:MouseEvent):void{
			var obj:Object = {};
			if(e.target == chujiRoomBtn){
				obj.roomId = 1;
				dispatchEvent(new CustomEvent(CustomEvent.CHOOSE_ROOM, obj));
				DebugConsole.addDebugLog(stage, "玩家在欢迎界面中选择了初级场进入...");
			}
			else if(e.target == gaojiRoomBtn){
				obj.roomId = 2;
				dispatchEvent(new CustomEvent(CustomEvent.CHOOSE_ROOM, obj));
				DebugConsole.addDebugLog(stage, "玩家在欢迎界面中选择了高级场进入...");
			}
		}
		
		private function showDiscription(e:MouseEvent):void{
			if(e.target == chujiRoomBtn){
				roomDiscription.bindRoom(chujiRoomBtn, 1);
				roomDiscription.visible = true;
			}
			else if(e.target == gaojiRoomBtn){
				roomDiscription.bindRoom(gaojiRoomBtn, 2);
				roomDiscription.visible = true;
			}
		}
		
		private function hideDiscription(e:MouseEvent):void{
			roomDiscription.visible = false;
		}
		
		public function dispose():void{
			removeChildren();
			bg.graphics.clear();
			welcomeBg.bitmapData.dispose();
			welcomeBg.bitmapData = null;
			welcomeBg = null;
			
			animeLogo.stop();
			animeLogo = null;
			
			chujiRoomBtn.removeEventListener(MouseEvent.CLICK, onChooseRoom);
			gaojiRoomBtn.removeEventListener(MouseEvent.CLICK, onChooseRoom);
			chujiRoomBtn.removeEventListener(MouseEvent.MOUSE_OVER, showDiscription);
			gaojiRoomBtn.removeEventListener(MouseEvent.MOUSE_OVER, showDiscription);
			chujiRoomBtn.removeEventListener(MouseEvent.MOUSE_OUT, hideDiscription);
			gaojiRoomBtn.removeEventListener(MouseEvent.MOUSE_OUT, hideDiscription);
			chargeBtn.removeEventListener(MouseEvent.CLICK, onChargeMoney);
			addRepoBtn.removeEventListener(MouseEvent.CLICK, onAddRepo);
			chujiRoomBtn.dispose();
			gaojiRoomBtn.dispose();
			chargeBtn.dispose();
			addRepoBtn.dispose();
			chujiRoomBtn = null;
			gaojiRoomBtn = null;
			chargeBtn = null;
			addRepoBtn = null;
			
			roomDiscription.dispose();
			roomDiscription = null;
		}
	}
}