package composure.utils;
import composure.core.ComposeItem;
import composure.traits.ITrait;
import composure.injectors.Injector;

/**
 * @author Tom Byrne
 */

class TraitChecker 
{

	public static function createTraitCheck(types:Array<Dynamic>, ?useOrCheck:Bool):ComposeItem->Injector->Bool {
		if (useOrCheck) {
			return function(item:ComposeItem, from:Injector):Bool {
				for (type in types) {
					if (item.getTrait(type) != null) {
						return true;
					}
				}
				return false;
			}
		}else {
			return function(item:ComposeItem, from:Injector):Bool {
				for (type in types) {
					if (item.getTrait(type) == null) {
						return false;
					}
				}
				return true;
			}
		}
	}
	
}