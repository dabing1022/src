package ui
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import model.Data;
	import model.RoomData;
	import model.TableData;
	import model.UserData;
	
	import utils.DebugConsole;

	/**
	 * 房间桌子容器，包含该房间内桌子列表
	 * */
	public class RoomTableContainer extends Sprite
	{
		private var tableList:Vector.<HallTableUnit>;
		private var _roomData:RoomData;
		public function RoomTableContainer(roomData:RoomData)
		{
			super();
			_roomData = roomData;
			tableList = new Vector.<HallTableUnit>();
			
			var i:uint;
			var roomId:int = _roomData.roomId;
			var tableNum:int = _roomData.tableNum;
			for(i = 0; i < tableNum; i++){
				var h:uint = i % 3;
				var v:uint = i / 3;
				var hallTableUnit:HallTableUnit = new HallTableUnit(roomId, i + 1);
				hallTableUnit.x = 15 + 320 * h;
				hallTableUnit.y = 12 + 320 * v;
				
				addChild(hallTableUnit);
				tableList.push(hallTableUnit);
			}
			if(_roomData.players.length > 0)
				setRoom(roomData);
		}
		
		public function setRoom(roomData:RoomData):void{
			_roomData = roomData;
			for each(var hallTableUnit:HallTableUnit in tableList){
				hallTableUnit.resumeNoPlayers();
			}
			
			var i:uint;
			var roomId:int = _roomData.roomId;
			var tableNum:int = _roomData.tableNum;
			//更改班板凳的显示状态
			var len:uint = _roomData.players.length;
			var tableId:uint;
			var chairId:uint;
			for(i = 0; i < len; i++){
				tableId = _roomData.players[i].tableId;
				chairId = _roomData.players[i].chairId;
				var hallChairUnit:HallChairUnit = Data.getInstance().roomMap[roomId + "_" + tableId + "_" + chairId];
				var userData:UserData = new UserData();
				userData.avarter = _roomData.players[i].avarter;
				userData.nickName = _roomData.players[i].nickName;
				hallChairUnit.setPlayer(false, userData);
			}
			
			//更改中央桌子的显示状态
			for(i = 0; i < len; i++){
				var userState:uint = _roomData.players[i].state;
				tableId = _roomData.players[i].tableId;
				chairId = _roomData.players[i].chairId;
				var hallTableState:HallTableState = Data.getInstance().tableStateMap[roomId + "_" + tableId];
				if(hallTableState.tableData.state == TableData.GAMING)	continue;
				if(userState == UserData.USER_WAIT_FOR_READY){
					hallTableState.setState(TableData.WAITING, chairId - 1, false);
				}else if(userState == UserData.USER_READY){
					hallTableState.setState(TableData.WAITING, chairId - 1, true);
				}else{
					hallTableState.setState(TableData.GAMING);
				}
			}
		}

		public function update(userData:UserData):void{
			var roomId:uint = userData.roomId;
			var tableId:uint = userData.tableId;
			var chairId:uint = userData.chairId;
			var userState:uint = userData.state;
			
            //通过玩家的tableId和chairId，用roomMap映射找到对应的板凳
			var hallChairUnit:HallChairUnit = Data.getInstance().roomMap[roomId + "_" + tableId + "_" + chairId];
			if(userData.state == 1)
				hallChairUnit.setPlayer(true);
			else
				hallChairUnit.setPlayer(false, userData);
			
            //通过玩家的tableId,用tableStateMap映射找到对应的用于展示状态的桌子
			var hallTableState:HallTableState = Data.getInstance().tableStateMap[roomId + "_" + tableId];
			if(userState == UserData.USER_WAIT_FOR_READY){
				hallTableState.setState(TableData.WAITING, chairId - 1, false);
			}else if(userState == UserData.USER_READY){
				hallTableState.setState(TableData.WAITING, chairId - 1, true);
			}else if(userState == 1 && hasNoPlayers(roomId, tableId)){  //规定：如果用户状态为1，则视为离开牌桌
				hallTableState.setState(TableData.NO_PLAYER);
				DebugConsole.addDebugLog(stage, "当前场的 " + tableId + " 桌子已经没人");
			}else if(userState == 1 && !hasNoPlayers(roomId, tableId)){
				hallTableState.setState(TableData.WAITING, chairId - 1, false);
			}else{
				hallTableState.setState(TableData.GAMING);
			}
		}
		
		private function hasNoPlayers(roomId:uint, tableId:uint):Boolean{
			for(var i:uint = 1; i <= 8; i++){
				var hallChairUnit:HallChairUnit = Data.getInstance().roomMap[roomId + "_" + tableId + "_" + i];
				if(hallChairUnit.noPlayer == false){
					return false;
				}
			}
			return true;
		}
	}
}
