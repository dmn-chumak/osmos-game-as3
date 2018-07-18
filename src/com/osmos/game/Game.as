package com.osmos.game {
    import com.osmos.assets.Assets;
    import com.osmos.gui.Debug;
    import com.osmos.gui.Menu;
    import com.osmos.render.Entity;
    import com.osmos.render.Render;
    import com.osmos.utils.Color;

    import flash.display.Stage;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    public class Game {
        private static var _instance:Game;

        private var _config:Object;
        private var _enemyColor1:Color;
        private var _enemyColor2:Color;
        private var _playerColor:Color;

        private var _entities:Vector.<Entity>;
        private var _enemiesRadius:uint;
        private var _mouseDownTime:uint;
        private var _player:Entity;
        
        private var _render:Render;
        private var _stage:Stage;
        private var _isPaused:Boolean;

        private var _debug:Debug;
        private var _menu:Menu;

        private var _timeScale:Number;
        private var _lastFrameTime:uint;
        private var _deltaTime:Number;

        private var _framesCount:uint;
        private var _lastSecondTime:uint;
        private var _frameRate:uint;

        public function Game() {
            if (_instance != null) {
                throw new Error("Use Game.instance instead of new.");
            }

            _instance = this;
        }

        public static function get instance():Game {
            return (_instance != null) ? _instance : new Game();
        }

        public function create(stage:Stage, config:Object):void {
            if (_stage != null) {
                return;
            }

            _render = new Render();
            _render.requestContext(stage, stage.stageWidth, stage.stageHeight);

            _stage = stage;
            _stage.scaleMode = StageScaleMode.NO_SCALE;
            _stage.quality = StageQuality.HIGH;
            _stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            _stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            _stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            _stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            _stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);

            _debug = new Debug();
            _debug.frameRate = _stage.frameRate;
            _stage.addChild(_debug);

            _menu = new Menu();
            _menu.resize(_stage.stageWidth, _stage.stageHeight);
            _menu.activate();
            _menu.showStartScreen();
            _stage.addChild(_menu);

            _config = config;
            _enemyColor1 = Color.createFromArray(_config.enemy.color1);
            _enemyColor2 = Color.createFromArray(_config.enemy.color2);
            _playerColor = Color.createFromArray(_config.player.color);

            _entities = new <Entity>[];

            resetGameTime();
            resetFrameCounter();
            createEntities();

            _isPaused = true;
        }

        public function destroy():void {
            if (_stage == null) {
                return;
            }

            _stage.removeChild(_debug);
            _debug = null;

            _stage.removeChild(_menu);
            _menu.deactivate();
            _menu = null;

            _render.disposeContext();
            _render = null;

            _stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            _stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            _stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            _stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
            _stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
            _stage = null;

            _config = null;
            _enemyColor1 = null;
            _enemyColor2 = null;
            _playerColor = null;

            _entities = null;
        }

        public function restart():void {
            removeEntities();
            createEntities();
        }

        public function pause():void {
            _isPaused = true;
        }

        public function resume():void {
            _isPaused = false;
        }

        private function resetGameTime():void {
            _timeScale = 1;
            _lastFrameTime = getTimer();
            _deltaTime = 0;
        }

        private function resetFrameCounter():void {
            _framesCount = 0;
            _lastSecondTime = getTimer();
            _frameRate = 0;
        }

        private function createPlayer():void {
            _player = new Entity();
            _player.radius = _config.player.radius;
            _player.friction = _config.player.friction;
            _player.color = _playerColor;

            locateEntity(_player);

            _entities.push(_player);
        }

        private function createEnemies():void {
            var minRadius:uint = _config.enemy.minRadius;
            var maxRadius:uint = _config.enemy.maxRadius;
            var friction:Number = _config.enemy.friction;
            var maxForce:Number = _config.enemy.maxForce;
            var count:uint = _config.enemy.count;
            var enemy:Entity;

            _enemiesRadius = 0;

            for (var i:uint = 0; i < count; i++) {
                enemy = new Entity();
                enemy.radius = Math.random() * (maxRadius - minRadius) + minRadius;
                enemy.friction = friction;
                enemy.force.angle = Math.random() * Math.PI * 2;
                enemy.force.power = maxForce;

                locateEntity(enemy);

                _enemiesRadius += enemy.radius;
                _entities.push(enemy);
            }
        }

        private function createEntities():void {
            createPlayer();
            createEnemies();
        }

        private function removeEntities():void {
            _entities.length = 0;
            _player = null;
        }

        private function absorbEntity(absorber:Entity, food:Entity):void {
            Assets.playRandomDrop();

            absorber.absorbEntity(food);

            if (_isPaused) {
                return;
            }

            if (_player == absorber) {
                _enemiesRadius -= food.radiusWithFood;

                if (_player.radiusWithFood > _enemiesRadius) {
                    _menu.showWonScreen();
                    _isPaused = true;
                }
            } else if (_player == food) {
                _enemiesRadius += food.radiusWithFood;
                _menu.showLostScreen();
                _isPaused = true;
            } else {
                var availableFood:int = 0;
                var highestEntity:int = 0;

                var playerRadius:int = _player.radiusWithFood;
                var entityRadius:int;

                for each (var entity:Entity in _entities) {
                    if (entity == _player) continue;

                    entityRadius = entity.radiusWithFood;

                    if (entityRadius < playerRadius) {
                        availableFood += entityRadius;
                    } else if (highestEntity < entityRadius) {
                        highestEntity = entityRadius;
                    }
                }

                if (highestEntity > playerRadius + availableFood) {
                    _menu.showLostScreen();
                    _isPaused = true;
                }
            }
        }

        private function checkCollision(entity:Entity):Boolean {
            for each (var current:Entity in _entities) {
                if (entity != current && entity.checkCollision(current)) {
                    return true;
                }
            }

            return false;
        }

        private function locateEntity(entity:Entity):void {
            var width:Number = _stage.stageWidth;
            var height:Number = _stage.stageHeight;
            var radius:Number = entity.radius;

            do {
                entity.x = Math.random() * (width  - radius * 2) + radius;
                entity.y = Math.random() * (height - radius * 2) + radius;
            } while (checkCollision(entity));
        }

        private function enterFrameHandler(e:Event):void {
            updateGameTime();
            updateFrameCounter();

            if (!_isPaused) {
                updateEntities();
                applyAbsorption();
            }

            renderEntities();
        }

        private function updateGameTime():void {
            var currentTime:uint = getTimer();

            _deltaTime = (currentTime - _lastFrameTime) * _timeScale / 1000;
            _lastFrameTime = currentTime;

            if (_deltaTime > 1) {
                _deltaTime = 1;
            }
        }

        private function updateFrameCounter():void {
            var currentTime:uint = getTimer();

            _framesCount++;

            if (currentTime - _lastSecondTime > 1000) {
                _frameRate = _framesCount;
                _lastSecondTime += 1000;
                _framesCount = 0;

                _debug.frameRate = _frameRate;
            }
        }

        private function updateEntities():void {
            for each (var entity:Entity in _entities) {
                entity.updateFrame();
            }
        }

        private function applyAbsorption():void {
            var len:uint = _entities.length;
            var entity1:Entity;
            var entity2:Entity;

            for (var i:uint = 0; i < len; i++) {
                entity1 = _entities[i];

                for (var j:uint = i + 1; j < len; j++) {
                    entity2 = _entities[j];

                    if (entity1.checkCollision(entity2)) {
                        len--;

                        if (entity1.radius > entity2.radius) {
                            absorbEntity(entity1, entity2);
                            _entities.removeAt(j--);
                        } else {
                            absorbEntity(entity2, entity1);
                            _entities.removeAt(i--);
                            break;
                        }
                    }
                }
            }
        }

        private function renderEntities():void {
            _render.prepareContext();
            _render.prepareVertexes();

            var range:Number;

            for each (var entity:Entity in _entities) {
                if (entity != _player) {
                    range = Math.max(0, Math.min(1, entity.radius / _player.radius - 0.5));
                    entity.color = Color.createFromRange(_enemyColor1, _enemyColor2, range);
                }

                _render.renderEntity(entity);
            }

            _render.renderVertexes();
            _render.presentContext();
        }

        private function keyDownHandler(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.SPACE) {
                _timeScale = .5;
            }
        }

        private function keyUpHandler(e:KeyboardEvent):void {
            if (e.keyCode == Keyboard.SPACE) {
                _timeScale = 1;
            }
        }

        private function mouseDownHandler(e:MouseEvent):void {
            if (_isPaused) {
                return;
            }

            _mouseDownTime = getTimer();
        }

        private function mouseUpHandler(e:MouseEvent):void {
            if (_isPaused || _mouseDownTime == 0) {
                return;
            }

            var holdTime:uint = getTimer() - _mouseDownTime;
            var maxForce:Number = _config.player.maxForce;

            _player.force.angle = Math.atan2(_player.y - _stage.mouseY, _player.x - _stage.mouseX);
            _player.force.power = Math.min(maxForce, holdTime / 1000 * maxForce);

            _mouseDownTime = 0;
        }

        public function get config():Object {
            return _config;
        }

        public function get stage():Stage {
            return _stage;
        }

        public function set timeScale(value:Number):void {
            _timeScale = (value < 0) ? 0 : value;
        }

        public function get timeScale():Number {
            return _timeScale;
        }

        public function get deltaTime():Number {
            return _deltaTime;
        }

        public function get frameRate():uint {
            return _frameRate;
        }
    }
}
