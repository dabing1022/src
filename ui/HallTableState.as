package ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import model.TableData;
	
	import utils.Childhood;
	import utils.ResourceUtils;

	/**
	 * 大厅每个桌子状态的显示，当前桌子玩家的状态决定了桌子的状态，包括
	 * <li>1.没人</li>
	 * <li>2.进行中</li>
	 * <li>3.准备中</li>
	 * */
	public class HallTableState extends Sprite
	{
		private var table:Bitmap;
		private var gamingNiuLogo:Bitmap;
		private var handUpList:Vector.<Bitmap>;
		private var _tableData:TableData;
		public function HallTableState(tableData:TableData):void
		{
			_tableData = tableData;
			table = ResourceUtils.getBitmap(Resource.DESK_NO_PLAYER);
			addChild(table);
			
			gamingNiuLogo = ResourceUtils.getBitmap(Resource.DESK_READY_NIU_LOGO);
			addChild(gamingNiuLogo);
			gamingNiuLogo.visible = false;
			gamingNiuLogo.x = -5;
			

            /**
             * 将易于布局排列的编号顺序转化成用于数组操作的id序列，如下图：
             * 1  2  3          1  8  7
             * 4     5   =====> 2     6
             * 6  7  8          3  4  5
             */
			handUpList = new Vector.<Bitmap>(8);
			var i:uint;
			var j:uint;
			for(i = 1; i <= 9; i++){
				if(i == 5) continue;
				j = i > 5? i - 1 : i;
				var id:uint = Childhood.chairIndexToId(j);
				var h:uint = (i - 1) % 3;
				var v:uint = (i - 1) / 3;
				var handUp:Bitmap = ResourceUtils.getBitmap(Resource.HAND_UP);
				addChild(handUp);
				handUp.x = 6 + 18 * h;
				handUp.y = -1 + 15 * v;
				handUpList[id - 1] = handUp;
				handUp.visible = false;
			}
		}
		
		public function setState(value:uint, chairHandUpId:int = -1, handUp:Boolean = false):void{
            //chairHandUpId用于标识数组的索引，范围是0~7，当chairHandUpId为-1时候，表示没有人准备
			switch(value){
				case TableData.NO_PLAYER:
					_tableData.state = TableData.NO_PLAYER;
					gamingNiuLogo.visible = false;
					table.visible = true;
					hideHandsUp();
					table.bitmapData = ResourceUtils.getBitmapData(Resource.DESK_NO_PLAYER);
					break;
				case TableData.GAMING:
					_tableData.state = TableData.GAMING;
					table.visible = false;
					gamingNiuLogo.visible = true;
					hideHandsUp();
					break;
				case TableData.WAITING:
					_tableData.state = TableData.WAITING;
					table.visible = true;
					table.bitmapData = ResourceUtils.getBitmapData(Resource.DESK_HAS_PLAYER);
					gamingNiuLogo.visible = false;
					if(chairHandUpId >= 0 && chairHandUpId <= 7 && handUp){
						handUpList[chairHandUpId].visible = true;
					}else{
						handUpList[chairHandUpId].visible = false;
					}
					break;
			}
		}

		public function dispose():void{
			removeChildren();
			table.bitmapData.dispose();
			gamingNiuLogo.bitmapData.dispose();
			table.bitmapData = null;
			gamingNiuLogo.bitmapData = null;
			table = null;
			gamingNiuLogo = null;

			handUpList.splice(0, handUpList.length);	
			handUpList = null;
		}
		
		private function hideHandsUp():void{
			var i:uint;
			for(i = 0; i < 8; i++){
				handUpList[i].visible = false;
			}
		}

		public function get tableData():TableData
		{
			return _tableData;
		}

		public function set tableData(value:TableData):void
		{
			_tableData = value;
		}

		

	}
}
