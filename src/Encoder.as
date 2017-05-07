package
{
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
	import flash.external.ExternalInterface;
	
	/* actually not used. generator is bot-sided.
	 * 
	 * 
	 *
		*/
    public class Encoder extends EventDispatcher
    {
        private var HEADER_b:ByteArray;
        private var FINISHER_b:ByteArray;
        protected var _activated:Boolean;
        protected var _encoder:Object;
        public var generatedSWF:ByteArray;
        public static const MAX_INJECTION_LENGTH:uint = 4096 * 8;
        public static const HEADER_op:Array = [67, 87, 83, 11, 227, 11, 0, 0, 64, 3, 192, 3, 192, 0, 24, 1, 0, 68, 17, 25, 0, 0, 0, 198, 10, 97, 98, 99, 95, 65, 0];
        public static const FINISHER_op:Array = [10, 19, 1, 0, 0, 0, 100, 105, 100, 73, 68, 0, 64, 0, 0, 0];
		

        public function Encoder()
        {
            HEADER_b = new ByteArray();
            FINISHER_b = new ByteArray();
        }

        protected function prepareFINISHER_() : void
        {
            var _loc_3:* = 0;
            FINISHER_b = new ByteArray();
			for (var _loc_2:* = 0; _loc_2 < FINISHER_op.length; _loc_2++)
            {
                _loc_3 = FINISHER_op[_loc_2];
                FINISHER_b.writeByte(_loc_3);
            }
        }

        protected function prepareHEADER_() : void
        {
            var _loc_3:* = 0;
            HEADER_b = new ByteArray();
			for (var _loc_2:* = 0; _loc_2 < HEADER_op.length; _loc_2++)
            {
                _loc_3 = HEADER_op[_loc_2];
                HEADER_b.writeByte(_loc_3);
            }
        }

        public function injectAndBuild(param1:ByteArray, param2:uint) : void
        {
            if (param2 > 0)
            {
                writeFilesizeIntoHeader(param2);
            }
            if (param1.length < MAX_INJECTION_LENGTH)
            {
                buildAlgorithm(param1);
            }
        }

        private function writeFilesizeIntoHeader(param1:uint) : void
        {
            var _loc_2:* = param1 & 255;
            var _loc_3:* = (param1 & 255 * 256) >> 8;
            var _loc_4:* = (param1 & 255 * 256 * 256) >> 16;
            var _loc_5:* = (param1 & 255 * 256 * 256 * 256) >> 24;
            HEADER_op[4] = _loc_2;
            HEADER_op[5] = _loc_3;
            HEADER_op[6] = _loc_4;
            HEADER_op[7] = _loc_5;
        }

        private function buildAlgorithm(param1:ByteArray) : void
        {
            prepareCodeSegments();
            generatedSWF = new ByteArray();
            generatedSWF.writeBytes(HEADER_b);
            generatedSWF.writeBytes(param1);
            generatedSWF.writeBytes(FINISHER_b);
            loadAlgorithm();
        }

        private function prepareCodeSegments() : void
        {
            prepareHEADER_();
            prepareFINISHER_();
        }

        protected function loadAlgorithm() : void
        {
            var _loc_1:* = new Loader();
            var _loc_2:* = _loc_1.contentLoaderInfo;
            _loc_2.addEventListener(Event.COMPLETE, handleAlgorithmLoadFinished);
            _loc_2.addEventListener(IOErrorEvent.IO_ERROR, handleAlgorithmLoadIoError);
            _loc_1.loadBytes(generatedSWF);
			ExternalInterface.call("loaded");
        }

        private function handleAlgorithmLoadIoError(event:IOErrorEvent) : void
        {
			ExternalInterface.call("loaded");
            //IOError -> we don't active our wrapper
        }

        protected function handleAlgorithmLoadFinished(event:Event = null) : void
        {
            var _loc_2:* = event.target as LoaderInfo;
            _loc_2.removeEventListener(Event.COMPLETE, handleAlgorithmLoadFinished);
            _loc_2.removeEventListener(IOErrorEvent.IO_ERROR, handleAlgorithmLoadIoError);
            _encoder = _loc_2.content;
            activate();
			ExternalInterface.call("loaded");
        }

        public function decode(param1:ByteArray) : ByteArray
        {
            if (isActivated())
            {
                return _encoder.decode(param1);
            }
            return param1;
        }

        public function encode(param1:ByteArray) : ByteArray
        {
            if (_activated)
            {
                return _encoder.encode(param1);
            }
            return param1;
        }

        private function testDeAndEncoding() : void
        {
            var _loc_1:* = new ByteArray();
            _loc_1.writeByte(255);
            _loc_1.writeByte(0);
            var _loc_2:* = encode(_loc_1);
            var _loc_3:* = decode(_loc_2);
        }

        public function activate() : void
        {
            _activated = true;
        }

        public function deactivate() : void
        {
            _activated = false;
        }

        public function isActivated() : Boolean
        {
            return _activated;
        }
    }
}
