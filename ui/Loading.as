package ui
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	/**登录界面*/
	public class Loading extends Sprite
	{
		private var bg:Shape;
		private var loadingAni:LoadingAni;
		public function Loading()
		{
			bg = new Shape();
			bg.graphics.beginFill(0x000000, 0.02);
			bg.graphics.drawRect(0, 0, Const.WIDTH, Const.HEIGHT);
			bg.graphics.endFill();
			addChild(bg);
			
			loadingAni = new LoadingAni();
			loadingAni.play();
			loadingAni.x = 40 + (Const.WIDTH-60) >> 1;
			loadingAni.y = (Const.HEIGHT-60) >> 1;
			addChild(loadingAni);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onRemovedFromStage(e:Event):void{
			bg.graphics.clear();
			loadingAni.stop();
			removeChild(loadingAni);
			loadingAni = null;
			bg = null;
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
	}
}