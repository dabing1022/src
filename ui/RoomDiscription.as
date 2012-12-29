package ui
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import utils.ResourceUtils;
	
	/**房间描述*/
	public class RoomDiscription extends Sprite
	{
		private var bg:Bitmap;
		private var discriptionTxt:TextField;
		private var discriptionTF:TextFormat;
		private var discription:String = "";
		private var roomId:uint;
		private var bindTarget:DisplayObject;
		public function RoomDiscription(bindTarget:DisplayObject, roomId:uint = 1):void
		{
			super();
			this.bindTarget = bindTarget;
			this.roomId = roomId;
			if(this.roomId == 1){
				discription = Const.DISCRIPTION_ROOM1;
			}else if(this.roomId == 2){
				discription = Const.DISCRIPTION_ROOM2;
			}
			bg = ResourceUtils.getBitmap(Resource.DISCRIPTION_BG);
			addChild(bg);
			bg.scaleX = 0.8;
			
			discriptionTxt = new TextField();
			discriptionTF = new TextFormat("Verdana", 15, 0xffff00, true);
			with(discriptionTxt){
				text = discription;
				x = 40;
				y = 15;
				width = 200;
				height = 30;
			}
			discriptionTxt.defaultTextFormat = discriptionTF;
			addChild(discriptionTxt);
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public function bindRoom(bindRoom:DisplayObject, roomId:uint):void{
			this.roomId = roomId;
			this.bindTarget = bindRoom;
			if(this.roomId == 1){
				discription = Const.DISCRIPTION_ROOM1;
			}else if(this.roomId == 2){
				discription = Const.DISCRIPTION_ROOM2;
			}
			//update
			update();
		}

		private function update():void{
			discriptionTxt.text = discription;
			this.x = this.bindTarget.x - 25;
			this.y = this.bindTarget.y + 88;
		}
		
		public function dispose():void{
			removeChildren();
			bg.bitmapData.dispose();
			bg.bitmapData = null;
			bg = null;
			discriptionTxt = null;
			discriptionTF = null;
			this.bindTarget = null;
		}
	}
}