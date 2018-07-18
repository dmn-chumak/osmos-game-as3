package com.osmos.utils {
    public class Color {
        private var _color:int;
        private var _r:Number;
        private var _g:Number;
        private var _b:Number;

        public function Color(color:int = 0xFFFFFF) {
            this.color = color;
        }

        public static function validate(color:Color):void {
            color._color = (
                  (color._r * 0xFF << 16)
                | (color._g * 0xFF <<  8)
                | (color._b * 0xFF)
            );
        }

        public static function createFromRange(color1:Color, color2:Color, range:Number):Color {
            var color:Color = new Color();

            color._r = color1._r * (1 - range) + color2._r * range;
            color._g = color1._g * (1 - range) + color2._g * range;
            color._b = color1._b * (1 - range) + color2._b * range;

            validate(color);

            return color;
        }

        public static function createFromArray(array:Array):Color {
            var color:Color = new Color();

            color._r = (int(array[0]) & 0xFF) / 0xFF;
            color._g = (int(array[1]) & 0xFF) / 0xFF;
            color._b = (int(array[2]) & 0xFF) / 0xFF;

            validate(color);

            return color;
        }

        public function set color(value:int):void {
            _color = value;
            _r = (value >> 16 & 0xFF) / 0xFF;
            _g = (value >>  8 & 0xFF) / 0xFF;
            _b = (value       & 0xFF) / 0xFF;
        }

        public function get color():int {
            return _color;
        }

        public function set r(value:Number):void {
            _color = (_color & 0x00FFFF) | (value * 0xFF) << 16;
            _r = value;
        }

        public function get r():Number {
            return _r;
        }

        public function set g(value:Number):void {
            _color = (_color & 0xFF00FF) | (value * 0xFF) << 8;
            _g = value;
        }

        public function get g():Number {
            return _g;
        }

        public function set b(value:Number):void {
            _color = (_color & 0xFFFF00) | (value * 0xFF);
            _b = value;
        }

        public function get b():Number {
            return _b;
        }
    }
}
