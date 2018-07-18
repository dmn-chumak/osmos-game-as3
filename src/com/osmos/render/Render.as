package com.osmos.render {
    import com.adobe.utils.AGALMiniAssembler;
    import com.osmos.utils.Color;

    import flash.display.Stage;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DBufferUsage;
    import flash.display3D.Context3DProfile;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Matrix3D;

    public class Render extends EventDispatcher {
        private static const _assembler:AGALMiniAssembler = new AGALMiniAssembler();

        private static const _constants:Vector.<Number> = new <Number>[ 0, .25, .5, 1 ];
        private static const _bounds:Vector.<Number> = new <Number>[ -.5, -.5, .5, -.5, .5, .5, -.5, .5 ];

        private var _stage3D:Stage3D;
        private var _context3D:Context3D;
        private var _program3D:Program3D;
        private var _state3D:Matrix3D;

        private var _vertexVector:Vector.<Number>;
        private var _vertexNumberMax:uint;
        private var _vertexNumber:uint;
        private var _vertexBuffer:VertexBuffer3D;

        private var _indexVector:Vector.<uint>;
        private var _indexNumberMax:uint;
        private var _indexNumber:uint;
        private var _indexBuffer:IndexBuffer3D;

        private var _isRequesting:Boolean;
        private var _color:Color;
        private var _width:uint;
        private var _height:uint;

        public function Render() {
            _vertexVector = new <Number>[];
            _indexVector = new <uint>[];
        }

        public function requestContext(stage:Stage, width:uint = 800, height:uint = 600):void {
            if (_stage3D != null) {
                return;
            }

            _isRequesting = true;
            _color = new Color(stage.color);
            _width = width;
            _height = height;

            _stage3D = stage.stage3Ds[0];
            _stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextCreateHandler);
            _stage3D.addEventListener(ErrorEvent.ERROR, contextErrorHandler);

            _stage3D.requestContext3DMatchingProfiles(
                new <String>[
                    Context3DProfile.STANDARD_CONSTRAINED,
                    Context3DProfile.STANDARD,
                    Context3DProfile.BASELINE_EXTENDED
                ]
            );
        }

        public function disposeContext():void {
            if (_stage3D == null || _isRequesting) {
                return;
            }

            _color = null;
            _width = 0;
            _height = 0;

            _stage3D.removeEventListener(Event.CONTEXT3D_CREATE, contextCreateHandler);
            _stage3D.removeEventListener(ErrorEvent.ERROR, contextErrorHandler);
            _stage3D = null;

            _program3D = null;
            _state3D = null;

            _vertexVector.length = 0;
            _vertexNumberMax = 0;
            _vertexNumber = 0;
            _vertexBuffer = null;

            _indexVector.length = 0;
            _indexNumberMax = 0;
            _indexNumber = 0;
            _indexBuffer = null;

            if (_context3D != null) {
                _context3D.dispose(false);
                _context3D = null;
            }
        }

        public function renderEntity(entity:Entity):void {
            var diameter:Number = entity.radius * 2;
            var offset:uint = _vertexNumber * 8;

            for (var i:uint = 0; i < 8; i += 2) {
                _vertexVector[offset++] = _bounds[i    ] * diameter + entity.x;
                _vertexVector[offset++] = _bounds[i + 1] * diameter + entity.y;

                _vertexVector[offset++] = _bounds[i    ];
                _vertexVector[offset++] = _bounds[i + 1];

                _vertexVector[offset++] = entity.color.r;
                _vertexVector[offset++] = entity.color.g;
                _vertexVector[offset++] = entity.color.b;
                _vertexVector[offset++] = 1;
            }

            _vertexNumber += 4;
            _indexNumber += 6;
        }

        public function prepareContext():void {
            if (_context3D == null) {
                return;
            }

            _context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
            _context3D.setProgram(_program3D);
            _context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _state3D, true);
            _context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _constants);
            _context3D.clear(_color.r, _color.g, _color.b);
        }

        public function presentContext():void {
            if (_context3D == null) {
                return;
            }

            _context3D.present();
        }

        public function prepareVertexes():void {
            _vertexNumber = 0;
            _indexNumber = 0;
        }

        public function renderVertexes():void {
            if (_context3D == null) {
                return;
            }

            if (_vertexNumber == 0) {
                return;
            }

            if (_vertexNumber > _vertexNumberMax) {
                if (_vertexBuffer != null) {
                    _vertexBuffer.dispose();
                    _indexBuffer.dispose();
                }

                for (var i:uint = _indexNumberMax, j:uint = _vertexNumberMax; i < _indexNumber; i += 6, j += 4) {
                    _indexVector[i + 0] = j + 0;
                    _indexVector[i + 1] = j + 1;
                    _indexVector[i + 2] = j + 2;
                    _indexVector[i + 3] = j + 2;
                    _indexVector[i + 4] = j + 3;
                    _indexVector[i + 5] = j + 0;
                }

                _indexBuffer = _context3D.createIndexBuffer(_indexNumber, Context3DBufferUsage.STATIC_DRAW);
                _indexBuffer.uploadFromVector(_indexVector, 0, _indexNumber);
                _indexNumberMax = _indexNumber;

                _vertexBuffer = _context3D.createVertexBuffer(_vertexNumber, 8, Context3DBufferUsage.DYNAMIC_DRAW);
                _vertexNumberMax = _vertexNumber;
            }

            _vertexBuffer.uploadFromVector(_vertexVector, 0, _vertexNumber);

            _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
            _context3D.setVertexBufferAt(1, _vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
            _context3D.setVertexBufferAt(2, _vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4);

            _context3D.drawTriangles(_indexBuffer, 0, _indexNumber / 3);
        }

        private function contextCreateHandler(e:Event):void {
            _context3D = _stage3D.context3D;
            _context3D.configureBackBuffer(_width, _height, 0, false);

            _state3D = new Matrix3D();
            _state3D.appendTranslation(-_width / 2, -_height / 2, 0);
            _state3D.appendScale(2 / _width, -2 / _height, 1);

            _program3D = _context3D.createProgram();
            _program3D.upload(
                _assembler.assemble(
                    Context3DProgramType.VERTEX,
                    [
                        'm44 op, va0, vc0',
                        'mov v0, va1',
                        'mov v1, va2'
                    ].join('\n')
                ),
                _assembler.assemble(
                    Context3DProgramType.FRAGMENT,
                    [
                        'mul ft0.xy, v0.xy,  v0.xy',
                        'add ft0.x,  ft0.x,  ft0.y',
                        'slt ft0.z,  ft0.x,  fc0.y',
                        'mul oc,     v1,     ft0.z'
                    ].join('\n')
                )
            );

            _isRequesting = false;
        }

        private function contextErrorHandler(e:Event):void {
            _isRequesting = false;
            disposeContext();
        }
    }
}
