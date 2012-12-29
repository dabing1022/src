package ui
{
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityProperties;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**当鼠标移动上去的时候的文字说明提示*/
	public class MessageTip extends Sprite
	{
		private static var _instance:MessageTip;
		private var label:TextField;
		private var area:DisplayObject;
		private var textWidth:uint;
		private var textHeight:uint;
		public function MessageTip()
		{
			super();
			label = new TextField();
			label.autoSize = TextFieldAutoSize.CENTER;
			label.selectable = false;
			label.multiline = true;
			label.wordWrap = true;
			label.defaultTextFormat =  new TextFormat("宋体", 12, 0xffffff);
			label.text = "提示信息";
			label.x= 3;
			label.y = 3;
			addChild(label);
			redraw();
			visible = false;
		}
		
		public static function getInstance():MessageTip{
			if(_instance == null){
				_instance = new MessageTip();
			}
			return _instance;
		}
		
		private function redraw():void{
			textWidth = 10 + label.textWidth;   
			textHeight = 10 + label.textHeight;   
			
			this.graphics.clear();   
			this.graphics.beginFill(0x888888,0.8);   
			this.graphics.drawRoundRect(0, 0, textWidth, textHeight, 10, 10);   
			this.graphics.endFill(); 
		}
		
		public function register(target:DisplayObject, message:String):void{
			if(_instance){
				var prop:AccessibilityProperties = new AccessibilityProperties();
				prop.description = message;
				target.accessibilityProperties = prop;
				Accessibility.updateProperties();
				target.addEventListener(MouseEvent.MOUSE_OVER, handler, false, 0, true);
			}
		}
		
		private function show(area:DisplayObject):void {   
			this.area = area;   
			this.area.addEventListener(MouseEvent.MOUSE_OUT, this.handler, false, 0, true);   
			this.area.addEventListener(MouseEvent.MOUSE_MOVE, this.handler, false, 0, true);   
			label.text = area.accessibilityProperties.description;   
			Accessibility.updateProperties();
			redraw();              
		}   
		
		private function move(point:Point):void {                
			var lp:Point = this.parent.globalToLocal(point);  
			var xpos:int = lp.x + 10;
			var ypos:int = lp.y + 10;
			if(lp.x + textWidth + 20 > 210){
				xpos = lp.x - textWidth - 10;
			}
			
			if(lp.y + textHeight + 20 > 77){
				ypos = lp.y - textHeight - 10;
			}
			this.x = xpos;            
			this.y = ypos;   
			if(!visible){   
				visible = true;   
			}   
		}   
		
		private function hide():void {   
			this.area.removeEventListener(MouseEvent.MOUSE_OUT, this.handler);   
			this.area.removeEventListener(MouseEvent.MOUSE_MOVE, this.handler);   
			visible = false; 
		}  
		
		private function handler(event:MouseEvent):void {   
			switch(event.type) {  
				case MouseEvent.MOUSE_OUT:   
					this.hide();   
					break;   
				case MouseEvent.MOUSE_MOVE:   
					this.move(new Point(event.stageX, event.stageY));                      
					break;   
				case MouseEvent.MOUSE_OVER:   
					this.show(event.currentTarget as DisplayObject);   
					this.move(new Point(event.stageX, event.stageY))   
					break;   
			}   
		}   
		
		public function unregister(target:DisplayObject):void {   
			if (_instance) {   
				target.removeEventListener(MouseEvent.MOUSE_OVER, handler);   
			}   
		}  
	}
}