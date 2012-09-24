package composure.traitCheckers;
import composure.core.ComposeItem;
import composure.traits.ITrait;
import composure.injectors.Injector;

/**
 * @author Tom Byrne
 */

@:keep
class TraitTypeChecker 
{

	public static function createMulti(types:Array<Class<Dynamic>>, useOrCheck:Bool=false, invertResponse:Bool=false, ?unlessIsTraits:Array<Dynamic>, dontMatchFrom:Bool=true):ComposeItem->Dynamic->Injector->Bool{
		if (useOrCheck) {
			return function(item:ComposeItem, trait:Dynamic, from:Injector):Bool {
				for (type in types) {
					var otherTrait:Dynamic = item.getTrait(type);
					if (otherTrait != null && (unlessIsTraits==null || !contains(unlessIsTraits,otherTrait)) && (dontMatchFrom==false || otherTrait!=trait)) {
						return !invertResponse;
					}
				}
				return invertResponse;
			}
		}else {
			return function(item:ComposeItem, trait:Dynamic, from:Injector):Bool {
				for (type in types) {
					var otherTrait:Dynamic = item.getTrait(type);
					if (otherTrait == null || (unlessIsTraits!=null && contains(unlessIsTraits,otherTrait)) || (dontMatchFrom==true && otherTrait==trait)) {
						return invertResponse;
					}
				}
				return !invertResponse;
			}
		}
	}
	public static function create(type:Class<Dynamic>, invertResponse:Bool=false, ?unlessIsTrait:Dynamic, dontMatchFrom:Bool=true):ComposeItem->Dynamic->Injector->Bool {
		return function(item:ComposeItem, trait:Dynamic, from:Injector):Bool {
			var otherTrait:Dynamic = item.getTrait(type);
			if (otherTrait != null && (unlessIsTrait==null || unlessIsTrait!=otherTrait) && (dontMatchFrom==false || otherTrait!=trait)) {
				return !invertResponse;
			}
			return invertResponse;
		}
	}
	private static function contains(traits:Array<Dynamic>, trait:Dynamic):Bool {
		for (otherTrait in traits) if (otherTrait == trait) return true;
		return false;
	}
	
}