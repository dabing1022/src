package ui
{
	import com.greensock.TweenLite;
	
	import events.ExchangeEvent;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import utils.ResourceUtils;
	
	/**
	 * 点券兑换游戏豆面板
	 * */
	public class ExchangePanel extends Sprite
	{
		private var bgPanel:Bitmap;
		private var cancelBtn:AnimeButton;
		private var exchangeConfirmBtn:AnimeButton;
		private var exchangeNumTxt:TextField;
		private var panelDiscriptionTxt:TextField;
		private var exchangeDiscriptionTxt:TextField;
		private var tf:TextFormat;
		
		/**玩家昵称*/
		private var _nickName:String;
		/**点券数量*/
		private var _pointNum:int;
		/**游戏豆数量*/
		private var _beanNum:int;
		/**兑换比值1:5,服务端传5给客户端*/
		private var _rateNum:Number;
		public static const POINT_TO_BEAN:int = 1;
		public static const BEAN_TO_POINT:int = 2;
		private var _type:int;
		
		private var warnBox:Sprite;
		private var warnBg:Shape;
		private var warnTxt:TextField;
		
		private var calculateBg:Shape;
		private var calculateKedui:TextField;
		private var calculateHuobi:TextField;
		private var calculateNum:TextField;
		private var timer:Timer;
		public function ExchangePanel(type:int, nickName:String, pointNum:int, beanNum:int, rateNum:Number):void
		{
			super();
			_type = type;
			_nickName = nickName;
			_pointNum = pointNum;
			_beanNum = beanNum;
			_rateNum = rateNum;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			addBgPanel();
			addText();
			addCancelBtn();
			addCalculate();
			addWarnStuff();
			addExchangeConfirmBtn();
			addEventListeners();
		}
		
		private function addCalculate():void
		{
			calculateBg = new Shape();
			calculateBg.graphics.beginFill(0xff3300, 0.3);
			calculateBg.graphics.drawRoundRect(70, 168, 172, 18, 4, 4);
			calculateBg.graphics.endFill();
			addChild(calculateBg);
			calculateBg.visible = false;
			
			calculateKedui = new TextField();
			calculateKedui.defaultTextFormat = tf;
			calculateKedui.text = "可兑";
			calculateKedui.textColor = 0xa2e700;
			addChild(calculateKedui);
			calculateKedui.x = 76;
			calculateKedui.y = 168;
			calculateKedui.visible = false;
			
			calculateHuobi = new TextField();
			calculateHuobi.defaultTextFormat = tf;
			if(_type == POINT_TO_BEAN)
				calculateHuobi.text = "游戏豆";
			else if(_type == BEAN_TO_POINT)
				calculateHuobi.text = "金币";
			calculateHuobi.textColor = 0xa2e700;
			addChild(calculateHuobi);
			calculateHuobi.x = 198;
			calculateHuobi.y = 168;
			calculateHuobi.visible = false;
			
			calculateNum = new TextField();
			calculateNum.defaultTextFormat = tf;
			addChild(calculateNum);
			calculateNum.x = 120;
			calculateNum.y = 168;
			calculateNum.width = 92;
			calculateNum.height = 20;
			calculateNum.visible = false;
		}
		
		private function addWarnStuff():void{
			warnBox = new Sprite();
			addChild(warnBox);
			warnBox.x = 182;
			warnBox.y = 108;
			warnBox.alpha = 0;
			
			warnBg = new Shape();
			warnBg.graphics.beginFill(0xff9900, 0.5);
			warnBg.graphics.drawRoundRect(0, 0, 132, 26, 5, 5);
			warnBg.graphics.endFill();
			warnBox.addChild(warnBg);
			
			warnTxt = new TextField();
			warnTxt.x = 3;
			warnTxt.y = 2;
			warnTxt.width = 136;
			warnTxt.height = 21;
			warnTxt.textColor = 0xfffffff;
			warnBox.addChild(warnTxt);
			warnBox.mouseChildren = false;
			warnBox.mouseEnabled = false;
		}
		
		private function addCancelBtn():void
		{
			cancelBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CANCEL_BUTTON1),
				ResourceUtils.getBitmapData(Resource.CANCEL_BUTTON2),
				ResourceUtils.getBitmapData(Resource.CANCEL_BUTTON1), 124, 286);
			addChild(cancelBtn);
		}
		
		private function addText():void
		{
			tf = new TextFormat("Arial", 13, 0xffcc00);
			tf.leading = 6;
			
			panelDiscriptionTxt = new TextField();
			panelDiscriptionTxt.defaultTextFormat = tf;
			panelDiscriptionTxt.x = 29;
			panelDiscriptionTxt.y = 72;
			panelDiscriptionTxt.width = 265;
			panelDiscriptionTxt.height = 80;
			panelDiscriptionTxt.type = TextFieldType.DYNAMIC;
			panelDiscriptionTxt.selectable = false;
			panelDiscriptionTxt.appendText("尊敬的：" + _nickName + "\n");
			panelDiscriptionTxt.appendText("您现有平台金币：" + _pointNum + "\n");
			panelDiscriptionTxt.appendText("您现有游戏豆：" + _beanNum + "\n");
			addChild(panelDiscriptionTxt);
			
			exchangeDiscriptionTxt = new TextField();
			exchangeDiscriptionTxt.defaultTextFormat = tf;
			exchangeDiscriptionTxt.x = 29;
			exchangeDiscriptionTxt.y = 185;
			exchangeDiscriptionTxt.width = 285;
			exchangeDiscriptionTxt.height = 20;
			exchangeDiscriptionTxt.type = TextFieldType.DYNAMIC;
			exchangeDiscriptionTxt.selectable = false;
			if(_type == POINT_TO_BEAN)
				exchangeDiscriptionTxt.appendText("兑换数量不得小于1000平台金币；兑换比1 : " + _rateNum);
			else if(_type == BEAN_TO_POINT)
				exchangeDiscriptionTxt.appendText("兑换数量不得小于1000游戏豆；兑换比" + _rateNum + " : 1");
			addChild(exchangeDiscriptionTxt);
			
			exchangeNumTxt = new TextField();
			exchangeNumTxt.textColor = 0xffffff;
			exchangeNumTxt.x = 120;
			exchangeNumTxt.y = 145;
			exchangeNumTxt.width = 108;
			exchangeNumTxt.height = 21;
			exchangeNumTxt.restrict = "0-9";
			exchangeNumTxt.maxChars = 8;
			exchangeNumTxt.type = TextFieldType.INPUT;
			addChild(exchangeNumTxt);
		}
		
		private function addExchangeConfirmBtn():void
		{
			exchangeConfirmBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.GAMING_CHARGE_CONFIRM_BUTTON1),
				ResourceUtils.getBitmapData(Resource.GAMING_CHARGE_CONFIRM_BUTTON2),
				ResourceUtils.getBitmapData(Resource.GAMING_CHARGE_CONFIRM_BUTTON1), 244, 134);
			addChild(exchangeConfirmBtn);
		}
		
		private function addBgPanel():void
		{
			if(_type == POINT_TO_BEAN){
				bgPanel = ResourceUtils.getBitmap(Resource.POINT_TO_BEAN_PANEL_BG);
			}else if(_type == BEAN_TO_POINT){
				bgPanel = ResourceUtils.getBitmap(Resource.BEAN_TO_POINT_PANEL_BG);
			}
			addChild(bgPanel);
		}		
		
		private function addEventListeners():void{
			exchangeConfirmBtn.addEventListener(MouseEvent.CLICK, onExchangeConfirm);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancelHandler);
			
			timer = new Timer(1000 / 30);
			timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			timer.start();
		}
		
		private function onTimerHandler(e:TimerEvent):void{
			if(exchangeNumTxt.text != ""){
				calculateBg.visible = calculateKedui.visible = calculateHuobi.visible = calculateNum.visible = true;
				if(_type == POINT_TO_BEAN){
					calculateNum.text = int(int(exchangeNumTxt.text) * _rateNum).toString();
					if(int(calculateNum.text) > 50000000){
						warnTxt.text = "最多兑换5000万游戏豆";
						TweenLite.from(warnBox, 1, {y:80, alpha:1, onComplete:hideWarnBox});
					}
				}
				else if(_type == BEAN_TO_POINT){
					calculateNum.text = int(int(exchangeNumTxt.text) / _rateNum).toString();
					if(int(exchangeNumTxt.text) > 50000000){
						warnTxt.text = "最多兑换5000万游戏豆";
						TweenLite.from(warnBox, 1, {y:80, alpha:1, onComplete:hideWarnBox});
					}
				}
			}else{
				calculateBg.visible = calculateKedui.visible = calculateHuobi.visible = calculateNum.visible = false;
			}
		}
		
		private function onCancelHandler(event:MouseEvent):void
		{
			if(this.parent){
				this.parent.removeChild(this);
			}
		}
		
		private function onExchangeConfirm(event:MouseEvent):void
		{
			if(exchangeNumTxt.text == ""){
				warnTxt.text = "请输入兑换";
				TweenLite.from(warnBox, 1, {y:80, alpha:1, onComplete:hideWarnBox});
			}else if(int(exchangeNumTxt.text) % 1000 != 0){
				warnTxt.text = "请输入1000的倍数";
				TweenLite.from(warnBox, 1, {y:80, alpha:1, onComplete:hideWarnBox});
			}else{
				if(_type == POINT_TO_BEAN){
					calculateNum.text = (int(exchangeNumTxt.text) * _rateNum).toString();
					if(int(calculateNum.text) > 50000000){
						warnTxt.text = "最多兑换5000万游戏豆";
						TweenLite.from(warnBox, 1, {y:80, alpha:1, onComplete:hideWarnBox});
						return;
					}
					dispatchEvent(new ExchangeEvent(ExchangeEvent.CONFIRM_POINT_TO_BEAN, int(exchangeNumTxt.text), true));
				}
				else{
					if(int(exchangeNumTxt.text) > 50000000){
						warnTxt.text = "最多兑换5000万游戏豆";
						TweenLite.from(warnBox, 1, {y:80, alpha:1, onComplete:hideWarnBox});
						return;
					}
					var exchangePoint:int = int(exchangeNumTxt.text) / _rateNum;
					dispatchEvent(new ExchangeEvent(ExchangeEvent.CONFIRM_BEAN_TO_POINT, exchangePoint, true));
				}
			}
		}
		
		private function hideWarnBox():void{
			if(warnBox)
				TweenLite.to(warnBox, 2, {y:108, alpha:0});
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			dispose();
		}
		
		private function dispose():void{
			exchangeConfirmBtn.removeEventListener(MouseEvent.CLICK, onExchangeConfirm);
			cancelBtn.removeEventListener(MouseEvent.CLICK, onCancelHandler);
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimerHandler);
			timer = null;
			
			removeChildren();
			bgPanel.bitmapData.dispose();
			bgPanel.bitmapData = null;
			bgPanel = null;
			
			cancelBtn.dispose();
			exchangeConfirmBtn.dispose();
			cancelBtn = null;
			exchangeConfirmBtn = null;
			exchangeNumTxt = null;
			panelDiscriptionTxt = null;
			exchangeDiscriptionTxt = null;
			warnBox = null;
			tf = null;
		}
	}
}