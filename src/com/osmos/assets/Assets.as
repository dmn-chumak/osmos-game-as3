package com.osmos.assets {
    import flash.media.Sound;

    public class Assets {
        [Embed(source="drop_1.mp3", mimeType="audio/mpeg")]
        private static var Drop1Sound:Class;
        [Embed(source="drop_2.mp3", mimeType="audio/mpeg")]
        private static var Drop2Sound:Class;
        [Embed(source="drop_3.mp3", mimeType="audio/mpeg")]
        private static var Drop3Sound:Class;

        private static var _dropSounds:Vector.<Sound>;
        private static var _initialized:Boolean;

        public static function initialize():void {
            if (_initialized) {
                return;
            }

            _dropSounds = new <Sound>[ new Drop1Sound(), new Drop2Sound(), new Drop3Sound() ];
            _initialized = true;
        }

        public static function playRandomDrop():void {
            if (!_initialized) {
                initialize();
            }

            var randomIndex:uint = Math.random() * _dropSounds.length;
            _dropSounds[randomIndex].play();
        }
    }
}
