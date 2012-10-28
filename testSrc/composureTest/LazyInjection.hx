package composureTest;
import composure.core.ComposeItem;
import composure.core.ComposeRoot;
import composure.utilTraits.LazyTraitMap;

/**
 * ...
 * @author Tom Byrne
 */

class LazyInjection 
{
    static function main(){
		var root = new ComposeRoot();
		root.addTrait(new LazyTraitMap(ILazyInterface, FClass(LazyClass)));
		
		root.addTrait(new TestTrait());
		root.addChild(new ComposeItem([new TestTrait()]));
	}
	
}

interface ILazyInterface {
	
}

class LazyClass implements ILazyInterface {
	
	public function new() {
		trace("I am");
	}
}

import composure.traits.AbstractTrait;
class TestTrait extends AbstractTrait {
	
	@inject({lazy:true, asc:true})
	public var lazyObject:ILazyInterface;
	
	public function new() {
		super();
	}
}