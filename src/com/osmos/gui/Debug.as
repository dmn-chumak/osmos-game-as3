package com.osmos.gui {
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class Debug extends Sprite {
        private var _counterTxt:TextField;

        public function Debug() {
            _counterTxt = new TextField();
            _counterTxt.defaultTextFormat = new TextFormat('Verdana', 12);
            _counterTxt.selectable = false;
            _counterTxt.width = 50;
            _counterTxt.height = 30;
            addChild(_counterTxt);
        }

        public function set frameRate(value:uint):void {
            _counterTxt.text = 'fps: ' + value;
        }
    }
}
