package ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import model.Data;
	import model.TableData;
	
	import utils.Childhood;
	import utils.ResourceUtils;
	
	/**大厅桌子单元
	 * <li>单元背景</li>
	 * <li>8个头像</li>
	 * <li>1个桌子，根据无人和有人以及有多少人有不同的显示</li>
	 * <li>桌子编号文本</li>
	 * */
	public class HallTableUnit extends Sprite
	{
		private var bg:Bitmap;
		private var hallTableState:HallTableState;
		private var _roomId:uint;
		private var _tableId:uint;
		private var _tableIdTxt:TextField;
		public function HallTableUnit(roomId:uint, tableId:uint)
		{
			super();
			_roomId = roomId;
			_tableId = tableId;
			
			bg = ResourceUtils.getBitmap(Resource.DESK_BOX_BG);
			addChild(bg);
			
			var i:uint;
			var j:uint;
			for(i = 1; i <= 9; i++){
				if(i == 5)	continue;
				j = i > 5?i - 1 : i;
				var chairId:uint = Childhood.chairIndexToId(j);
				var h:uint = (i - 1) % 3;
				var v:uint = (i - 1) / 3;
				var hallChairUint:HallChairUnit = new HallChairUnit();
				hallChairUint.chairData.tableId = _tableId;
				hallChairUint.chairData.chairId = chairId;
				hallChairUint.x = 34 + 93 * h;
				hallChairUint.y = 33 + 86 * v;
				addChild(hallChairUint);
				Data.getInstance().roomMap[_roomId + "_" + _tableId + "_" + chairId] = hallChairUint;
			}
			
			
			var tableData:TableData = new TableData();
			tableData.roomId = _roomId;
			tableData.tableId = _tableId;
			tableData.state = TableData.NO_PLAYER;
			hallTableState = new HallTableState(tableData);
			addChild(hallTableState);
			hallTableState.x = 118;
			hallTableState.y = 120;
			Data.getInstance().tableStateMap[_roomId + "_" + _tableId] = hallTableState;
			
			_tableIdTxt = new TextField();
			_tableIdTxt.text = "-★—" + _tableId + "—★-";
			_tableIdTxt.textColor = 0xffffff;
			_tableIdTxt.x = this.width - _tableIdTxt.textWidth >> 1;
			_tableIdTxt.y = 280;
			addChild(_tableIdTxt);
		}
		
		public function resumeNoPlayers():void{
			for(var i:uint = 1; i <= 8; i++){
				(Data.getInstance().roomMap[_roomId + "_" + _tableId + "_" + i] as HallChairUnit).setPlayer(true);
			}
			hallTableState.setState(TableData.NO_PLAYER);
		}
	}
}