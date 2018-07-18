package com.osmos.utils {
    public class Force {
        private var _angle:Number;
        private var _power:Number;
        private var _x:Number;
        private var _y:Number;

        public function Force(angle:Number = 0, power:Number = 0) {
            this.angle = angle;
            this.power = power;
        }

        public function set angle(value:Number):void {
            _angle = value;
            _x = Math.cos(value);
            _y = Math.sin(value);
        }

        public function get angle():Number {
            return _angle
        }

        public function set power(value:Number):void {
            _power = (value < 0) ? -value : value;
        }

        public function get power():Number {
            return _power;
        }

        public function set y(value:Number):void {
            _angle = Math.atan2(value, _x);
            _y = value;
        }

        public function get y():Number {
            return _y;
        }

        public function set x(value:Number):void {
            _angle = Math.atan2(_y, value);
            _x = value;
        }

        public function get x():Number {
            return _x;
        }
    }
}
