package ui
{
	import events.CustomEvent;
	import events.LoginEvent;
	
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import model.UserData;
	
	import utils.ResourceUtils;
	
	public class LoginScreen extends Sprite
	{
		private var bg:Shape;
		private var userNameTxt:TextField;
		private var passWordTxt:TextField;
		private var platformIdTxt:TextField;
		private var userNameInput:TextField;
		private var passWordInput:TextField;
		private var platformIdTxtInput:TextField;
		private var confirmBtn:AnimeButton;
		public function LoginScreen()
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
			bg = new Shape();
			bg.graphics.beginFill(0x777777);
			bg.graphics.drawRect(0, 0, Const.WIDTH, Const.HEIGHT);
			bg.graphics.endFill();
			addChild(bg);
			
			userNameTxt = new TextField();
			userNameTxt.text = "帐户: ";
			addChild(userNameTxt);
			userNameTxt.x = 200;
			userNameTxt.y = 300;
			
			userNameInput = new TextField();
			with(userNameInput){
				x = 250;
				y = 300;
				border = true;
				width = 100;
				height = 20;
				type = TextFieldType.INPUT;
			}
			addChild(userNameInput);
			
			passWordTxt = new TextField();
			passWordTxt.text = "密码: ";
			addChild(passWordTxt);
			passWordTxt.x = 200;
			passWordTxt.y = 330;
			
			passWordInput = new TextField();
			with(passWordInput){
				x = 250;
				y = 330;
				border = true;
				width = 100;
				height = 20;
				type = TextFieldType.INPUT;
				displayAsPassword = true;
			}
			addChild(passWordInput);
			
			platformIdTxt = new TextField();
			platformIdTxt.text = "平台: ";
			addChild(platformIdTxt);
			platformIdTxt.x = 200;
			platformIdTxt.y = 360;
			
			platformIdTxtInput = new TextField();
			with(platformIdTxtInput){
				x = 250;
				y = 360;
				border = true;
				width = 100;
				height = 20;
				type = TextFieldType.INPUT;
			}
			addChild(platformIdTxtInput);
			
			confirmBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.LOGIN_BUTTON1), 
										 ResourceUtils.getBitmapData(Resource.LOGIN_BUTTON2),
										 ResourceUtils.getBitmapData(Resource.LOGIN_BUTTON3));
			addChild(confirmBtn);
			confirmBtn.x = 230;
			confirmBtn.y = 390;
			confirmBtn.focusRect = false;
			confirmBtn.addEventListener(MouseEvent.CLICK, onConfirm);
		}
		
		private function onConfirm(e:MouseEvent):void{
			var userData:Object = {};
			userData.username = userNameInput.text;
			userData.password = passWordInput.text;
			userData.platformId = platformIdTxtInput.text;
			dispatchEvent(new LoginEvent(LoginEvent.LOGIN_CONFIRM, userData));
		}
		
		public function dispose():void{
			removeChildren();
			bg.graphics.clear();
			userNameTxt = null;
			userNameInput = null;
			passWordTxt = null;
			passWordInput = null;
			platformIdTxt = null;
			platformIdTxtInput = null;
			
			confirmBtn.removeEventListener(MouseEvent.CLICK, onConfirm);
			confirmBtn.dispose();
		}
	}
}