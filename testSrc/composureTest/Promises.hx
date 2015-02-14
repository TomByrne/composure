package composureTest;
import composure.core.ComposeRoot;
import composure.prom.Promises.PromiseInfo;
import composure.traits.AbstractTrait;
import flash.geom.Point;
import flash.utils.Dictionary;


class Promises
{
    static function main(){
		var root = new ComposeRoot();
		root.addTrait(new TestTrait());
		
		var point = new Point();
		root.addTrait(point);
		root.addTrait(new Dictionary());
		root.removeTrait(point);
	}
	
}

class TestTrait extends TestTraitBase {
	
	public function new() {
		super();
	}
	
	private override function __getPromiseInfo():Array<composure.prom.Promises.PromiseInfo> {
		var ret:Array<composure.prom.Promises.PromiseInfo> = super.__getPromiseInfo();
		ret.push( { methodName:"onBothInjected2", requirements:[composure.prom.Promises.PromiseReq.RProp("point"), composure.prom.Promises.PromiseReq.RProp("dictionary")] } );
		return ret;
	}
	
	@promise("point", "dictionary")
	private function onBothInjected2(met:Bool):Void {
		if (met) {
			trace("Both point and dictionary have been injected 2: "+point+" "+dictionary);
		}else {
			trace("Either point or dictionary is about to be removed 2: "+point+" "+dictionary);
		}
	}
}

class TestTraitBase extends AbstractTrait {
	
	@inject
	public var point:Point;
	
	@inject
	public var dictionary:Dictionary;
	
	public function new() {
		super();
	}
	
	private function __getPromiseInfo():Array<composure.prom.Promises.PromiseInfo> {
		var ret:Array<composure.prom.Promises.PromiseInfo> = [];
		ret.push( { methodName:"onBothInjected", requirements:[composure.prom.Promises.PromiseReq.RProp("point"), composure.prom.Promises.PromiseReq.RProp("dictionary")] } );
		return ret;
	}
	
	@promise("point", "dictionary")
	private function onBothInjected(met:Bool):Void {
		if (met) {
			trace("Both point and dictionary have been injected: "+point+" "+dictionary);
		}else {
			trace("Either point or dictionary is about to be removed: "+point+" "+dictionary);
		}
	}
}