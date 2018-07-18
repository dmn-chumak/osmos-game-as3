package com.osmos.gui {
    import com.osmos.game.Game;

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;

    import flashx.textLayout.formats.TextAlign;

    public class Menu extends Sprite {
        private var _titleTxt:TextField;
        private var _messageTxt:TextField;
        private var _playBtn:Sprite;
        private var _needRestart:Boolean;

        public function Menu() {
            var titleFormat:TextFormat = new TextFormat('Verdana', 30);
            titleFormat.align = TextAlign.CENTER;

            _titleTxt = new TextField();
            _titleTxt.defaultTextFormat = titleFormat;
            _titleTxt.selectable = false;
            _titleTxt.width = 100;
            _titleTxt.height = 50;
            _titleTxt.text = 'osmos';
            addChild(_titleTxt);

            var mainFormat:TextFormat = new TextFormat('Verdana', 12);
            mainFormat.align  = TextAlign.CENTER;

            _messageTxt = new TextField();
            _messageTxt.defaultTextFormat = mainFormat;
            _messageTxt.selectable = false;
            _messageTxt.width = 100;
            _messageTxt.height = 30;
            _messageTxt.y = 50;
            addChild(_messageTxt);

            _playBtn = new Sprite();
            _playBtn.graphics.beginFill(0x6666FF);
            _playBtn.graphics.drawRoundRect(0, 0, 100, 30, 10, 10);
            _playBtn.graphics.endFill();
            _playBtn.y = 80;
            addChild(_playBtn);

            var playBtnTxt:TextField = new TextField();
            playBtnTxt.defaultTextFormat = mainFormat;
            playBtnTxt.selectable = false;
            playBtnTxt.width = 100;
            playBtnTxt.height = 30;
            playBtnTxt.text = 'play';
            playBtnTxt.y = 5;
            _playBtn.addChild(playBtnTxt);

            visible = false;
        }

        public function resize(width:uint, height:uint):void {
            var halfWidth:uint = width / 2;
            var halfHeight:uint = height / 2;

            _titleTxt.x = halfWidth - 50;
            _titleTxt.y = halfHeight - 50;

            _messageTxt.x = halfWidth - 50;
            _messageTxt.y = halfHeight;

            _playBtn.x = halfWidth - 50;
            _playBtn.y = halfHeight + 30;

            graphics.beginFill(0x000000, .5);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();

            graphics.beginFill(0xFFFFFF);
            graphics.drawRect(halfWidth - 60, halfHeight - 60, 120, 140);
            graphics.endFill();
        }

        public function showStartScreen():void {
            _needRestart = false;
            _messageTxt.text = 'WELCOME';
            visible = true;
        }

        public function showLostScreen():void {
            _needRestart = true;
            _messageTxt.text = 'YOU LOST';
            visible = true;
        }

        public function showWonScreen():void {
            _needRestart = true;
            _messageTxt.text = 'YOU WON';
            visible = true;
        }

        public function activate():void {
            _playBtn.addEventListener(MouseEvent.CLICK, mouseClickHandler);
        }

        public function deactivate():void {
            _playBtn.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
        }

        private function mouseClickHandler(e:MouseEvent):void {
            e.stopImmediatePropagation();
            visible = false;

            if (_needRestart) {
                Game.instance.restart();
            }

            Game.instance.resume();
        }
    }
}
