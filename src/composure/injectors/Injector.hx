package composure.injectors;

import composure.core.ComposeItem;
import composure.traits.ITrait;

class Injector extends AbstractInjector
{

	public var unlessHasTraits:Array<Class<Dynamic>>;
	public var additionalTraits:Array<Class<Dynamic>>;
	public var stopDescendingAt:ComposeItem->Injector->Bool;
	public var stopAscendingAt:ComposeItem->Injector->Bool;

	public var matchProps:Hash<Dynamic>;
	public var maxMatches:Int;

	public function new(interestedTraitType:Class<Dynamic>, addHandler:Dynamic, removeHandler:Dynamic, siblings:Bool=true, descendants:Bool=false, ascendants:Bool=false){
		super(interestedTraitType, addHandler, removeHandler, siblings, descendants, ascendants);
		
		maxMatches = -1;
	}


	override public function shouldDescend(item:ComposeItem):Bool{
		if(stopDescendingAt!=null){
			return !stopDescendingAt(item,this);
		}else{
			return true;
		}
	}
	override public function shouldAscend(item:ComposeItem):Bool{
		if(stopAscendingAt!=null){
			return !stopAscendingAt(item,this);
		}else{
			return true;
		}
	}
	override public function isInterestedIn(trait:Dynamic):Bool {
		var item:ComposeItem = null;
		
		var getProxyTrait = Reflect.field(trait, "getProxiedTrait");
		if (getProxyTrait != null) {
			var proxy = trait.getProxiedTrait();
			if (Std.is(proxy, ITrait)) item = cast(proxy, ITrait).item;
		}
		
		if (item==null && Std.is(trait, ITrait)) {
			item = trait.item;
		}else {
			item = null;
		}
		
		return  (super.isInterestedIn(trait) &&
					(item==null || ((additionalTraits == null || itemMatchesAll(item, additionalTraits)) &&
					(unlessHasTraits == null || !itemMatchesAll(item, unlessHasTraits)) &&
					(matchProps == null || propsMatch(trait, matchProps)))) &&
				(maxMatches==-1 || _addedTraits.list.length<maxMatches));
	}
	
	private function propsMatch(trait:Dynamic, props:Hash<Dynamic>):Bool {
		for (i in props.keys()) {
			if (Reflect.field(trait, i) != props.get(i)) {
				return false;
			}
		}
		return true;
	}
}