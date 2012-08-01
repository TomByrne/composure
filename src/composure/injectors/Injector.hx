package composure.injectors;

import composure.core.ComposeItem;
import composure.traits.ITrait;

class Injector extends AbstractInjector
{
	public var matchTrait:ComposeItem->Dynamic->Injector->Bool;
	public var stopDescendingAt:ComposeItem->Dynamic->Injector->Bool;
	public var stopAscendingAt:ComposeItem->Dynamic->Injector->Bool;

	public var maxMatches:Int;

	public function new(interestedTraitType:Class<Dynamic>, addHandler:Dynamic, removeHandler:Dynamic, siblings:Bool=true, descendants:Bool=false, ascendants:Bool=false){
		super(interestedTraitType, addHandler, removeHandler, siblings, descendants, ascendants);
		
		maxMatches = -1;
	}


	override public function shouldDescend(item:ComposeItem):Bool{
		if(stopDescendingAt!=null){
			return !stopDescendingAt(item,null,this);
		}else{
			return true;
		}
	}
	override public function shouldAscend(item:ComposeItem):Bool{
		if(stopAscendingAt!=null){
			return !stopAscendingAt(item,null,this);
		}else{
			return true;
		}
	}
	override public function isInterestedIn(item:ComposeItem, trait:Dynamic):Bool {
		return  	(super.isInterestedIn(item, trait) &&
					(matchTrait == null || matchTrait(item, trait, this)) &&
					(maxMatches==-1 || _addedTraits.length<maxMatches));
	}
}