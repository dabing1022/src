package ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class PureTxtTip extends Sprite
	{
		private var bg:Shape;
		private var tipTxt:TextField;
		private var tf:TextFormat;
		private var tip:String = "";
		private static var _instance:PureTxtTip;
		private var parentNode:DisplayObjectContainer;
		public function PureTxtTip()
		{
			super();
			addBg();
			addTipTxt();
		}
		
		private function addBg():void{
			bg = new Shape();
			bg.graphics.beginFill(0x4d4d4d);
			bg.graphics.drawRoundRect(0, 0, 450, 100, 30, 30);
			bg.graphics.endFill();
			addChild(bg);
		}
		
		private function addTipTxt():void{
			tipTxt = new TextField();
			tf = new TextFormat("Verdana", 18, 0xcccccc);
			tf.align = TextFormatAlign.CENTER;
			addChild(tipTxt);
			with(tipTxt){
			    x = 0;
				y = 30;
				width = 450;
				height = 30;
				text = tip;
			}
			tipTxt.defaultTextFormat = tf;
		}
		
		public static function getInstance():PureTxtTip{
			if(_instance == null)
				_instance = new PureTxtTip();
			return _instance;
		}
		
		public function show(parent:DisplayObjectContainer, tip:String):void{
			this.parentNode = parent;
			if(this.parent)
				this.parent.removeChild(this);
			this.parentNode = parent;
			this.parentNode.addChild(this);
			this.x = this.parentNode.width - this.width >> 1;
			this.y = this.parentNode.height - this.height >> 1;
			tipTxt.text = tip;
		}
		
		public function hide():void{
			if(this.parent){
				this.parent.removeChild(this);
			}
		}
	}
}