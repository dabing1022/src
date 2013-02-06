package
{
	import events.CustomEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import ui.Loading;
	import ui.Preload;
	import ui.SimpleTip;

	[SWF(width="1000", height="680", frameRate="30", backgroundColor=0x222222)]
	public class Niuniu extends Sprite
	{
		private var preLoad:Preload;
		private var coreGame:CoreGame;
		private var loadingAni:Loading;
		private const VERSION:String = "欢乐斗牛公测版1.0.3";
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
			coreGame = new CoreGame();
			
			var sign:String = this.stage.loaderInfo.parameters["sign"];
			if(sign != ""){
				if(loadingAni == null){
					loadingAni = new Loading();
					addChild(loadingAni);
				}
				
				coreGame.visible = false;
			}
			
			addChild(coreGame);
			coreGame.addEventListener(CustomEvent.CORE_GAME_LOAD_COMPLETE, onCoreGameReady);
			coreGame.addEventListener(CustomEvent.USER_LOGINED, onUserLogined);
		}
		
		private function onCoreGameReady(e:CustomEvent=null):void{
			releasePreloadAndLoadingAni();
			
			coreGame.visible = true;
			coreGame.removeEventListener(CustomEvent.CORE_GAME_LOAD_COMPLETE, onCoreGameReady);
			coreGame.removeEventListener(CustomEvent.USER_LOGINED, onUserLogined);
		}
		
		private function onUserLogined(e:CustomEvent):void{
			onCoreGameReady();
		}
		
		private function releasePreloadAndLoadingAni():void{
			removeChild(preLoad);
			preLoad.removeEventListener(CustomEvent.PRELOAD_COMPLETE, onPreloadComplete);
			preLoad.dispose();
			preLoad = null;
			
			if(loadingAni && contains(loadingAni)){
				removeChild(loadingAni);
			}
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