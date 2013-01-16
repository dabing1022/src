package ui
{
	import events.ChatEvent;
	import events.UserEvent;
	
	import fl.controls.List;
	import fl.controls.ScrollPolicy;
	import fl.controls.TextArea;
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import model.ChatData;
	import model.Data;
	
	import utils.ResourceUtils;
	
	public class ChatBox extends Sprite
	{
		private var bg:Shape; 
		private var textInputBg:Shape;
		private var textArea:TextArea;
        /**快速回复*/
		private var fastReplyBtn:SimpleButton;
        /**发送消息*/
		private var sendMessageBtn:SimpleButton;
		private var inputTxt:TextField;
        /**清空文本按钮*/
		private var clearTxtBtn:AnimeButton;
        /**快捷回复列表*/
		private var listCompo:List;
		private var dp:DataProvider;
		private var chatData:ChatData;
		private var tf:TextFormat;
		public function ChatBox()
		{
			super();
			chatData = Data.getInstance().chatData;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addBg();
			addTextArea();
			addInputText();
			addBtns();
			addList();
			addEventListeners();
		}
		
		private function addBg():void{
			bg = new Shape();
			bg.graphics.beginFill(0x333333);
			bg.graphics.drawRoundRect(0, 0, 200, 356, 16, 16);
			bg.graphics.endFill();
			addChild(bg);
			
			textInputBg = new Shape();
			textInputBg.graphics.beginFill(0x666666);
			textInputBg.graphics.drawRoundRect(5, 322, 188, 30, 6, 6);
			textInputBg.graphics.endFill();
			addChild(textInputBg);
		}
		
		private function addTextArea():void{
			textArea = new TextArea();
			addChild(textArea);
			with(textArea){
				y = 16;
				width = 200;
				height = 282;
				verticalScrollPolicy = ScrollPolicy.AUTO;
				wordWrap = true;
				editable = false;
			}
		}
		
		private function addInputText():void{
			inputTxt = new TextField();
			with(inputTxt){
				x = 8;
				y = 326;
				width = 154;
				height = 30;
				textColor = 0xffffff;
				maxChars = 50;
                type = TextFieldType.INPUT;
			}
			addChild(inputTxt);
		}
		
		private function addBtns():void{
			clearTxtBtn = new AnimeButton(ResourceUtils.getBitmapData(Resource.CLEAR_TEXT_BUTTON),
				ResourceUtils.getBitmapData(Resource.CLEAR_TEXT_BUTTON),
				ResourceUtils.getBitmapData(Resource.CLEAR_TEXT_BUTTON));
			addChild(clearTxtBtn);
			clearTxtBtn.x = 72;
			clearTxtBtn.y = 302;
			
			fastReplyBtn = ResourceUtils.getButton(Resource.FAST_REPLAY_BUTTON);
			addChild(fastReplyBtn);
			fastReplyBtn.x = 148;
			fastReplyBtn.y = 330;
			
			sendMessageBtn = ResourceUtils.getButton(Resource.SEND_MESSAGE_BUTTON);
			addChild(sendMessageBtn);
			sendMessageBtn.x = 164;
			sendMessageBtn.y = 324;
			
			clearTxtBtn.addEventListener(MouseEvent.CLICK, onClearTxt);
			fastReplyBtn.addEventListener(MouseEvent.CLICK, onFastReply);
			sendMessageBtn.addEventListener(MouseEvent.CLICK, onSendMessage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
		}
		
		private function addList():void{
			dp = new DataProvider();
			dp.addItem({label:Const.FAST_REPLY0});
			dp.addItem({label:Const.FAST_REPLY1});
			dp.addItem({label:Const.FAST_REPLY2});
			dp.addItem({label:Const.FAST_REPLY3});
			dp.addItem({label:Const.FAST_REPLY4});
			
			tf = new TextFormat("Arial", 12, 0xeeeeee, true);
			listCompo = new List();
			listCompo.dataProvider = dp;
			listCompo.setSize(318, 122);
			listCompo.rowCount = 6;
			addChild(listCompo);
			listCompo.x = -156;
			listCompo.y = 200;
			listCompo.setRendererStyle("textFormat", tf);
			listCompo.visible = false;
		}
		
		private function onClickListItem(e:ListEvent):void{
			var fastReplyId:uint = e.index;
			dispatchEvent(new UserEvent(UserEvent.FAST_CHAT, fastReplyId, true));
			listCompo.visible = false;
		}
		
		private function onClearTxt(e:MouseEvent):void{
			textArea.text = "";
		}
		
		private function onFastReply(e:MouseEvent):void{
            listCompo.visible = !listCompo.visible;
		}
		
		private function onSendMessage(e:MouseEvent):void{
			sendMessage();
		}
		
		private function onKeyDownHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.ENTER)
				sendMessage();
		}
		
		public function addWelcomeMessage(nickName:String):void{
			textArea.htmlText += "<font color='#ffff00' size='13'>温馨提示：</font>"
				+ "<font color='#99FF00' size='13'>"+nickName+"</font>" 
				+ "<font color='#FFFFFF' size='13'>进入房间。</font>";
			textArea.verticalScrollPosition = textArea.maxVerticalScrollPosition;
		}
		
		public function addLeaveMessage(nickName:String):void{
			textArea.htmlText += "<font color='#ffff00' size='13'>温馨提示：</font>"
				+ "<font color='#99FF00' size='13'>"+nickName+"</font>" 
				+ "<font color='#FFFFFF' size='13'>离开房间。</font>";
			textArea.verticalScrollPosition = textArea.maxVerticalScrollPosition;
		}
		
		public function addResultPre():void{
			textArea.htmlText += "<font color='#ffff00' size='13'>------本局比赛结果------</font>"
			textArea.verticalScrollPosition = textArea.maxVerticalScrollPosition;
		}
		
		private function sendMessage():void{
			if(inputTxt.text == "" || inputTxt.text.length == 0){
				textArea.htmlText += "<font color='#ffff00' size='13'>提示：</font><font color='#ffffff' size='13'>您输入的内容不能为空！</font>\n";
			}else{
				if(getTimer() - chatData.lastSendTime < ChatData.MIN_TIME_INTERVAL){
					textArea.htmlText += "<font color='#ffff00' size='13'>提示：</font></font><font color='#ffffff' size='13'>您发言过快，请稍等！</font>\n";
				}else{
					dispatchEvent(new UserEvent(UserEvent.NOMAL_CHAT, inputTxt.text, true));
				}
				inputTxt.text = "";
				chatData.lastSendTime = getTimer();
			}
			textArea.verticalScrollPosition = textArea.maxVerticalScrollPosition;
		}
		
		private function onChatDataChange(e:ChatEvent):void{
			var msgObject:Object = chatData.getLastMessage();
			var msg:String = "<font color='#99FF00' size='13'>"+msgObject.nickName+"</font>" 
				+ "<font color='#99FF00' size='13'>: </font>" 
				+ "<font color='#FFFFFF' size='13'>"+msgObject.message+"</font>";
			textArea.htmlText += msg;
			textArea.verticalScrollPosition = textArea.maxVerticalScrollPosition;
		}
		
		private function onRemoveFromStage(e:Event):void{
			removeChildren();
			removeEventListeners();
			bg.graphics.clear();
			textInputBg.graphics.clear();
			textArea.text = "";
			clearTxtBtn.dispose();
			bg = null;
			textInputBg = null;
			textArea = null;
			fastReplyBtn = null;
			sendMessageBtn = null;
			inputTxt = null;
			clearTxtBtn = null;
			listCompo = null;
			dp = null;
		}
		
		private function addEventListeners():void
		{
			clearTxtBtn.addEventListener(MouseEvent.CLICK, onClearTxt);
			fastReplyBtn.addEventListener(MouseEvent.CLICK, onFastReply);
			sendMessageBtn.addEventListener(MouseEvent.CLICK, onSendMessage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			listCompo.addEventListener(ListEvent.ITEM_CLICK, onClickListItem);
			chatData.addEventListener(ChatEvent.DATA_CHANGE, onChatDataChange);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}

        private function removeEventListeners():void{
            clearTxtBtn.removeEventListener(MouseEvent.CLICK, onClearTxt);
            fastReplyBtn.removeEventListener(MouseEvent.CLICK, onFastReply);
            sendMessageBtn.removeEventListener(MouseEvent.CLICK, onSendMessage);
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
            listCompo.removeEventListener(ListEvent.ITEM_CLICK, onClickListItem);
			chatData.removeEventListener(ChatEvent.DATA_CHANGE, onChatDataChange);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
        }
	}
}
