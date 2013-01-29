package
{
	import events.CustomEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import ui.Preload;
	import ui.SimpleTip;

	[SWF(width="1000", height="680", frameRate="30", backgroundColor=0x222222)]
	public class Niuniu extends Sprite
	{
		private var preLoad:Preload;
		private var coreGame:CoreGame;
		private const VERSION:String = "欢乐斗牛内测版2013/01/29/10/56(调试开启)";
		public function Niuniu()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			showRightClickMenu();
			preLoad = new Preload();
			addChild(preLoad);
			preLoad.addEventListener(CustomEvent.PRELOAD_COMPLETE, onPreloadComplete);
		}
		
		private function onPreloadComplete(event:CustomEvent):void
		{
			removeChild(preLoad);
			preLoad.removeEventListener(CustomEvent.PRELOAD_COMPLETE, onPreloadComplete);
			preLoad.dispose();
			preLoad = null;
			
			SimpleTip.getInstance().showTip(this, "登录中...");
			coreGame = new CoreGame();
			addChild(coreGame);
		}
		
		private function showRightClickMenu():void {
			var expandmenu:ContextMenu = new ContextMenu();
			expandmenu.hideBuiltInItems();
			var customMenu:ContextMenuItem = new ContextMenuItem("51高清娱乐", true);
			var versionMenu:ContextMenuItem = new ContextMenuItem(VERSION, true);
			expandmenu.customItems.push(customMenu);
			expandmenu.customItems.push(versionMenu);
			this.contextMenu = expandmenu;
		}
	}
}