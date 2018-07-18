package com.osmos {
    import com.osmos.game.Game;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;

    [SWF(width='1000', height='750', frameRate='60', backgroundColor='#FFFFFF')]
    public class Main extends Sprite {
        public function Main() {
            if (stage != null) {
                loadConfig();
            } else {
                addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            }
        }

        private function loadConfig():void {
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
            loader.load(new URLRequest('config.json'));
        }

        private function addedToStageHandler(e:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            loadConfig();
        }

        private function loaderCompleteHandler(e:Event):void {
            var loader:URLLoader = e.currentTarget as URLLoader;
            loader.removeEventListener(Event.COMPLETE, loaderCompleteHandler);

            var config:Object = JSON.parse(loader.data);

            var game:Game = new Game();
            game.create(stage, config);
        }
    }
}
