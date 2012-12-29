package utils
{
	import com.adobe.serialization.json.JSON;
	
	import flash.errors.IOError;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	import flash.utils.ByteArray;

	/**
	 * 通信工具类
	 * @author Administrator
	 */
	public class CommunicateUtils extends EventDispatcher
	{
		private static var _instance:CommunicateUtils;
		private var b:ByteArray = new ByteArray();

		public static function getInstance():CommunicateUtils
		{
			if(_instance == null){
				_instance = new CommunicateUtils();
			}
			return _instance;
		}

		private var byteArray:ByteArray = new ByteArray();
		/**
		 * 发送消息
		 * @param cmd 命令Command定义
		 * @param content 内容
		 */
		public function sendMessage(socket:Socket, cmd:String, content:Object, isEncode:Boolean = true):void
		{
			var contentStr:String = isEncode?com.adobe.serialization.json.JSON.encode(content):content.toString();
			byteArray.clear();
			byteArray.writeUTFBytes(cmd);
			byteArray.writeUTFBytes(contentStr);
			var leng:int = byteArray.length;

			b.clear();
			b.writeInt(leng);
			b.writeUTFBytes(cmd);
			b.writeUTFBytes(contentStr);

			try{
				socket.writeBytes(b);
				socket.flush();
			}catch(e:IOError){
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "data send failure..."));
			}
		}
	}
}


