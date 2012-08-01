package composure.injectors;

import org.tbyrne.collections.UniqueList;
import composure.core.ComposeItem;
import composure.traits.ITrait;


class AbstractInjector implements IInjector
{

	
	public var addHandler:Dynamic;
	public var removeHandler:Dynamic;
	
	public var siblings:Bool;
	public var descendants:Bool;
	public var ascendants:Bool;
	public var acceptOwnerTrait:Bool;
	
	public var interestedTraitType:Class<Dynamic>;


	public var ownerTrait:Dynamic;
	public var passThroughInjector:Bool;
	public var passThroughItem:Bool;

	private var _addedTraits:UniqueList<Dynamic>;

	public function new(interestedTraitType:Class<Dynamic>, addHandler:Dynamic, removeHandler:Dynamic, siblings:Bool=true, descendants:Bool=false, ascendants:Bool=false){
		this.addHandler = addHandler;
		this.removeHandler = removeHandler;
		
		this.siblings = siblings;
		this.descendants = descendants;
		this.ascendants = ascendants;
		this.interestedTraitType = interestedTraitType;
		_addedTraits = new UniqueList<Dynamic>();
		passThroughInjector = false;
		passThroughItem = false;
	}



	public function injectorAdded(trait:Dynamic, item:ComposeItem):Void {
		if (_addedTraits.add(trait) && addHandler != null) {
			if (passThroughInjector) {
				if(passThroughItem){	
					addHandler(this, trait, item);
				}else {
					addHandler(this, trait);
				}
			}else {
				if(passThroughItem){	
					addHandler(trait, item);
				}else {	
					addHandler(trait);
				}
			}
		}
	}

	public function injectorRemoved(trait:Dynamic, item:ComposeItem):Void{
		if (_addedTraits.remove(trait) && removeHandler!=null) {
			if (passThroughInjector) {
				if (passThroughItem) {
					removeHandler(this, trait, item);
				}else{
					removeHandler(this, trait);
				}
			}else {
				if (passThroughItem) {
					removeHandler(trait, item);
				}else{
					removeHandler(trait);
				}
			}
		}
	}

	private function itemMatchesAll(item:ComposeItem, traitTypes:Array<Class<Dynamic>>):Bool{
		for(traitType in traitTypes){
			if(item.getTrait(traitType)==null){
				return false;
			}
		}
		return true;
	}
	private function itemMatchesAny(item:ComposeItem, traitTypes:Array<Class<Dynamic>>):Bool{
		for(traitType in traitTypes){
			if(item.getTrait(traitType)!=null){
				return true;
			}
		}
		return false;
	}
	public function shouldDescend(item:ComposeItem):Bool{
		// override me
		return true;
	}
	public function shouldAscend(item:ComposeItem):Bool{
		// override me
		return true;
	}
	public function isInterestedIn(item:ComposeItem, trait:Dynamic):Bool {
		return Std.is(trait, interestedTraitType);
	}
}