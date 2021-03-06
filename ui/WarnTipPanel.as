package ui
{
	import events.UserEvent;
	
	import flash.display.Bitmap;
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
	import utils.ResourceUtils;
	
	public class WarnTipPanel extends Sprite
	{
		private var bg:Shape;
		private var tipBg:Bitmap;
		private var tipTxt:TextField;
		private var tipTF:TextFormat;
		private var confirmBtn:AnimeButton;
		public static const OFFLINE:String = "offline";
		public static const EXCHANGE_SHORTAGE:String = "exchangeShortage";
		public static const EXCHANGE_ERROR:String = "exchangeError";
		public static const EXCHANGE_SUCCESS:String = "exchangeSuccess";
		public static const EXCHANGE_BUSY:String = "exchangeBusy";
		public static const USER_LOGINED:String = "userLogined";
		public static const RECONNECT_ERROR:String = "reconnectError";
		public static const RECONNECT_SUCCESS:String = "reconnectSuccess";
		public static const DATA_ERROR:String = "dataError";
		private var _type:String;
		public function WarnTipPanel(type:String)
		{
			super();
			_type = type;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			addBg();
			addTipBg();
			addTipTxt();
			addBtns();
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function addBg():void{
			bg = new Shape();
			bg.graphics.beginFill(0x000000, 0.2);
			bg.graphics.drawRect(0, 0, Const.WIDTH, Const.HEIGHT);
			bg.graphics.endFill();
			addChild(bg);
		}
		
		private function onConfirmHandler(event:MouseEvent):void
		{
			if(_type == OFFLINE)
				dispatchEvent(new UserEvent(UserEvent.BACK_TO_WELCOME, null, true));
			else if(_type == RECONNECT_ERROR || _type == DATA_ERROR){
				if(ExternalInterface.available){
					ExternalInterface.call("reloadHtml");
				}
			}
			hide();
		}
		
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			confirmBtn.removeEventListener(MouseEvent.CLICK, onConfirmHandler);
			
			removeChildren();
			bg.graphics.clear();
			tipBg.bitmapData.dispose();
			tipBg.bitmapData = null;
			bg = null;
			tipBg = null;
			tipTxt = null;
			tipTF = null;
			confirmBtn.dispose();
			confirmBtn = null;
		}
		
		private function addBtns():void
		{
			confirmBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1),
					ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON2),	
					ResourceUtils.getBitmapData(Resource.CONFIRM_BUTTON1), tipBg.x + 164, tipBg.y + 96);
			addChild(confirmBtn);
			confirmBtn.addEventListener(MouseEvent.CLICK, onConfirmHandler);
		}
		
		private function addTipTxt():void
		{
			tipTxt = new TextField();
			tipTF = new TextFormat("Verdana", 18, 0xffff00, true);
			tipTF.align = TextFormatAlign.CENTER;
			tipTxt.defaultTextFormat = tipTF;
			tipTxt.x = tipBg.x + 45;
			tipTxt.y = tipBg.y + 36;
			tipTxt.width = 320;
			tipTxt.height = 28;
			tipTxt.wordWrap = false;
			showTip(_type);
			
			addChild(tipTxt);
		}
		
		private function showTip(type:String):void{
			_type = type;
			switch(_type){
				case OFFLINE:
					tipTxt.text = "您的网络出现异常断开，尝试重连中...";
					break;
				case EXCHANGE_SHORTAGE:
					tipTxt.text = "兑换余额不足";
					break;
				case EXCHANGE_ERROR:
					tipTxt.text = "兑换错误，请重试！";
					break;
				case EXCHANGE_SUCCESS:
					tipTxt.text = "兑换成功！";
					break;
				case EXCHANGE_BUSY:
					tipTxt.text = "服务器忙，请重试！";
					break;
				case USER_LOGINED:
					tipTxt.text = "用户已登录！";
					break;
				case RECONNECT_ERROR:
					tipTxt.text = "重连失败，请重新登录...";
					break;
				case RECONNECT_SUCCESS:
					tipTxt.text = "重连成功！";
					break;
				case DATA_ERROR:
					tipTxt.text = "网络异常，请重新登录...";
					break;
			}
		}
		
		private function addTipBg():void
		{
			tipBg = ResourceUtils.getBitmap(Resource.TIP_BG);
			addChild(tipBg);
			tipBg.x = Const.WIDTH - tipBg.bitmapData.width >> 1;
			tipBg.y = Const.HEIGHT - tipBg.bitmapData.height >> 1;
		}
		
		private function hide():void{
			if(this.parent)
				parent.removeChild(this);
		}
	}
}