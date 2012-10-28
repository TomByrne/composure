package composure.injectors;

import composure.core.ComposeItem;
import composure.utilTraits.LazyTraitMap;

/**
 * ...
 * @author Tom Byrne
 */

class LazyInjector<MatchType> extends PropInjector
{
	private var _matchType:Class<MatchType>;

	public function new(interestedTraitType:Class<MatchType>, subject:Dynamic, prop:String, siblings:Bool = true, descendants:Bool = false, ascendants:Bool = false, universal:Bool = false, writeOnly:Bool=false) {
		_matchType = interestedTraitType;
		super(LazyTraitMap, subject, prop, siblings, descendants, ascendants, universal, writeOnly);
		
	}
	
	override private function addProp(trait:Dynamic):Void {
		
		if (isSet) return;
		if (!writeOnly) {
			if (Reflect.getProperty(subject, prop) != null) {
				// this means the value has been manually set into the target
				isSet = true;
				return;
			}
		}
		isSet = true;
		var traitMap:LazyTraitMap<MatchType> = cast trait;
		setTrait = traitMap.requestInstance(ownerTraitTyped.item);
		Reflect.setProperty(subject, prop, setTrait);
	}
	
	override private function removeProp(trait:Dynamic):Void {
		if (isSet && trait == setTrait) {
			var traitMap:LazyTraitMap<MatchType> = cast trait;
			traitMap.returnInstance(ownerTraitTyped.item, setTrait);
			setTrait = null;
			if (Reflect.getProperty(subject, prop) != null) {
				// this means the value has been manually set into the target
				isSet = true;
				return;
			}else{
				isSet = false;
				Reflect.setProperty(subject, prop, null);
			}
		}
	}
	
	override public function isInterestedIn(item:ComposeItem, trait:Dynamic):Bool {
		if (super.isInterestedIn(item, trait)) {
			var traitMap:LazyTraitMap<MatchType> = cast trait;
			return (traitMap.matchType == _matchType);
		}else {
			return false;
		}
	}
}