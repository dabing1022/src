package model
{
	import com.adobe.protocols.dict.Dict;
	
	import flash.utils.Dictionary;
	/**
	 * 与服务器交互数据集合
	 */
	public class Data 
	{
		private static var _instance:Data;
		public var player:UserData;
		public var playerList:Vector.<UserData>;
		public var playerNum:uint;
		/**板凳编号1_1等对hallChairUnit的映射*/
		public var roomMap:Dictionary;	
		/**桌子1、2等对hallTableState的映射*/
		public var tableStateMap:Dictionary;
		
		public var chatData:ChatData;
		public var gamingPlayersList:Vector.<UserData>;
		public var Z_PosId:uint;
		public function Data():void{
			player = new UserData();
			roomMap = new Dictionary(true);
			tableStateMap = new Dictionary(true);
			chatData = new ChatData();
			initPlayerList();
		}

		private function initPlayerList():void{
			for(var i:uint = 0; i < playerNum; i++){
				playerList[i] = new UserData();
			}
		}
		
		public function objToUserDataInUpdateChairs(obj:Object):UserData{
			var userData:UserData = new UserData();
			userData.username = obj.username;
			userData.roomId = obj.roomId;
			userData.nickName = obj.nickName;
			userData.avarter = obj.avarter;
			userData.chairId = obj.chairId;
			userData.state = obj.state;
			userData.tableId = obj.tableId;
			return userData;
		}
		
		//进入桌子后，收到的桌子玩家信息，将之转成游戏中用户数据列表
		public function usersInfoList2gamingPlayersList(usersInfo:Array):Vector.<UserData>{
			gamingPlayersList = new Vector.<UserData>();
			var len:uint = usersInfo.length;
			var i:uint;
			for(i = 0; i < len; i++){
				var userData:UserData = new UserData();
				userData.avarter = usersInfo[i].avarter;
				userData.roomId = usersInfo[i].roomId;
				userData.betCoin = usersInfo[i].betCoin;
				userData.betCoinArr = usersInfo[i].betCoinArray;
				userData.cards = usersInfo[i].cards;
				userData.chairId = usersInfo[i].chairId;
				userData.nickName = usersInfo[i].nickName;
				userData.pid = usersInfo[i].pid;
				userData.isZ = usersInfo[i].makers;
				userData.canJiaoZ = usersInfo[i].chooseMakers;
				userData.sex = usersInfo[i].sex;
				userData.state = usersInfo[i].state;
				userData.tableId = usersInfo[i].tableId;
				userData.isTuoguan = usersInfo[i].tuoguan;
				userData.money = usersInfo[i].userCoin;
				userData.username = usersInfo[i].username;
				userData.remainCountDownTime = usersInfo[i].cdNum;
				userData.totalCountTime = usersInfo[i].cdCount;
				userData.showCountDown = usersInfo[i].showCD;
				userData.cardType = usersInfo[i].cardSize;
				userData.showCards = usersInfo[i].showCards;
				userData.winCoin = usersInfo[i].winCoin;
				gamingPlayersList.push(userData);
			}
			return gamingPlayersList;
		}
		
		//在游戏中更新玩家信息
		public function objToUserDataInUpdateTablePlayer(obj:Object):UserData{
			var userData:UserData = new UserData();
			userData.username = obj.hasOwnProperty("username")?obj.username:userData.username;
			userData.roomId = obj.hasOwnProperty("roomId")?obj.roomId:userData.roomId;
			userData.money = obj.hasOwnProperty("userCoin")?obj.userCoin:userData.money;
			userData.showCountDown = obj.hasOwnProperty("showCD")?obj.showCD:userData.showCountDown;
			userData.betCoinArr = obj.hasOwnProperty("betCoinArray")?obj.betCoinArray:userData.betCoinArr;
			userData.state = obj.hasOwnProperty("state")?obj.state:userData.state;
			userData.avarter = obj.hasOwnProperty("avarter")?obj.avarter:userData.avarter;
			userData.betCoin = obj.hasOwnProperty("betCoin")?obj.betCoin:userData.betCoin;
			userData.cards = obj.hasOwnProperty("cards")?obj.cards:userData.cards;
			userData.chairId = obj.hasOwnProperty("chairId")?obj.chairId:userData.chairId;
			userData.nickName = obj.hasOwnProperty("nickName")?obj.nickName:userData.nickName;
			userData.pid = obj.hasOwnProperty("pid")?obj.pid:userData.pid;
			userData.canJiaoZ = obj.hasOwnProperty("chooseMakers")?obj.chooseMakers:userData.canJiaoZ;
			userData.isZ = obj.hasOwnProperty("makers")?obj.makers:userData.isZ;
			userData.sex = obj.hasOwnProperty("sex")?obj.sex:userData.sex;
			userData.tableId = obj.hasOwnProperty("tableId")?obj.tableId:userData.tableId;
			userData.isTuoguan = obj.hasOwnProperty("tuoguan")?obj.tuoguan:userData.isTuoguan;
			userData.remainCountDownTime = obj.hasOwnProperty("cdNum")?obj.cdNum:userData.remainCountDownTime;
			userData.totalCountTime = obj.hasOwnProperty("cdCount")?obj.cdCount:userData.totalCountTime;
			userData.cardType = obj.hasOwnProperty("cardsSize")?obj.cardsSize:userData.cardType;
			userData.showCards = obj.hasOwnProperty("showCards")?obj.showCards:userData.showCards;
			userData.winCoin = obj.hasOwnProperty("winCoin")?obj.winCoin:userData.winCoin;
			return userData;
		}
		
		/**更新游戏桌子单个玩家信息*/
		public function updateTablePlayer(obj:Object):void{
			var len:uint = gamingPlayersList.length;
			var i:uint;
			var userData:UserData;
			for(i = 0; i < len; i++){
				userData = gamingPlayersList[i];
				if(userData.username == obj.username){
					userData.money = obj.hasOwnProperty("userCoin")?obj.userCoin:userData.money;
					userData.roomId = obj.hasOwnProperty("roomId")?obj.roomId:userData.roomId;
					userData.showCountDown = obj.hasOwnProperty("showCD")?obj.showCD:userData.showCountDown;
					userData.betCoinArr = obj.hasOwnProperty("betCoinArray")?obj.betCoinArray:userData.betCoinArr;
					userData.state = obj.hasOwnProperty("state")?obj.state:userData.state;
					userData.avarter = obj.hasOwnProperty("avarter")?obj.avarter:userData.avarter;
					userData.betCoin = obj.hasOwnProperty("betCoin")?obj.betCoin:userData.betCoin;
					userData.cards = obj.hasOwnProperty("cards")?obj.cards:userData.cards;
					userData.chairId = obj.hasOwnProperty("chairId")?obj.chairId:userData.chairId;
					userData.nickName = obj.hasOwnProperty("nickName")?obj.nickName:userData.nickName;
					userData.pid = obj.hasOwnProperty("pid")?obj.pid:userData.pid;
					userData.canJiaoZ = obj.hasOwnProperty("chooseMakers")?obj.chooseMakers:userData.canJiaoZ;
					userData.isZ = obj.hasOwnProperty("makers")?obj.makers:userData.isZ;
					userData.sex = obj.hasOwnProperty("sex")?obj.sex:userData.sex;
					userData.tableId = obj.hasOwnProperty("tableId")?obj.tableId:userData.tableId;
					userData.isTuoguan = obj.hasOwnProperty("tuoguan")?obj.tuoguan:userData.isTuoguan;
					userData.remainCountDownTime = obj.hasOwnProperty("cdNum")?obj.cdNum:userData.remainCountDownTime;
					userData.totalCountTime = obj.hasOwnProperty("cdCount")?obj.cdCount:userData.totalCountTime;
					userData.cardType = obj.hasOwnProperty("cardsSize")?obj.cardsSize:userData.cardType;
					userData.showCards = obj.hasOwnProperty("showCards")?obj.showCards:userData.showCards;
					userData.winCoin = obj.hasOwnProperty("winCoin")?obj.winCoin:userData.winCoin;
					break;
				}
			}
		}
		
		/**更新游戏桌子所有玩家信息*/
		public function updateTablePlayers(objArr:Array):void{
			var len1:uint = objArr.length;
			var len2:uint = gamingPlayersList.length;
			var i:uint, j:uint;
			for(i = 0; i < len1; i++){
				for(j = 0; j < len2; j++){
					if(gamingPlayersList[j].username == objArr[i].username){
						gamingPlayersList[j].money = objArr[i].hasOwnProperty("userCoin")?objArr[i].userCoin:gamingPlayersList[j].money;
						gamingPlayersList[j].roomId = gamingPlayersList[j].hasOwnProperty("roomId")?gamingPlayersList[j].roomId:gamingPlayersList[j].roomId;
						gamingPlayersList[j].showCountDown = objArr[i].hasOwnProperty("showCD")?objArr[i].showCD:gamingPlayersList[j].showCountDown;
						gamingPlayersList[j].betCoin = objArr[i].hasOwnProperty("betCoin")?objArr[i].betCoin:gamingPlayersList[j].betCoin;
						gamingPlayersList[j].betCoinArr = objArr[i].hasOwnProperty("betCoinArray")?objArr[i].betCoinArray:gamingPlayersList[j].betCoinArr;
						gamingPlayersList[j].state = objArr[i].hasOwnProperty("state")?objArr[i].state:gamingPlayersList[j].state;
						gamingPlayersList[j].avarter = objArr[i].hasOwnProperty("avarter")?objArr[i].avarter:gamingPlayersList[j].avarter;
						gamingPlayersList[j].cards = objArr[i].hasOwnProperty("cards")?objArr[i].cards:gamingPlayersList[j].cards;
						gamingPlayersList[j].chairId = objArr[i].hasOwnProperty("chairId")?objArr[i].chairId:gamingPlayersList[j].chairId;
						gamingPlayersList[j].nickName = objArr[i].hasOwnProperty("nickName")?objArr[i].nickName:gamingPlayersList[j].nickName;
						gamingPlayersList[j].pid = objArr[i].hasOwnProperty("pid")?objArr[i].pid:gamingPlayersList[j].pid;
						gamingPlayersList[j].canJiaoZ = objArr[i].hasOwnProperty("chooseMakers")?objArr[i].chooseMakers:gamingPlayersList[j].canJiaoZ;
						gamingPlayersList[j].isZ = objArr[i].hasOwnProperty("makers")?objArr[i].makers:gamingPlayersList[j].isZ;
						gamingPlayersList[j].sex = objArr[i].hasOwnProperty("sex")?objArr[i].sex:gamingPlayersList[j].sex;
						gamingPlayersList[j].tableId = objArr[i].hasOwnProperty("tableId")?objArr[i].tableId:gamingPlayersList[j].tableId;
						gamingPlayersList[j].isTuoguan = objArr[i].hasOwnProperty("tuoguan")?objArr[i].tuoguan:gamingPlayersList[j].isTuoguan;
						gamingPlayersList[j].remainCountDownTime = objArr[i].hasOwnProperty("cdNum")?objArr[i].cdNum:gamingPlayersList[j].remainCountDownTime;
						gamingPlayersList[j].totalCountTime = objArr[i].hasOwnProperty("cdCount")?objArr[i].cdCount:gamingPlayersList[j].totalCountTime;
						gamingPlayersList[j].cardType = objArr[i].hasOwnProperty("cardsSize")?objArr[i].cardsSize:gamingPlayersList[j].cardType;
						gamingPlayersList[j].showCards = objArr[i].hasOwnProperty("showCards")?objArr[i].showCards:gamingPlayersList[j].showCards;
						gamingPlayersList[j].winCoin = objArr[i].hasOwnProperty("winCoin")?objArr[i].winCoin:gamingPlayersList[j].winCoin;
						break;
					}
				}
			}
		}
		
		/**在玩家数组中找到自己并更新玩家自己的信息*/
		public function updateMyselfInArr(objArr:Array):void{
			var len:uint = objArr.length;
			var i:uint;
			for(i = 0; i < len; i++){
				if(Data.getInstance().player.username == objArr[i].username){
					Data.getInstance().player.money = objArr[i].hasOwnProperty("userCoin")?objArr[i].userCoin:Data.getInstance().player.money;
					Data.getInstance().player.roomId = objArr[i].hasOwnProperty("roomId")?objArr[i].roomId:Data.getInstance().player.roomId;
					Data.getInstance().player.avarter = objArr[i].hasOwnProperty("avarter")?objArr[i].avarter:Data.getInstance().player.avarter;
					Data.getInstance().player.betCoinArr = objArr[i].hasOwnProperty("betCoinArray")?objArr[i].betCoinArray:Data.getInstance().player.betCoinArr;
					Data.getInstance().player.showCountDown = objArr[i].hasOwnProperty("showCD")?objArr[i].showCD:Data.getInstance().player.showCountDown;
					Data.getInstance().player.state = objArr[i].hasOwnProperty("state")?objArr[i].state:Data.getInstance().player.state;
					Data.getInstance().player.betCoin = objArr[i].hasOwnProperty("betCoin")?objArr[i].betCoin:Data.getInstance().player.betCoin;
					Data.getInstance().player.cards = objArr[i].hasOwnProperty("cards")?objArr[i].cards:Data.getInstance().player.cards;
					Data.getInstance().player.canJiaoZ = objArr[i].hasOwnProperty("chooseMakers")?objArr[i].chooseMakers:Data.getInstance().player.canJiaoZ;
					Data.getInstance().player.isZ = objArr[i].hasOwnProperty("makers")?objArr[i].makers:Data.getInstance().player.isZ;
					Data.getInstance().player.pid = objArr[i].hasOwnProperty("pid")?objArr[i].pid:Data.getInstance().player.pid;
					Data.getInstance().player.tableId = objArr[i].hasOwnProperty("tableId")?objArr[i].tableId:Data.getInstance().player.tableId;
					Data.getInstance().player.nickName = objArr[i].hasOwnProperty("nickName")?objArr[i].nickName:Data.getInstance().player.nickName;
					Data.getInstance().player.chairId = objArr[i].hasOwnProperty("chairId")?objArr[i].chairId:Data.getInstance().player.chairId;
					Data.getInstance().player.isTuoguan = objArr[i].hasOwnProperty("tuoguan")?objArr[i].tuoguan:Data.getInstance().player.isTuoguan;
					Data.getInstance().player.remainCountDownTime = objArr[i].hasOwnProperty("cdNum")?objArr[i].cdNum:Data.getInstance().player.remainCountDownTime;
					Data.getInstance().player.totalCountTime = objArr[i].hasOwnProperty("cdCount")?objArr[i].cdCount:Data.getInstance().player.totalCountTime;
					Data.getInstance().player.sex = objArr[i].hasOwnProperty("sex")?objArr[i].sex:Data.getInstance().player.sex;
					Data.getInstance().player.cardType = objArr[i].hasOwnProperty("cardsSize")?objArr[i].cardsSize:Data.getInstance().player.cardType;
					Data.getInstance().player.showCards = objArr[i].hasOwnProperty("showCards")?objArr[i].showCards:Data.getInstance().player.showCards;
					Data.getInstance().player.winCoin = objArr[i].hasOwnProperty("winCoin")?objArr[i].winCoin:Data.getInstance().player.winCoin;
					break;
				}
			}
		}
		
		/**更新玩家自己的信息*/
		public function updateMyself(obj:Object):void{
			if(Data.getInstance().player.username == obj.username){
				Data.getInstance().player.money = obj.hasOwnProperty("userCoin")?obj.userCoin:Data.getInstance().player.money;
				Data.getInstance().player.showCountDown = obj.hasOwnProperty("showCD")?obj.showCD:Data.getInstance().player.showCountDown;
				Data.getInstance().player.betCoinArr = obj.hasOwnProperty("betCoinArray")?obj.betCoinArray:Data.getInstance().player.betCoinArr;
				Data.getInstance().player.state = obj.hasOwnProperty("state")?obj.state:Data.getInstance().player.state;
				Data.getInstance().player.avarter = obj.hasOwnProperty("avarter")?obj.avarter:Data.getInstance().player.avarter;
				Data.getInstance().player.betCoin = obj.hasOwnProperty("betCoin")?obj.betCoin:Data.getInstance().player.betCoin;
				Data.getInstance().player.cards = obj.hasOwnProperty("cards")?obj.cards:Data.getInstance().player.cards;
				Data.getInstance().player.chairId = obj.hasOwnProperty("chairId")?obj.chairId:Data.getInstance().player.chairId;
				Data.getInstance().player.nickName = obj.hasOwnProperty("nickName")?obj.nickName:Data.getInstance().player.nickName;
				Data.getInstance().player.pid = obj.hasOwnProperty("pid")?obj.pid:Data.getInstance().player.pid;
				Data.getInstance().player.canJiaoZ = obj.hasOwnProperty("chooseMakers")?obj.chooseMakers:Data.getInstance().player.canJiaoZ;
				Data.getInstance().player.isZ = obj.hasOwnProperty("makers")?obj.makers:Data.getInstance().player.isZ;
				Data.getInstance().player.sex = obj.hasOwnProperty("sex")?obj.sex:Data.getInstance().player.sex;
				Data.getInstance().player.tableId = obj.hasOwnProperty("tableId")?obj.tableId:Data.getInstance().player.tableId;
				Data.getInstance().player.isTuoguan = obj.hasOwnProperty("tuoguan")?obj.tuoguan:Data.getInstance().player.isTuoguan;
				Data.getInstance().player.remainCountDownTime = obj.hasOwnProperty("cdNum")?obj.cdNum:Data.getInstance().player.remainCountDownTime;
				Data.getInstance().player.totalCountTime = obj.hasOwnProperty("cdCount")?obj.cdCount:Data.getInstance().player.totalCountTime;
				Data.getInstance().player.cardType = obj.hasOwnProperty("cardsSize")?obj.cardsSize:Data.getInstance().player.cardType;
				Data.getInstance().player.showCards = obj.hasOwnProperty("showCards")?obj.showCards:Data.getInstance().player.showCards;
				Data.getInstance().player.winCoin = obj.hasOwnProperty("winCoin")?obj.winCoin:Data.getInstance().player.winCoin;
			}
		}
		
		/**有新的玩家进来*/
		public function addNewPlayerInList(obj:Object):UserData{
			var userData:UserData = new UserData();
			userData.username = obj.hasOwnProperty("username")?obj.username:userData.username;
			userData.roomId = obj.hasOwnProperty("roomId")?obj.roomId:userData.roomId;
			userData.money = obj.hasOwnProperty("userCoin")?obj.userCoin:userData.money;
			userData.showCountDown = obj.hasOwnProperty("showCD")?obj.showCD:userData.showCountDown;
			userData.betCoinArr = obj.hasOwnProperty("betCoinArray")?obj.betCoinArray:userData.betCoinArr;
			userData.state = obj.hasOwnProperty("state")?obj.state:userData.state;
			userData.avarter = obj.hasOwnProperty("avarter")?obj.avarter:userData.avarter;
			userData.betCoin = obj.hasOwnProperty("betCoin")?obj.betCoin:userData.betCoin;
			userData.cards = obj.hasOwnProperty("cards")?obj.cards:userData.cards;
			userData.chairId = obj.hasOwnProperty("chairId")?obj.chairId:userData.chairId;
			userData.nickName = obj.hasOwnProperty("nickName")?obj.nickName:userData.nickName;
			userData.pid = obj.hasOwnProperty("pid")?obj.pid:userData.pid;
			userData.canJiaoZ = obj.hasOwnProperty("chooseMakers")?obj.chooseMakers:userData.canJiaoZ;
			userData.isZ = obj.hasOwnProperty("makers")?obj.makers:userData.isZ;
			userData.sex = obj.hasOwnProperty("sex")?obj.sex:userData.sex;
			userData.tableId = obj.hasOwnProperty("tableId")?obj.tableId:userData.tableId;
			userData.isTuoguan = obj.hasOwnProperty("tuoguan")?obj.tuoguan:userData.isTuoguan;
			userData.remainCountDownTime = obj.hasOwnProperty("cdNum")?obj.cdNum:userData.remainCountDownTime;
			userData.totalCountTime = obj.hasOwnProperty("cdCount")?obj.cdCount:userData.totalCountTime;
			userData.cardType = obj.hasOwnProperty("cardsSize")?obj.cardsSize:userData.cardType;
			userData.showCards = obj.hasOwnProperty("showCards")?obj.showCards:userData.showCards;
			userData.winCoin = obj.hasOwnProperty("winCoin")?obj.winCoin:userData.winCoin;
			gamingPlayersList.push(userData);
			return userData;
		}
		
		/**有玩家离开桌子*/
		public function removePlayerInList(playerObj:Object):UserData{
			var len:uint = gamingPlayersList.length;
			var i:uint;
			var userDataVec:Vector.<UserData>;
			for(i = 0; i < len; i++){
				if(gamingPlayersList[i].username == playerObj.username){
					userDataVec = gamingPlayersList.splice(i, 1);
					return userDataVec[0];
				}
			}
			
			trace("remove player from playerlist wrong happened...");
			return null;
		}
	
		public static function getInstance():Data
		{
			if (_instance == null)
			{
				_instance=new Data();
			}
			return _instance;
		}
	}
}