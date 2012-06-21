package org.tbyrne.composure.concerns;

import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.ITrait;


class AbstractConcern implements IConcern
{

	
	public var addHandler:Dynamic;
	public var removeHandler:Dynamic;
	
	public var siblings:Bool;
	public var descendants:Bool;
	public var ascendants:Bool;
	public var acceptOwnerTrait:Bool;
	
	public var interestedTraitType:Class<Dynamic>;


	public var ownerTrait:ITrait;
	public var passThroughConcern:Bool;
	public var passThroughItem:Bool;

	private var _addedTraits:IndexedList<Dynamic>;

	public function new(interestedTraitType:Class<Dynamic>, addHandler:Dynamic, removeHandler:Dynamic, siblings:Bool=true, descendants:Bool=false, ascendants:Bool=false){
		this.addHandler = addHandler;
		this.removeHandler = removeHandler;
		
		this.siblings = siblings;
		this.descendants = descendants;
		this.ascendants = ascendants;
		this.interestedTraitType = interestedTraitType;
		_addedTraits = new IndexedList<Dynamic>();
		passThroughConcern = false;
		passThroughItem = false;
	}



	public function concernAdded(trait:Dynamic, item:ComposeItem):Void{
		if (_addedTraits.add(trait) && addHandler != null) {
			if (passThroughConcern) {
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

	public function concernRemoved(trait:Dynamic, item:ComposeItem):Void{
		if (_addedTraits.remove(trait) && removeHandler!=null) {
			if (passThroughConcern) {
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
	public function isInterestedIn(trait:Dynamic):Bool {
		return Std.is(trait, interestedTraitType);
	}
}