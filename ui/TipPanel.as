package ui
{
	import events.UserEvent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
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
		private var bg:Shape;
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
			addBg();
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
		
		private function addBg():void
		{
			bg = new Shape();
			bg.graphics.beginFill(0x888888, 0.2);
			bg.graphics.drawRect(0, 0, Const.WIDTH, Const.HEIGHT);
			bg.graphics.endFill();
			addChild(bg);
		}
		
		private function addBtns():void
		{
			confirmBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1),
										 ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON2),	
									     ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1));
			addChild(confirmBtn);
			confirmBtn.x = tipBg.x + 78;
			confirmBtn.y = tipBg.y + 96;
			
			chargeBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CHARGE_ON_TIP_BUTTON1),
										 ResourceUtils.getBitmapData(Resource.CHARGE_ON_TIP_BUTTON2),	
										 ResourceUtils.getBitmapData(Resource.CHARGE_ON_TIP_BUTTON1));
			addChild(chargeBtn);
			chargeBtn.x = tipBg.x + 250;
			chargeBtn.y = tipBg.y + 96;
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
			tipTxt.x = tipBg.x + 10;
			tipTxt.y = tipBg.y + 36;
			tipTxt.width = tipBg.bitmapData.width;
			tipTxt.height = 28;
			tipTxt.wordWrap = false;
			addChild(tipTxt);
		}
		
		private function addTipBg():void
		{
			tipBg = ResourceUtils.getBitmap(Resource.TIP_BG);
			addChild(tipBg);
			tipBg.x = Const.WIDTH - tipBg.bitmapData.width >> 1;
			tipBg.y = Const.HEIGHT - tipBg.bitmapData.height >> 1;
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
			tipTxt.text = message;
		}
		
		public function hide():void{
			if(this.parent)
				parent.removeChild(this);
		}
	}
}