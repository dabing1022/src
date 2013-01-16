package ui
{
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import utils.ResourceUtils;
	
	/**
	 * 登录反馈面板
	 * 1.成功
	 * 2.失败
	 * */
	public class LoginFeedBackPanel extends Sprite
	{
		public static const SUCCESS:int = 1;
		public static const FAILURE:int = 2;
		private var tipBg:Bitmap;
		private var tipTxt:TextField;
		private var tipTF:TextFormat;
		private var parentNode:DisplayObjectContainer;
		private static var _instance:LoginFeedBackPanel;
		public function LoginFeedBackPanel(type:int = 1)
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			addTipBg();
			addTipTxt();
		}
		
		private function addTipBg():void
		{
			tipBg = ResourceUtils.getBitmap(Resource.TIP_BG);
			addChild(tipBg);
			tipBg.x = Const.WIDTH - tipBg.bitmapData.width >> 1;
			tipBg.y = Const.HEIGHT - tipBg.bitmapData.height >> 1;
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
			addChild(tipTxt);
		}
		
		public static function getInstance():LoginFeedBackPanel{
			if(_instance == null)
				_instance = new LoginFeedBackPanel();
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
			
			tipBg.bitmapData.dispose();
			tipBg.bitmapData = null;
		}
	}
}