package com.osmos.render {
    import com.osmos.game.Game;
    import com.osmos.utils.Color;
    import com.osmos.utils.Force;

    public class Entity {
        private var _force:Force;
        private var _friction:Number;
        private var _radius:uint;

        private var _absorbTime:Number;
        private var _food:uint;

        public var color:Color;
        public var x:Number;
        public var y:Number;

        public function Entity() {
            _force = new Force();
            _friction = 0;
            _radius = 0;

            _absorbTime = Game.instance.config.entity.absorbTime;
            _food = 0;

            color = new Color();
            x = 0;
            y = 0;
        }

        public function updateFrame():void {
            applyFriction();
            applyAbsorption();
            applyForce();
        }

        private function applyFriction():void {
            _force.power *= 1 - _friction * Game.instance.deltaTime;
        }

        private function applyAbsorption():void {
            if (_food > 0) {
                _absorbTime -= Game.instance.deltaTime;

                if (_absorbTime < 0) {
                    _absorbTime += Game.instance.config.entity.absorbTime;
                    _food--;
                    _radius++;
                }
            }
        }

        private function applyForce():void {
            var currentSpeed:Number = _force.power * Game.instance.deltaTime * (2 / _radius);

            var deltaX:Number = currentSpeed * Math.cos(_force.angle);
            var deltaY:Number = currentSpeed * Math.sin(_force.angle);

            var width:Number = Game.instance.stage.stageWidth;
            var height:Number = Game.instance.stage.stageHeight;

            if (x + deltaX > width - _radius) {
                deltaX = -(x - (width - _radius) + deltaX);
                _force.x = -_force.x;
            } else if (x + deltaX < _radius) {
                deltaX = -(x - _radius + deltaX);
                _force.x = -_force.x;
            }

            if (y + deltaY > height - _radius) {
                deltaY = -(y - (height - _radius) + deltaY);
                _force.y = -_force.y;
            } else if (y + deltaY < _radius) {
                deltaY = -(y - _radius + deltaY);
                _force.y = -_force.y;
            }

            x += deltaX;
            y += deltaY;
        }

        public function checkCollision(entity:Entity):Boolean {
            var deltaX:Number = entity.x - x;
            var deltaY:Number = entity.y - y;

            var currentDistance:Number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
            var collideDistance:Number = entity._radius + _radius;

            return currentDistance < collideDistance;
        }

        public function absorbEntity(food:Entity):void {
            _food += food._radius + food._food;
        }

        public function set friction(value:Number):void {
            _friction = (value > 1) ? 1 : value;
        }

        public function get friction():Number {
            return _friction;
        }

        public function get force():Force {
            return _force;
        }

        public function get radiusWithFood():uint {
            return _radius + _food;
        }

        public function set radius(value:uint):void {
            _radius = value;
        }

        public function get radius():uint {
            return _radius;
        }
    }
}
