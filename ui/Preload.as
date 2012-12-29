package ui
{
	import events.CustomEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	import utils.DebugConsole;
	
	public class Preload extends Sprite
	{
		[Embed(source="../res/loadingBarFrame.png")]
		private var LoadingBarFrame:Class;
		private var loadingBarFrame:Bitmap;
		[Embed(source="../res/loadingBarContent.png")]
		private var LoadingBarContent:Class;
		private var loadingBarContent:Bitmap;
		[Embed(source="../res/staticLogo.png")]
		private var NiuLogo:Class;
		private var niuLogo:Bitmap;
		private var niuStartX:Number;
		
		private var roundRectBg:Shape;
		private var maskShape:Shape;
		private var percentTxt:TextField;
		
		private var loader:Loader;
		private var loaderContext:LoaderContext;
		private var urlReq:URLRequest;
		public function Preload()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			init();
		}	
		
		private function init():void{
			roundRectBg = new Shape();
			roundRectBg.graphics.beginFill(0x444444);
			roundRectBg.graphics.drawRoundRect(275, 310, 450, 100, 30, 30);
			roundRectBg.graphics.endFill();
			addChild(roundRectBg);
			
			loadingBarFrame = new LoadingBarFrame();
			addChild(loadingBarFrame);
			loadingBarFrame.x = Const.WIDTH - loadingBarFrame.width >> 1;
			loadingBarFrame.y = (Const.HEIGHT - loadingBarFrame.height >> 1) + 40;
			
			loadingBarContent = new LoadingBarContent();
			addChild(loadingBarContent);
			loadingBarContent.x = loadingBarFrame.x + 4;
			loadingBarContent.y = loadingBarFrame.y + 3;
			
			niuLogo = new NiuLogo();
			addChild(niuLogo);
			niuLogo.x = loadingBarFrame.x - 80;
			niuLogo.y = loadingBarFrame.y - niuLogo.height + 4;
			niuStartX = niuLogo.x;
			
			percentTxt = new TextField();
			addChild(percentTxt);
			with(percentTxt){
				textColor = 0x888888;
				x = loadingBarFrame.x + 100;
				y = loadingBarFrame.y + 20;
				text = "正在加载资源，请等待    0 %"
				width = 300;
				height = 20;
			}
			
			maskShape = new Shape();
			maskShape.graphics.beginFill(0x000000);
			maskShape.graphics.drawRect(loadingBarContent.x, loadingBarContent.y, 0, 15);
			maskShape.graphics.endFill();
			addChild(maskShape);
			loadingBarContent.mask = maskShape;
			
			loader = new Loader();
			loaderContext = new LoaderContext();
			loaderContext.applicationDomain = ApplicationDomain.currentDomain;
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest(Const.RES_URL),loaderContext);
			
			DebugConsole.addDebugLog(stage, "");
		}
		
		private function onProgress(e:ProgressEvent):void{
			var percent:Number = e.bytesLoaded / e.bytesTotal;
			percentTxt.text = "正在加载资源，请等待    " + Math.round(percent * 100) + " %";
			maskShape.graphics.clear();
			maskShape.graphics.beginFill(0x000000);
			maskShape.graphics.drawRect(loadingBarContent.x, loadingBarContent.y, 356 * percent, 15);
			maskShape.graphics.endFill();
			niuLogo.x = niuStartX + 356 * percent;
		}
		
		private function onComplete(e:Event):void{
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			dispatchEvent(new CustomEvent(CustomEvent.PRELOAD_COMPLETE));
			DebugConsole.addDebugLog(stage, "资源加载完毕...");
		}
		
		public function dispose():void{
			removeChildren();
			loadingBarFrame.bitmapData.dispose();
			loadingBarContent.bitmapData.dispose();
			niuLogo.bitmapData.dispose();
			loadingBarFrame.bitmapData = null;
			loadingBarContent.bitmapData = null;
			niuLogo.bitmapData = null;
			loadingBarFrame = null;
			loadingBarContent.mask = null;
			loadingBarContent = null;
			niuLogo = null;
			roundRectBg = null;
			maskShape.graphics.clear();
			maskShape = null;
			percentTxt = null;
			loader = null;
			loaderContext = null;
		}
	}
}