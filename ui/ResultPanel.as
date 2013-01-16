package ui
{
	import events.UserEvent;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import model.Data;
	
	import utils.ResourceUtils;
	
	public class ResultPanel extends Sprite
	{
		private var _bg:Bitmap;
		private var _nextRoundBtn:AnimeButton;
		private var _cancelBtn:AnimeButton;
		private var _isZAnime:MovieClip;
		private var _resultData:Array;
		private var _realPlayersList:Array;
		private static var _instance:ResultPanel;
		private var resultList:Vector.<ResultItem>;
		private var headItem:ResultItem;
		private var showTimer:Timer;
		private var oldTime:int = getTimer();
		public function ResultPanel(resultData:Array)
		{
			super();
			_resultData = resultData;
			resultList = new Vector.<ResultItem>();
			_realPlayersList = new Array();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_bg = ResourceUtils.getBitmap(Resource.RESULT_PANEL_BG);
			addChild(_bg);
			
			addHeadItem();
			addResultItems();
			
			_nextRoundBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.NEXT_ROUND_BUTTON1),
				ResourceUtils.getBitmapData(Resource.NEXT_ROUND_BUTTON2),
				ResourceUtils.getBitmapData(Resource.NEXT_ROUND_BUTTON1), 54, 284);
			addChild(_nextRoundBtn);
			
			_cancelBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CANCEL_BUTTON1),
				ResourceUtils.getBitmapData(Resource.CANCEL_BUTTON2),
				ResourceUtils.getBitmapData(Resource.CANCEL_BUTTON1), 204, 284);
			addChild(_cancelBtn);
			
			_nextRoundBtn.addEventListener(MouseEvent.CLICK, onNextRound);
			_cancelBtn.addEventListener(MouseEvent.CLICK, onCancelBtn);
			
			showTimer = new Timer(1000 / 30);
			showTimer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			showTimer.start();
		}
		
		private function onTimerHandler(e:TimerEvent):void{
			var tempTime:int = getTimer();
			if(tempTime - oldTime >= 5000 && this.parent){
				this.parent.removeChild(this);
				this.dispose();
			}
		}
		
		private function addHeadItem():void{
			headItem = new ResultItem();
			addChild(headItem);
			headItem.x = 30;
			headItem.y = 70;
		}
		
		private function addResultItems():void{
			//resultData 包含了在桌子上所有玩家的数据，包括观看者，在显示结果的时候需要将观看者的数据排除
			//排除依据：观看者的winCoin为0
			var resultItem:ResultItem;
			var posIdArr:Array = [];
			var i:int, chairId:int, posId:int;
			var userObj:Object;
			for(i = 0; i < _resultData.length; i++){
				if(_resultData[i].winCoin != 0)
					_realPlayersList.push(_resultData[i]);
			}
			
			for(i = 0; i < _realPlayersList.length; i++){
				//将结果数据中的用户的板凳id转化为位置id，然后放入数组posIdArr
				userObj = _realPlayersList[i];
				chairId = userObj.chairId;
				posId =  ((chairId + 8 - Data.getInstance().player.chairId) + 3) % 8;
				posIdArr[i] = posId;
			}
			
			var tempArr:Array = new Array();
			for(i = 0; i < _realPlayersList.length; i++){
				if(posIdArr[i] == 3){
					tempArr = _realPlayersList.splice(i);
					break;
				}
			}
			_realPlayersList = tempArr.concat(_realPlayersList);
			
			for(i = 0; i < _realPlayersList.length; i++){
				userObj = _realPlayersList[i];
				resultItem = new ResultItem(userObj.nickName, userObj.cardsSize.toString(), userObj.winCoin, userObj.makers);
				addChild(resultItem);
				resultItem.x = headItem.x;
				resultItem.y = headItem.y + 22 * (i + 1);
			}
		}
		
		private function onNextRound(e:MouseEvent):void{
			dispatchEvent(new UserEvent(UserEvent.READY_OK, true));
			if(this.parent){
				this.parent.removeChild(this);
				this.dispose();
			}
		}
		
		private function onCancelBtn(e:MouseEvent):void{
			if(this.parent){
				this.parent.removeChild(this);
				this.dispose();
			}
		}
		
		public function dispose():void{
			removeChildren();
			showTimer.stop();
			_nextRoundBtn.removeEventListener(MouseEvent.CLICK, onNextRound);
			_cancelBtn.removeEventListener(MouseEvent.CLICK, onCancelBtn);
			showTimer.removeEventListener(TimerEvent.TIMER, onTimerHandler);
			_nextRoundBtn.dispose();
			_cancelBtn.dispose();
			_bg.bitmapData = null;
			showTimer = null;
			_bg = null;
			_nextRoundBtn = null;
			_cancelBtn = null;
		}
	}
}