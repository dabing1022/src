package ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import utils.Childhood;
	
	/**
	 * 简单的提示信息，用于说明资源的加载情况等
	 * */
	public class SimpleTip extends Sprite
	{
		private var bigBg:Shape;
		private var bg:Shape;
		private var tipTxt:TextField;
		private var tipTF:TextFormat;
		private var _parent:DisplayObjectContainer;
		private static var _instance:SimpleTip;
		public function SimpleTip()
		{
			super();
			
			bigBg = new Shape();
			bigBg.graphics.beginFill(0x111111, 0.02);
			bigBg.graphics.drawRect(0, 0, Const.WIDTH, Const.HEIGHT);
			bigBg.graphics.endFill();
			addChild(bigBg);
			
			bg = new Shape();
			bg.graphics.beginFill(0x72211b);
			bg.graphics.drawRoundRect(300, 290, 400, 100, 20, 20);
			bg.graphics.endFill();
			addChild(bg);
			
			tipTxt = new TextField();
			tipTF = new TextFormat("Verdana", 18, 0xfff7e6, true);
			with(tipTxt){
				x = 300 + 10;
				y = 290 + 30;
				width = 370;
				height = 56;
				wordWrap = false;
				autoSize = TextFieldAutoSize.CENTER;
			}
			addChild(tipTxt);
			tipTxt.defaultTextFormat = tipTF;
		}
		
		public function showTip(parent:DisplayObjectContainer, tip:String):void{
			if(parent.contains(this))
				parent.removeChild(this);
	        _parent = parent;
			tipTxt.text = tip;
			_parent.addChild(this);
		}
		
		public function hide():void{
			if(this.parent)
				_parent.removeChild(this);
		}
		
		public static function getInstance():SimpleTip{
			if(_instance == null)
				_instance = new SimpleTip();
			return _instance;
		}
	}
}