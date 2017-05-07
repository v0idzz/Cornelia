package
{
	import adobe.utils.CustomActions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import com.hurlant.math.BigInteger;
	import flash.external.ExternalInterface;
	import com.hurlant.crypto.prng.ARC4;
	import com.hurlant.crypto.rsa.RSAKey;
	
	/**
	 * Decrypts and encrypts packets/eventstream.
	 * 
	 * Cornelia.
	 * 
	 * @author Freshek
	 */
	public class Main extends Sprite
	{
		
		private var clients:Vector.<CorneliaClient> = new Vector.<CorneliaClient>();
		
		public function Main() 
		{
			init();
		}
		
		private function init(e:Event = null):void 
		{
			ExternalInterface.addCallback("ready", connectCornelia);
			ExternalInterface.addCallback("addClient", addClient);
			
			ExternalInterface.addCallback("generateKey", generateKey);
			
			ExternalInterface.addCallback("loadSwf", wrap);
			ExternalInterface.addCallback("handleHandshake", handleHandshake);
			
			ExternalInterface.addCallback("encode", encode);
			ExternalInterface.addCallback("decode", decode);
			
			ExternalInterface.addCallback("reset", reset);
		}
		
		
		public function connectCornelia():void
		{
			//test if connection swf->c# works correctly
			//you can put anything here
			//I don't use it
		}
		
		public function addClient():int
		{
			var id:int = clients.length;
			var cornelia:CorneliaClient = new CorneliaClient(id);
			clients.push(cornelia);
			return id;
		}
		
		public function generateKey(id:Number):String
		{
			return clients[id].GenerateKey();
		}
		
		public function encode(data:String, id:Number):String
		{
			return clients[id].Encode(data);
		}
		
		public function decode(data:String, id:Number):String
		{
			return clients[id].Decode(data);
		}
		
		public function wrap(swf:String, id:Number):void
		{
			var data:ByteArray = Base64.decode(swf);
			clients[id].Wrap(data);
		}
		
		public function handleHandshake(code:String, id:Number):void
		{
			var data:ByteArray = Base64.decode(code);
			clients[id].HandleHandshakeResponse(data);
		}
		
		public function decodeEventStream(param1:String):String
		{
			var bytes:ByteArray = Base64.decode(param1);
			bytes.uncompress();
			var _loc1_:String;
			_loc1_ = bytes.readUTFBytes(bytes.length);
			return _loc1_;
		}
		
		public function encodeEventStream(param1:String):String
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(param1);
			bytes.compress();
			return Base64.encode(bytes);
		}
		
		public function reset(id:Number):void
		{
			clients[id].Reset();
		}
	}
	
}