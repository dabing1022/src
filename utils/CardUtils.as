package utils
{
	import flash.utils.Dictionary;
	
	import model.CardData;
	import model.CardType;

	public class CardUtils
	{
		public var cardMap:Dictionary;
		public var mapCardTypeToResName:Dictionary;
		public var mapCardTypeToTxt:Dictionary;
		private static var _instance:CardUtils;
		public function CardUtils()
		{
			initCardMap();
			initMapCardTypeToResName();
			initMapCardTypeToTxt();
		}
		
		private function initCardMap():void{
			cardMap = new Dictionary(true);
			cardMap[getKey(CardData.COLOR_HEI, CardData.VA)] = ResourceUtils.getBitmapData(Resource.CARD_A1);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V2)] = ResourceUtils.getBitmapData(Resource.CARD_A2);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V3)] = ResourceUtils.getBitmapData(Resource.CARD_A3);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V4)] = ResourceUtils.getBitmapData(Resource.CARD_A4);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V5)] = ResourceUtils.getBitmapData(Resource.CARD_A5);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V6)] = ResourceUtils.getBitmapData(Resource.CARD_A6);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V7)] = ResourceUtils.getBitmapData(Resource.CARD_A7);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V8)] = ResourceUtils.getBitmapData(Resource.CARD_A8);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V9)] = ResourceUtils.getBitmapData(Resource.CARD_A9);
			cardMap[getKey(CardData.COLOR_HEI, CardData.V10)] = ResourceUtils.getBitmapData(Resource.CARD_A10);
			cardMap[getKey(CardData.COLOR_HEI, CardData.VJ)] = ResourceUtils.getBitmapData(Resource.CARD_A11);
			cardMap[getKey(CardData.COLOR_HEI, CardData.VQ)] = ResourceUtils.getBitmapData(Resource.CARD_A12);
			cardMap[getKey(CardData.COLOR_HEI, CardData.VK)] = ResourceUtils.getBitmapData(Resource.CARD_A13);
			
			cardMap[getKey(CardData.COLOR_HONG, CardData.VA)] = ResourceUtils.getBitmapData(Resource.CARD_B1);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V2)] = ResourceUtils.getBitmapData(Resource.CARD_B2);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V3)] = ResourceUtils.getBitmapData(Resource.CARD_B3);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V4)] = ResourceUtils.getBitmapData(Resource.CARD_B4);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V5)] = ResourceUtils.getBitmapData(Resource.CARD_B5);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V6)] = ResourceUtils.getBitmapData(Resource.CARD_B6);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V7)] = ResourceUtils.getBitmapData(Resource.CARD_B7);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V8)] = ResourceUtils.getBitmapData(Resource.CARD_B8);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V9)] = ResourceUtils.getBitmapData(Resource.CARD_B9);
			cardMap[getKey(CardData.COLOR_HONG, CardData.V10)] = ResourceUtils.getBitmapData(Resource.CARD_B10);
			cardMap[getKey(CardData.COLOR_HONG, CardData.VJ)] = ResourceUtils.getBitmapData(Resource.CARD_B11);
			cardMap[getKey(CardData.COLOR_HONG, CardData.VQ)] = ResourceUtils.getBitmapData(Resource.CARD_B12);
			cardMap[getKey(CardData.COLOR_HONG, CardData.VK)] = ResourceUtils.getBitmapData(Resource.CARD_B13);
			
			cardMap[getKey(CardData.COLOR_MEI, CardData.VA)] = ResourceUtils.getBitmapData(Resource.CARD_C1);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V2)] = ResourceUtils.getBitmapData(Resource.CARD_C2);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V3)] = ResourceUtils.getBitmapData(Resource.CARD_C3);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V4)] = ResourceUtils.getBitmapData(Resource.CARD_C4);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V5)] = ResourceUtils.getBitmapData(Resource.CARD_C5);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V6)] = ResourceUtils.getBitmapData(Resource.CARD_C6);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V7)] = ResourceUtils.getBitmapData(Resource.CARD_C7);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V8)] = ResourceUtils.getBitmapData(Resource.CARD_C8);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V9)] = ResourceUtils.getBitmapData(Resource.CARD_C9);
			cardMap[getKey(CardData.COLOR_MEI, CardData.V10)] = ResourceUtils.getBitmapData(Resource.CARD_C10);
			cardMap[getKey(CardData.COLOR_MEI, CardData.VJ)] = ResourceUtils.getBitmapData(Resource.CARD_C11);
			cardMap[getKey(CardData.COLOR_MEI, CardData.VQ)] = ResourceUtils.getBitmapData(Resource.CARD_C12);
			cardMap[getKey(CardData.COLOR_MEI, CardData.VK)] = ResourceUtils.getBitmapData(Resource.CARD_C13);
			
			cardMap[getKey(CardData.COLOR_FANG, CardData.VA)] = ResourceUtils.getBitmapData(Resource.CARD_D1);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V2)] = ResourceUtils.getBitmapData(Resource.CARD_D2);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V3)] = ResourceUtils.getBitmapData(Resource.CARD_D3);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V4)] = ResourceUtils.getBitmapData(Resource.CARD_D4);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V5)] = ResourceUtils.getBitmapData(Resource.CARD_D5);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V6)] = ResourceUtils.getBitmapData(Resource.CARD_D6);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V7)] = ResourceUtils.getBitmapData(Resource.CARD_D7);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V8)] = ResourceUtils.getBitmapData(Resource.CARD_D8);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V9)] = ResourceUtils.getBitmapData(Resource.CARD_D9);
			cardMap[getKey(CardData.COLOR_FANG, CardData.V10)] = ResourceUtils.getBitmapData(Resource.CARD_D10);
			cardMap[getKey(CardData.COLOR_FANG, CardData.VJ)] = ResourceUtils.getBitmapData(Resource.CARD_D11);
			cardMap[getKey(CardData.COLOR_FANG, CardData.VQ)] = ResourceUtils.getBitmapData(Resource.CARD_D12);
			cardMap[getKey(CardData.COLOR_FANG, CardData.VK)] = ResourceUtils.getBitmapData(Resource.CARD_D13);
			
			cardMap[getKey(CardData.COLOR_GUI, CardData.VG1)] = ResourceUtils.getBitmapData(Resource.CARD_G1);
			cardMap[getKey(CardData.COLOR_GUI, CardData.VG2)] = ResourceUtils.getBitmapData(Resource.CARD_G2);
		}
		
		private function initMapCardTypeToResName():void{
			mapCardTypeToResName = new Dictionary(true);
			mapCardTypeToResName[CardType.NO_NIU] = Resource.WU_NIU;
			mapCardTypeToResName[CardType.NIU_DING] = Resource.NIU_YI;
			mapCardTypeToResName[CardType.NIU_ER] = Resource.NIU_ER;
			mapCardTypeToResName[CardType.NIU_SAN] = Resource.NIU_SAN;
			mapCardTypeToResName[CardType.NIU_SI] = Resource.NIU_SI;
			mapCardTypeToResName[CardType.NIU_WU] = Resource.NIU_WU;
			mapCardTypeToResName[CardType.NIU_LIU] = Resource.NIU_LIU;
			mapCardTypeToResName[CardType.NIU_QI] = Resource.NIU_QI;
			mapCardTypeToResName[CardType.NIU_BA] = Resource.NIU_BA;
			mapCardTypeToResName[CardType.NIU_JIU] = Resource.NIU_JIU;
			mapCardTypeToResName[CardType.NIU_NIU] = Resource.NIU_NIU_ANIME;
			mapCardTypeToResName[CardType.SI_ZHA] = Resource.SI_ZHA_ANIME;
			mapCardTypeToResName[CardType.WU_HUA_NIU] = Resource.WU_HUA_NIU_ANIME;
		}
		
		private function initMapCardTypeToTxt():void{
			mapCardTypeToTxt = new Dictionary();
			mapCardTypeToTxt[-1] = "无牛";
			mapCardTypeToTxt[0] = "牛牛";
			mapCardTypeToTxt[1] = "牛一";
			mapCardTypeToTxt[2] = "牛二";
			mapCardTypeToTxt[3] = "牛三";
			mapCardTypeToTxt[4] = "牛四";
			mapCardTypeToTxt[5] = "牛五";
			mapCardTypeToTxt[6] = "牛六";
			mapCardTypeToTxt[7] = "牛七";
			mapCardTypeToTxt[8] = "牛八";
			mapCardTypeToTxt[9] = "牛九";
			mapCardTypeToTxt[4444] = "炸弹";
			mapCardTypeToTxt[55555] = "五花牛";
		}
		
		private function getKey(color:int, value:int):String{
			return color + "_" + value;
		}
		
		/**
		 * @param cards  牌数据数组
		 * @return Object 如果无牛，则返回null;
		 * 如果有牛、炸弹或者五花牛，则返回一个对象obj
		 * <li>obj.cardType 牌型</li>
		 * <li>obj.cardsIndex 构成牌型的牌的索引</li>
		 * */
		public function analysisCards(cards:Array):Object{
			var obj:Object = {};
			var hasNiu:Boolean;
			var i:int, j:int, k:int, tempSum:int;
			var sum:int = getSumInArr(cards);
			if(judgeBomb(cards)){
				obj.cardType = CardType.SI_ZHA;
				obj.cardsIndex = judgeBomb(cards).cardsIndex;
				return obj;
			}
			if(judgeWuHuaNiu(cards)){
				obj.cardType = CardType.WU_HUA_NIU;
				obj.cardsIndex = judgeWuHuaNiu(cards).cardsIndex;
				return obj;
			}
			
			for(i = 0; i <= 2; i++){
				for(j = i + 1; j <= 3; j++){
					for(k = j + 1; k <= 4; k++){
						tempSum = getNiuValue(cards[i].value) + getNiuValue(cards[j].value) + getNiuValue(cards[k].value);
						if(tempSum % 10 == 0){
							hasNiu = true;
							obj.cardType = (sum - tempSum) % 10;
							obj.cardsIndex = [i, j, k];
							return obj;
						}
					}
				}
			}
			obj.cardType = CardType.NO_NIU;
			obj.cardsIndex = null;
			return obj;
		}
		
		/**判断五花牛*/
		private function judgeWuHuaNiu(cards:Array):Object{
			var obj:Object = {};
			if(isInRange(cards[0].value, 11, 13) 
				&& isInRange(cards[1].value, 11, 13)
				&& isInRange(cards[2].value, 11, 13)
				&& isInRange(cards[3].value, 11, 13)
				&& isInRange(cards[4].value, 11, 13)){
				obj.wuhua = true;
				obj.cardsIndex = [0, 1, 2, 3, 4];
				return obj;
			}
			return null;
		}
		
		public function isInRange(value:uint, min:uint, max:uint):Boolean{
			return (value >= min && value <= max);
		}
		
		private function judgeBomb(cards:Array):Object{
			var obj:Object = {};
			var i:int, j:int, m:int, n:int;
			for(i = 0; i <= 1; i++){
				for(j = i + 1; j <= 2; j++){
					for(m = j + 1; m <= 3; m++){
						for(n = m + 1; n <= 4; n++){
							//四炸
							var k:int = cards[i].value;
							if(cards[i].value == k && cards[j].value == k && cards[m].value == k && cards[n].value == k)
							{
								obj.bomb = true;
								obj.cardsIndex = [i, j , m , n];
								return obj;
							}
						}
					}
				}
			}
			
			for(i = 0; i <= 3; i++){
				for(j = i + 1; j <= 4; j++){
					//双鬼炸弹
					if(cards[i].color == CardData.COLOR_GUI && cards[j].color == CardData.COLOR_GUI){
						obj.bomb = true;
						obj.cardsIndex = [i, j];
						return obj;
					}
				}
			}
			return null;
		}
		
		public function getNiuValue(value:int):int{
			if(value >= CardData.V10 && value <= CardData.VG2)
				return 10;
			else
				return value;
		}
		
		/**
		 * @param cards Array类型，里面存储数据为CardData类型
		 */
		public function getSumInArr(cards:Array):int{
			var len:int = cards.length;
			var i:int, sum:int = 0;
			for(i = 0; i < len; i++){
				var niuValue:int = getNiuValue(cards[i].value);
				sum += niuValue;
			}
			return sum;
		}
		
		public static function getInstance():CardUtils{
			if(_instance == null)
				_instance = new CardUtils();
			return _instance;
		}
	}
}
