package ui
{
	import events.BetEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import utils.DebugConsole;
	import utils.ResourceUtils;
	
	/**显示下注倍率的容器*/
	public class RatioBox extends Sprite
	{
        //有大背景和小背景之分
		private var ratioBg:Bitmap;
		private var ratioTxt:TextField;
		private var ratioTF:TextFormat;
		public var ratio:int;
        //根据type来决定是使用大背景或者是小背景
        //1--->大背景
        //2--->小背景
        private var type:uint;
		public function RatioBox(ratio:int, type:uint = 1)
		{
			super();
			this.ratio = ratio;
            this.type = type;
          
			init();
		}
		
		private function init():void{
			if(this.type == 1){
				ratioBg = ResourceUtils.getBitmap(Resource.RATIO_BIG_BG);
				ratioTF = new TextFormat("Arial", 18, 0x990000, true);
			}else if(this.type == 2){
				ratioBg = ResourceUtils.getBitmap(Resource.RATIO_SMALL_BG);
				ratioTF = new TextFormat("Arial", 16, 0x990000, true);
				this.mouseChildren = false;
				this.mouseEnabled = true;
				this.buttonMode = true;
				this.addEventListener(MouseEvent.CLICK, onChooseRatio);
			}
			addChild(ratioBg);
			
			ratioTxt = new TextField();
			ratioTxt.defaultTextFormat = ratioTF;
			with(ratioTxt){
				width = ratioBg.bitmapData.width;
				height = ratioBg.bitmapData.height;
				autoSize = TextFieldAutoSize.CENTER;
				text = this.ratio.toString();
				selectable = false;
			}
			addChild(ratioTxt);
		}
		
		public function setRatio(ratio:int):void{
			this.ratio = ratio;
			ratioTxt.text = this.ratio.toString();
		}
		
		private function onChooseRatio(e:MouseEvent):void{
			dispatchEvent(new BetEvent(BetEvent.BET, this.ratio, true));
			DebugConsole.addDebugLog(stage, "您选择的下注数额为：" + this.ratio);
		}
		
		public function dispose():void{
			if(this.hasEventListener(MouseEvent.CLICK))
				this.removeEventListener(MouseEvent.CLICK, onChooseRatio);
			removeChildren();
			ratioBg.bitmapData.dispose();
			ratioBg.bitmapData = null;
			ratioBg = null;
			ratioTxt = null;
			ratioTF = null;
		}
	}
}
