package ui
{
	import fl.controls.DataGrid;
	import fl.controls.ScrollPolicy;
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.data.DataProvider;
	import fl.events.DataChangeEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	import model.UserData;
	
	import utils.DebugConsole;
	import utils.ResourceUtils;

	/**
	 * 游戏进行界面中的右侧玩家数据列表
	 * 桌号、状态、性别、昵称、账号、游戏币
	 * */
	public class PlayerDataGrid extends Sprite
	{
		private var dataGrid:DataGrid;
		public var dp:DataProvider;
		private var tableIdCol:DataGridColumn;
		private var statusCol:DataGridColumn;
		private var sexCol:DataGridColumn;
		private var nickNameCol:DataGridColumn;
		private var usernameCol:DataGridColumn;
		private var moneyCol:DataGridColumn;
		private var tf:TextFormat;
		private var Boy:Class;
		private var Girl:Class;
		private var Gaming:Class;
		private var ReadyOk:Class;
		private var WaitingForReady:Class;
		private var Watching:Class;
		public function PlayerDataGrid()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			definiteClasses();
			tf = new TextFormat("Verdana", 12, 0x999999, true);
			
			tableIdCol = new DataGridColumn("tableId");
			tableIdCol.headerText = "桌号";
			tableIdCol.width = 45;
			tableIdCol.editable = false;
			tableIdCol.sortable = false;
			
			statusCol = new DataGridColumn("status");
			statusCol.headerText = "状态";
			statusCol.width = 45;
			statusCol.editable = false;
			statusCol.sortable = false;
			statusCol.cellRenderer = PlayerStatusCellRenderer;
			
			sexCol = new DataGridColumn("sex");
			sexCol.headerText = "性别";
			sexCol.width = 45;
			sexCol.editable = false;
			sexCol.sortable = false;
			sexCol.cellRenderer = PlayerSexCellRenderer;
			
			nickNameCol = new DataGridColumn("nickName");
			nickNameCol.headerText = "昵称";
			nickNameCol.width = 130;
			nickNameCol.editable = false;
			
			usernameCol = new DataGridColumn("username");
			usernameCol.headerText = "帐号";
			usernameCol.width = 100;
			usernameCol.sortable = false;
			usernameCol.editable = false;
			
			moneyCol = new DataGridColumn("money");
			moneyCol.headerText = "游戏币";
			moneyCol.width = 100;
			moneyCol.sortable = false;
			moneyCol.editable = false;
			
			dp = new DataProvider();
			
			dataGrid = new DataGrid();
			dataGrid.addColumn(tableIdCol);
			dataGrid.addColumn(statusCol);
			dataGrid.addColumn(sexCol);
			dataGrid.addColumn(nickNameCol);
			dataGrid.addColumn(usernameCol);
			dataGrid.addColumn(moneyCol);
			dataGrid.dataProvider = dp;
			dataGrid.move(792 , 90);
			dataGrid.setSize(200, 200);
			dataGrid.sortableColumns = false;
			dataGrid.resizableColumns = false;
			dataGrid.rowHeight = 18;
			dataGrid.setStyle("headerTextFormat", tf);
			dataGrid.setStyle("textFormat", tf);
			dataGrid.selectable = false;
			dataGrid.horizontalScrollPolicy = ScrollPolicy.ON;
			dataGrid.verticalScrollPolicy = ScrollPolicy.AUTO;
			addChild(dataGrid);
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		
		private function onRemoveFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			removeChildren();
			dp = null;
		}
		
		private function definiteClasses():void{
			Boy = ResourceUtils.getCls(Resource.SEX_BOY);
			Girl = ResourceUtils.getCls(Resource.SEX_GIRL);
			Gaming = ResourceUtils.getCls(Resource.STATUS_GAMING);
			ReadyOk = ResourceUtils.getCls(Resource.STATUS_READY_OK);
			WaitingForReady = ResourceUtils.getCls(Resource.STATUS_WAITING_FOR_READY);
			Watching = ResourceUtils.getCls(Resource.STATUS_WATCHING);
		}
		
		public function addItemInDp(userData:UserData):void{
			var statusInfo:String = getStatusInfoByState(userData.state);
			var sexInfo:String = getSexInfoByUser(userData.sex);
			var userItem:Object = {"tableId": userData.tableId,
									"status":  statusInfo,
									"sex":     sexInfo,
									"nickName":userData.nickName,
									"username":userData.username,
									"money":   userData.money};
			dp.addItem(userItem);
			dataGrid.dataProvider = dp;
		}
		
		private function getSexInfoByUser(sex:int):String{
			var sexInfo:String;
			switch(sex){
				case 0:
					sexInfo = "Girl";
					break;
				case 1:
					sexInfo = "Boy";
					break;
			}
			return sexInfo;
		}
		
		private function getStatusInfoByState(state:uint):String{
			var statusInfo:String;
			switch(state){
				case UserData.USER_WAIT_FOR_READY:
					statusInfo = "WaitingForReady";
					break;
				case UserData.USER_WATCH:
					statusInfo = "Watching";
					break;
				case UserData.USER_READY:
					statusInfo = "ReadyOk";
					break;
				case UserData.USER_BET:
				case UserData.USER_SHOWCARDS:
				case UserData.USER_WAIT_BET:
				case UserData.USER_WAIT_SHOWCARDS:
				case UserData.USER_JIAO_Z:
					statusInfo = "Gaming";
					break;
			}
			return statusInfo;
		}
		
		public function updateItemInDp(userObj:Object):void{
			//只有状态和金币会更新
			var len:uint = dp.length;
			for(var i:uint = 0; i < len; i++){
				if(dp.getItemAt(i).username == userObj.username){
					dp.getItemAt(i).status = getStatusInfoByState(userObj.state);
					dp.getItemAt(i).money = userObj.userCoin;
					dataGrid.dataProvider = dp;
					break;
				}
			}
		}
		
		public function removeItemInDp(userData:UserData):void{
			for(var i:uint = 0; i < dp.length; i++){
				if(dp.getItemAt(i).username == userData.username){
					dp.removeItemAt(i);
					dataGrid.dataProvider = dp;
					break;
				}
			}
		}
	}
}