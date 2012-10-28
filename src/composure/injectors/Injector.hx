package composure.injectors;

import composure.core.ComposeItem;
import composure.traits.ITrait;

class Injector extends AbstractInjector
{

	public function new(traitType:Dynamic, addHandler:Dynamic, removeHandler:Dynamic, siblings:Bool = true, descendants:Bool = false, ascendants:Bool = false, universal:Bool = false) {
		super(traitType, addHandler, removeHandler, siblings, descendants, ascendants, universal);
	}


}