package composureTest;
import composure.core.ComposeRoot;
import composure.prom.Promises.PromiseInfo;
import composure.traits.AbstractTrait;


class Promises
{
    static function main(){
		var root = new ComposeRoot();
		root.addTrait(new TestTrait());
		
		var obj1 = new SimpleObj1();
		root.addTrait(obj1);
		root.addTrait(new SimpleObj2());
		root.removeTrait(obj1);
	}
	
}

class TestTrait extends TestTraitBase {
	
	public function new() {
		super();
	}
	
	@promise("simpleObj1", "simpleObj2")
	private function onBothInjected2(met:Bool):Void {
		if (met) {
			trace("Both objects have been injected 2: "+simpleObj1+" "+simpleObj2);
		}else {
			trace("One of the objects is about to be removed 2: "+simpleObj1+" "+simpleObj2);
		}
	}
}

class TestTraitBase extends AbstractTrait {
	
	@inject
	public var simpleObj1:SimpleObj1;
	
	@inject
	public var simpleObj2:SimpleObj2;
	
	public function new() {
		super();
	}
	
	@promise("simpleObj1", "simpleObj2")
	private function onBothInjected(met:Bool):Void {
		if (met) {
			trace("Both objects have been injected: "+simpleObj1+" "+simpleObj2);
		}else {
			trace("One of the objects is about to be removed: "+simpleObj1+" "+simpleObj2);
		}
	}
}

class SimpleObj1 {
	public function new() {
		
	}
}

class SimpleObj2 {
	public function new() {
		
	}
}