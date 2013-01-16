package ui
{
	import events.UserEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import model.Data;
	import model.UserData;
	
	import utils.Childhood;
	import utils.ResourceUtils;
	
	/**
	 * <li>包括玩家头像、昵称、帐号、游戏豆等信息</li>
	 * <li>个人中心、充值链接</li>
	 * */
	public class AvatarInfo extends Sprite
	{
		private var avatarBoxBg:Bitmap;
		private var nickNameTxt:TextField;
		private var userNameTxt:TextField;
		private var moneyTxtStatic:TextField;
		private var moneyTxtDynamic:TextField;
		private var avatarTxtBg:Bitmap;
		private var avatar:Bitmap;
		private var player:UserData;
		
		/**个人中心按钮链接*/
		private var personalCenterBtn:AnimeButton;
		/**充值链接*/
		private var chargeBtn:AnimeButton;
		private static var _instance:AvatarInfo;
		public function AvatarInfo()
		{
			super();
			player = Data.getInstance().player;
			player.addEventListener(UserEvent.MONEY_CHANGE, updateMoney);
			addAvatarBox();
            //个人中心链接、充值链接
			addLinkButtons();
			addChild(MessageTip.getInstance());
		}
		
		public static function getInstance():AvatarInfo{
			if(_instance == null){
				_instance = new AvatarInfo();
			}
			return _instance;
		}
		
		private function addAvatarBox():void{
			avatarTxtBg = ResourceUtils.getBitmap(Resource.AVATAR_TXT_BG);
			addChild(avatarTxtBg);
			
			avatarBoxBg = ResourceUtils.getBitmap(Resource.AVATAR_BOX_BG);
			addChild(avatarBoxBg);
			
			avatar = ResourceUtils.getBitmap(player.avarter);
			addChild(avatar);
			avatar.x = 10;
			avatar.y = 10;
			
			nickNameTxt = new TextField();
			addChild(nickNameTxt);
			with(nickNameTxt){
				x = 70;
				y = 5;
				width = 300;
				height = 30;
				textColor = 0xffffff;
				type = TextFieldType.DYNAMIC;
				text = player.nickName;
			}
			
			userNameTxt = new TextField();
			addChild(userNameTxt);
			with(userNameTxt){
				x = 70;
				y = 22;
				width = 130;
				height = 30;
				textColor = 0xffffff;
				type = TextFieldType.DYNAMIC;
				text = "( " + player.username + " )";
			}
			
			moneyTxtStatic = new TextField();
			addChild(moneyTxtStatic);
			with(moneyTxtStatic){
				x = 70;
				y = 40;
				width = 50;
				height = 30;
				textColor = 0xffffff;
				text = "游戏豆: ";
			}
			
			moneyTxtDynamic = new TextField();
			addChild(moneyTxtDynamic);
			with(moneyTxtDynamic){
				x = 120;
				y = 40;
				width = 100;
				height = 30;
				textColor = 0xffff00;
				type = TextFieldType.DYNAMIC;
				text = player.money;
			}
		}
		
		private function addLinkButtons():void{
			personalCenterBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.PERSONAL_CENTER_BUTTON),
												ResourceUtils.getBitmapData(Resource.PERSONAL_CENTER_BUTTON),
												ResourceUtils.getBitmapData(Resource.PERSONAL_CENTER_BUTTON));
			addChild(personalCenterBtn);
			personalCenterBtn.x = 144;
			personalCenterBtn.y = 22;
			personalCenterBtn.focusRect = false;
			
			chargeBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CHARGE_BUTTON), 
										ResourceUtils.getBitmapData(Resource.CHARGE_BUTTON), 
										ResourceUtils.getBitmapData(Resource.CHARGE_BUTTON));
			addChild(chargeBtn);
			chargeBtn.x = 172;
			chargeBtn.y = 22;
			chargeBtn.focusRect = false;
			
			MessageTip.getInstance().register(personalCenterBtn, "保险箱");
			MessageTip.getInstance().register(chargeBtn, "游戏豆充值");
			personalCenterBtn.addEventListener(MouseEvent.CLICK, onPersonalCenter);
			chargeBtn.addEventListener(MouseEvent.CLICK, onChargeMoney);
		}
		
		private function onChargeMoney(event:MouseEvent):void{
			Childhood.openChargeUrl();
		}
		
		private function onPersonalCenter(event:MouseEvent):void{
			Childhood.openPersonalCenterUrl();
		}
		
		private function updateMoney(e:UserEvent):void{
			moneyTxtDynamic.text = e.data.money;
		}
	}
}
