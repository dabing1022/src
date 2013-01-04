package ui
{
	import events.UserEvent;
	
	import flash.display.Bitmap;
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
	
	public class WarnOffLine extends Sprite
	{
		private var tipBg:Bitmap;
		private var tipTxt:TextField;
		private var tipTF:TextFormat;
		private var confirmBtn:AnimeButton;
		private var chargeBtn:AnimeButton;
		private static var _instance:TipPanel;
		
		public function WarnOffLine()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			addTipBg();
			addTipTxt();
			addBtns();
			this.x = Const.WIDTH - this.width >> 1;
			this.y = Const.HEIGHT - this.height >> 1;
			confirmBtn.addEventListener(MouseEvent.CLICK, onConfirmHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onConfirmHandler(event:MouseEvent):void
		{
			dispatchEvent(new UserEvent(UserEvent.BACK_TO_WELCOME, null, true));
			hide();
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			confirmBtn.removeEventListener(MouseEvent.CLICK, onConfirmHandler);
			removeChildren();
			tipBg.bitmapData.dispose();
			confirmBtn.dispose();
			tipBg.bitmapData = null;
			tipBg = null;
			tipTxt = null;
			confirmBtn = null;
		}
		
		private function addBtns():void
		{
			confirmBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1),
					ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON2),	
					ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1), 164, 96);
			addChild(confirmBtn);
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
			tipTxt.text = "您的网络出现异常断开，尝试重连中...";
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
		
		public function hide():void{
			if(this.parent)
				parent.removeChild(this);
		}
	}
}