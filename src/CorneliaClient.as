package 
{
	/**
	 * Cornelia Client
	 * 
	 * @author Freshek
	 */
	import flash.display.Sprite;
	import flash.events.Event;
	import com.hurlant.math.BigInteger;
	import flash.external.ExternalInterface;
	import com.hurlant.crypto.prng.ARC4;
	import com.hurlant.crypto.rsa.RSAKey;
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
	
	public class CorneliaClient 
	{
		public var ID:int = 100;
		
		private var swfActived:Boolean = false;
		private var rc4Actived:Boolean = false;
		
		private var encoder:Object;
		
		public var privateKey:BigInteger;
		
		private const ENC_BASE_GENERATOR:BigInteger = new BigInteger("ac2c3325cd2663e6cd7439ebda99e67e70b38fe8607871cc524599714ab41510ea1f311dd8e2acf8b46e158e61e7a7023ebc5f51f074f521271a697d773baa84");
		private const ENC_PRIME_MODULUS:BigInteger = new BigInteger("ba47695ced0f95a60dbb8a3cbfb44f21ea46681a181ad71c81da590ef4ffebd1a659ea71310e02398d7489c9de2f9de6e694ad54f9d85ac440bb1e167114ba99");
		
		private var currentEncodeAlgorithm:ARC4;
		private var currentDecodeAlgorithm:ARC4;
		
		public function CorneliaClient(param1:int) 
		{
			ID = param1;
		}
		
		public function HandleHandshakeResponse(param1:ByteArray):void
		{
			
			var _loc3_:ByteArray = null;
			var _loc4_:BigInteger = null;
			var _loc6_:BigInteger = null;
			var _loc7_:BigInteger = null;
			var _loc8_:ByteArray = null;
			var _loc2_:RSAKey = new RSAKey(new BigInteger("84c16e0a5860d56409207e6b542f168de24e434198e68b363dec817b77a594a17f968f177e871bfd626d139099cb3af0070cf2a03b46d1404503dc95d5a72f7c61e36b61967be50bd6bdf8d3376171b00fce65c521bc3267cdf7e6b0c3d725c9"),65537);
			_loc3_ = new ByteArray();
			_loc2_.verify(param1,_loc3_,param1.length);
			_loc3_.position = 0;
			_loc4_ = new BigInteger(_loc3_);
			_loc6_ = privateKey;
			_loc7_ = _loc4_.modPow(_loc6_,ENC_PRIME_MODULUS);
			_loc8_ = new ByteArray();
			_loc7_.toByteArray().readBytes(_loc8_, 0, 16);
			SetRc4Secret(_loc8_);
		}
		
		private function SetRc4Secret(param1:ByteArray):void
		{
			currentEncodeAlgorithm = new ARC4();
			currentDecodeAlgorithm = new ARC4();
			
			currentEncodeAlgorithm.init(param1);
			currentDecodeAlgorithm.init(param1);
			
			rc4Actived = true;
		}
		
		public function Wrap(swf:ByteArray):void
		{
			var loader:Loader = new Loader();
			var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
			loaderInfo.addEventListener(Event.COMPLETE, done);
			loader.loadBytes(swf);
		}
		
		public function done(event:Event = null)
		{
			var loaderInfo:LoaderInfo = event.target as LoaderInfo;
			loaderInfo.removeEventListener(Event.COMPLETE, done);
			encoder = loaderInfo.content;
			swfActived = true;
			ExternalInterface.call("generated", ID);
		}
		
		public function Encode(param1:String):String
		{
			var decoded:ByteArray = Base64.decode(param1);
			if (rc4Actived)
			{
				currentEncodeAlgorithm.encrypt(decoded);
			}
			if (swfActived)
			{
				decoded = encoder.encode(decoded);
			}
			return Base64.encode(decoded);
		}
		
		public function Decode(param1:String):String
		{
			var decoded:ByteArray = Base64.decode(param1);
			if (rc4Actived)
			{
				currentDecodeAlgorithm.decrypt(decoded);
			}
			if (swfActived)
			{
				decoded = encoder.decode(decoded);
			}
			return Base64.encode(decoded);
		}
		
		//We have loaded our swf, now we have to generate our key. Copy pasta from main.swf
		
		public function GenerateKey() : String
		{
		 var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc1_:String = new String();
		 for (var _loc2_:* = 0; _loc2_ < 128; _loc2_++)
         {
            _loc5_ = Math.random() * 256;
            _loc6_ = _loc5_.toString(16);
            if(_loc6_.length == 1)
            {
               _loc6_ = "0" + _loc6_;
            }
            _loc1_ = _loc1_ + _loc6_;
            _loc2_++;
         }
         privateKey = new BigInteger(_loc1_,16);
         var _loc3_:BigInteger = ENC_BASE_GENERATOR.modPow(privateKey, ENC_PRIME_MODULUS);
		 
		 return Base64.encode(_loc3_.toByteArray());
		 
		}
		
		public function Reset():void
		{
			swfActived = false;
			rc4Actived = false;
			currentDecodeAlgorithm = null;
			currentEncodeAlgorithm = null;
			encoder = null;
		}
		
	}

}