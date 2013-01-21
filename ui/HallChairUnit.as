package ui
{
	import events.CustomEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import model.ChairData;
	import model.UserData;
	
	import utils.ResourceUtils;
	
	/**
	 * 大厅板凳头像单元
	 * */
	public class HallChairUnit extends Sprite
	{
		private var _noPlayer:Boolean;
		private var _avatar:Bitmap;
		private var _chairData:ChairData;
		/**玩家:头像、昵称、桌子id、板凳id、状态
		 * <ul>状态包括：
		 * <li>1.观看</li>
		 * <li>2.等待准备</li>
		 * <li>3.准备</li>
		 * <li>4.游戏中</li>
		 * </ul>
		 * */
		private var _playerData:UserData;
		private var _nickNameTxt:TextField;
		public function HallChairUnit()
		{
			super();
            //默认为没有玩家在板凳上
			_noPlayer = true;
			_playerData = new UserData();
			_chairData = new ChairData();
			
			_avatar = ResourceUtils.getBitmap(Resource.DESK_PLAYER_AVATAR_NO);
			addChild(_avatar);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK, onClickChair, false, 0, true);
			this.buttonMode = true;
		}
		
		private function onMouseOverHandler(e:MouseEvent):void{
			if(_noPlayer)
				_avatar.bitmapData = ResourceUtils.getBitmapData(Resource.DESK_PLAYER_AVATAR_YES);
		}
		
		private function onMouseOutHandler(e:MouseEvent):void{
			if(_noPlayer)
				_avatar.bitmapData = ResourceUtils.getBitmapData(Resource.DESK_PLAYER_AVATAR_NO);
		}
		
		private function onClickChair(e:MouseEvent):void{
			dispatchEvent(new CustomEvent(CustomEvent.CHOOSE_CHAIR, _chairData, true));
		}

		public function setPlayer(noPlayer:Boolean = true, playerData:UserData = null):void
		{
			this.noPlayer = noPlayer;
			_playerData = playerData;
			if(_noPlayer){
				if(_avatar.bitmapData != ResourceUtils.getBitmapData(Resource.DESK_PLAYER_AVATAR_NO))
					_avatar.bitmapData.dispose();
				_avatar.bitmapData = ResourceUtils.getBitmapData(Resource.DESK_PLAYER_AVATAR_NO);
				if(_nickNameTxt && _nickNameTxt.parent){
					removeChild(_nickNameTxt)
					_nickNameTxt = null;
				}
			}else{
				_avatar.bitmapData = ResourceUtils.getBitmapData(_playerData.avarter);
				if(_nickNameTxt == null){
					_nickNameTxt = new TextField();
					_nickNameTxt.x = 0;
					_nickNameTxt.y = 52;
					_nickNameTxt.width = 150;
					_nickNameTxt.height = 30;
					_nickNameTxt.wordWrap = true;
					addChild(_nickNameTxt);
				}
				_nickNameTxt.text = _playerData.nickName;
			}
		}
		
		public function dispose():void{
			removeChildren();
			_avatar.bitmapData.dispose();
			_avatar.bitmapData = null;
			_avatar = null;
			
			if(_nickNameTxt)
				_nickNameTxt = null;
			
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			this.removeEventListener(MouseEvent.CLICK, onClickChair);
		}

		public function get noPlayer():Boolean
		{
			return _noPlayer;
		}

		public function set noPlayer(value:Boolean):void
		{
			_noPlayer = value;
			this.buttonMode = _noPlayer;
		}
		
		public function get playerData():UserData
		{
			return _playerData;
		}

		public function set playerData(value:UserData):void
		{
			_playerData = value;
		}

		public function get avatar():Bitmap
		{
			return _avatar;
		}

		public function set avatar(value:Bitmap):void
		{
			_avatar = value;
		}

		public function get chairData():ChairData
		{
			return _chairData;
		}

		public function set chairData(value:ChairData):void
		{
			_chairData = value;
		}
	}
}
