package ui
{
	import events.UserEvent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import model.Data;
	import model.UserData;
	
	import utils.Childhood;
	import utils.DebugConsole;
	import utils.ResourceUtils;
	
	public class TipPanel extends Sprite
	{
		private var tipBg:Bitmap;
		private var tipTxt:TextField;
		private var tipTF:TextFormat;
		private var confirmBtn:AnimeButton;
		private var chargeBtn:AnimeButton;
		private var parentNode:DisplayObjectContainer;
		private static var _instance:TipPanel;
		public function TipPanel()
		{
			super();
			addTipBg();
			addTipTxt();
			addBtns();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			confirmBtn.addEventListener(MouseEvent.CLICK, onConfirmHandler);
			chargeBtn.addEventListener(MouseEvent.CLICK, onChargeHandler);
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			confirmBtn.removeEventListener(MouseEvent.CLICK, onConfirmHandler);
			chargeBtn.removeEventListener(MouseEvent.CLICK, onChargeHandler);
		}
		
		private function addBtns():void
		{
			confirmBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1),
				ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON2),	
				ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1), 78, 96);
			addChild(confirmBtn);
			
			chargeBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CHARGE_ON_TIP_BUTTON1),
				ResourceUtils.getBitmapData(Resource.CHARGE_ON_TIP_BUTTON2),	
				ResourceUtils.getBitmapData(Resource.CHARGE_ON_TIP_BUTTON1), 250, 96);
			addChild(chargeBtn);
		}
		
		private function onConfirmHandler(event:MouseEvent):void
		{
			if(Data.getInstance().player.state == UserData.USER_WAIT_FOR_READY){
				DebugConsole.addDebugLog(stage, "游戏豆不足，点击确定在桌子内部退到大厅...");
				dispatchEvent(new UserEvent(UserEvent.BACK_TO_HALL, null, true));
			}
			hide();
		}
		
		private function onChargeHandler(event:MouseEvent):void
		{
			if(Data.getInstance().player.state == UserData.USER_WAIT_FOR_READY){
				DebugConsole.addDebugLog(stage, "游戏豆不足，点击充值在桌子内部退到大厅...");
				dispatchEvent(new UserEvent(UserEvent.BACK_TO_HALL, null, true));
			}
			Childhood.openChargeUrl();
			hide();
		}
		
		private function addTipTxt():void
		{
			tipTxt = new TextField();
			tipTF = new TextFormat("Verdana", 18, 0xffff00, true);
			tipTF.align = TextFormatAlign.CENTER;
			tipTxt.defaultTextFormat = tipTF;
			tipTxt.x = 45;
			tipTxt.y = 36;
			tipTxt.width = 320;
			tipTxt.height = 28;
			tipTxt.wordWrap = false;
			addChild(tipTxt);
		}
		
		private function addTipBg():void
		{
			tipBg = ResourceUtils.getBitmap(Resource.TIP_BG);
			addChild(tipBg);
		}
		
		public static function getInstance():TipPanel{
			if(_instance == null)
				_instance = new TipPanel();
			return _instance;
		}
		
		public function show(parentNode:DisplayObjectContainer, message:String):void{
			if(this.parent)
				parent.removeChild(this);
			this.parentNode = parentNode;
			this.parentNode.addChild(this);
			this.x = this.parentNode.width - this.width >> 1;
			this.y = this.parentNode.height - this.height >> 1;
			tipTxt.text = message;
		}
		
		public function hide():void{
			if(this.parent)
				parent.removeChild(this);
		}
	}
}