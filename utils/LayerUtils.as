package utils
{
	import flash.display.Sprite;
	import flash.display.Stage;

	/**
	 * 层管理工具
	 */
	public class LayerUtils
	{
		private var _frameLayer:Sprite;
		private var _gameLayer:Sprite;
		private var _baseLayer:Sprite;
		private static var _instance:LayerUtils;
		
		public static function getInstance():LayerUtils
		{
			return _instance||=new LayerUtils();
		}

		public function start(stage:Stage):void{
			_frameLayer = new Sprite();
			_gameLayer = new Sprite();
			_baseLayer = new Sprite();
			stage.addChild(_baseLayer);
			stage.addChild(_gameLayer);
			stage.addChild(_frameLayer);
		}
		
		public function get frameLayer():Sprite{
			return _frameLayer;
		}
		
		public function get gameLayer():Sprite{
			return _gameLayer;
		}
		
		public function get baseLayer():Sprite{
			return _baseLayer;
		}
	}
}
