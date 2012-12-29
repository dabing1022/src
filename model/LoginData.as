package model
{
	/**
	 * 登录数据，单例模式
	 * */
	public class LoginData
	{
		public var username:String;
		public var password:String;
		public var platform:String;
		public var sign:String;
		private static var _instance:LoginData;
		public static function getInstance():LoginData{
			if(_instance == null)
				_instance = new LoginData();
			return _instance;
		}
	}
}