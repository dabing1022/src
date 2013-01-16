package ui
{
	import fl.containers.UILoader;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import fl.core.InvalidationType;
	
	public class PlayerStatusCellRenderer extends UILoader implements ICellRenderer
	{
		protected var _data:Object;
		protected var _listData:ListData;
		protected var _selected:Boolean;
		public function PlayerStatusCellRenderer()
		{
			super();
		}
		
		public function get data():Object {
			return _data;
		}
		/** 
		 * @private (setter)
		 */
		public function set data(value:Object):void {
			_data = value;
			source = value.status;
		}
		/**
		 * Gets or sets the cell's internal _listData property.
		 */
		public function get listData():ListData {
			return _listData;
		}
		/**
		 * @private (setter)
		 */
		public function set listData(value:ListData):void {
			_listData = value;
			invalidate(InvalidationType.DATA);
			invalidate(InvalidationType.STATE);
			drawBackgroundColor();
		}
		
		private function drawBackgroundColor():void{
			graphics.beginFill(0x555555);
			graphics.lineStyle(0.1, 0x555555);
			graphics.drawRect(0,0,45,14);
			graphics.endFill();           
		}
		/**
		 * Gets or sets the cell's internal _selected property.
		 */
		public function get selected():Boolean {
			return _selected;
		}
		/**
		 * @private (setter)
		 */
		public function set selected(value:Boolean):void {
			_selected = value;
			invalidate(InvalidationType.STATE);
		}
		/**
		 * Sets the internal mouse state.
		 */
		public function setMouseState(state:String):void {
		}
	}
}