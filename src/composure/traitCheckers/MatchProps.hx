package composure.traitCheckers;
import composure.traits.ITrait;
import composure.core.ComposeItem;
import composure.injectors.Injector;

/**
 * ...
 * @author Tom Byrne
 */

class MatchProps 
{
	public static function create(matchProps:Map<String, Dynamic>):ComposeItem->Dynamic->Injector->Bool {
		return function(item:ComposeItem, trait:Dynamic, from:Injector):Bool {
			for (i in matchProps.keys()) {
				if (Reflect.field(trait, i) != matchProps.get(i)) {
					return false;
				}
			}
			return true;
		}
	}
	
}