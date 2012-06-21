package org.tbyrne.composure.concerns;

import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.ITrait;

class Concern extends AbstractConcern
{

	public var unlessHasTraits:Array<Class<Dynamic>>;
	public var additionalTraits:Array<Class<Dynamic>>;
	public var stopDescendingAt:ComposeItem->Concern->Bool;
	public var stopAscendingAt:ComposeItem->Concern->Bool;

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
		var item:ComposeItem;
		if (Std.is(trait, ITrait)) {
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