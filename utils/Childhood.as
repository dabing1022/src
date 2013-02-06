package utils
{
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;

	public class Childhood
	{
		public static var chargeUrl:String;
		public static var playDiscriptionUrl:String;
		public static var personalCenterUrl:String;
		public static function openUrl(url:String):void{
			navigateToURL(new URLRequest(url), "_blank");
		}
		
		public static function chatByQQ():void{
			if(ExternalInterface.available)
				ExternalInterface.call("chatByQQ");
		}
		
		public static function openChargeUrl():void{
			if(ExternalInterface.available)
				ExternalInterface.call("charge", chargeUrl);
		}
		
		public static function openPlayDiscriptionUrl():void{
			if(ExternalInterface.available)
				ExternalInterface.call("openPlayDiscriptionUrl", playDiscriptionUrl);
		}
		
		public static function openPersonalCenterUrl():void{
			if(ExternalInterface.available)
				ExternalInterface.call("openPersonalCenterUrl", personalCenterUrl);
		}
		
		public static function getRectMaskShape(x:Number, y:Number, width:Number, height:Number):Shape{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0x000000);
			shape.graphics.drawRect(x, y, width, height);
			shape.graphics.endFill();
			return shape;
		}
		
		//深复制，比如数组
		public static function clone(source:Object):*
		{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(source);
			myBA.position = 0;
			return(myBA.readObject());
		}

		
		/**
		 * 将方便布局的index转化成逆时针的id序列
		 * 1 2 3         1 8 7
		 * 4   5   ==>   2   6
		 * 6 7 8         3 4 5
		 * */ 
		public static function chairIndexToId(index:uint):uint{
			var id:uint;
			switch(index){
				case 1:
					id = 1;
					break;
				case 2:
					id = 8;
					break;
				case 3:
					id = 7;
					break;
				case 4:
					id = 2;
					break;
				case 5:
					id = 6;
					break;
				case 6:
					id = 3;
					break;
				case 7:
					id = 4;
					break;
				case 8:
					id = 5;
					break;
			}
			return id;
		}
	}
}