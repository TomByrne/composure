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
	public var universal:Bool;
	public var acceptOwnerTrait:Bool;
	
	public var matchTrait:ComposeItem->Dynamic->AbstractInjector->Bool;
	public var stopDescendingAt:ComposeItem->Dynamic->AbstractInjector->Bool;
	public var stopAscendingAt:ComposeItem->Dynamic->AbstractInjector->Bool;
	
	public var checkEnumParams:Array<Int>;

	public var maxMatches:Int;
	
	public var interestedTraitType(default, set_interestedTraitType):Dynamic;
	private function set_interestedTraitType(value:Dynamic):Dynamic {
		interestedTraitType = value;
		
		#if cpp
		_enumValMode = Type.enumIndex(value) != -1;
		#else
		_enumValMode = Type.getEnum(value) != null; // cpp returns 'Class'
		#end
		
		return value;
	}
	
	private var _enumValMode:Bool;


	public var ownerTrait:Dynamic;
	public var ownerTraitTyped:ITrait;
	public var passThroughInjector:Bool;
	public var passThroughItem:Bool;

	private var _addedTraits:UniqueList<Dynamic>;

	public function new(interestedTraitType:Dynamic, addHandler:Dynamic, removeHandler:Dynamic, siblings:Bool=true, descendants:Bool=false, ascendants:Bool=false, universal:Bool=false){
		this.addHandler = addHandler;
		this.removeHandler = removeHandler;
		
		maxMatches = -1;
		
		this.siblings = siblings;
		this.descendants = descendants;
		this.ascendants = ascendants;
		this.universal = universal;
		this.interestedTraitType = interestedTraitType;
		_addedTraits = new UniqueList<Dynamic>();
		passThroughInjector = false;
		passThroughItem = false;
	}



	public function injectorAdded(traitPair:TraitPair<Dynamic>):Void {
		if (_addedTraits.add(traitPair) && addHandler != null) {
			var item:ComposeItem = traitPair.item;
			var trait:Dynamic = traitPair.trait;
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

	public function injectorRemoved(traitPair:TraitPair<Dynamic>):Void{
		if (_addedTraits.remove(traitPair) && removeHandler != null) {
			var item:ComposeItem = traitPair.item;
			var trait:Dynamic = traitPair.trait;
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
		if(stopDescendingAt!=null){
			return !stopDescendingAt(item,null,this);
		}else{
			return true;
		}
	}
	public function shouldAscend(item:ComposeItem):Bool{
		if(stopAscendingAt!=null){
			return !stopAscendingAt(item,null,this);
		}else{
			return true;
		}
	}
	public function isInterestedIn(item:ComposeItem, trait:Dynamic):Bool {
		if((matchTrait != null && !matchTrait(item, trait, this)) ||
					(maxMatches != -1 && _addedTraits.length >= maxMatches)) {
			return false;
		}
		if (_enumValMode) {
			if (checkEnumParams == null) {
				return Type.enumEq(trait, interestedTraitType);
			}else {
				var traitEnum = Type.getEnum(trait);
				var intEnum = Type.getEnum(interestedTraitType);
				if (traitEnum != intEnum) return false;
				if (Type.enumIndex(trait) != Type.enumIndex(interestedTraitType)) return false;
				
				var traitParams:Array<Dynamic> = Type.enumParameters(trait);
				var intParams:Array<Dynamic> = Type.enumParameters(interestedTraitType);
				for (index in checkEnumParams) {
					var intVal:Dynamic = intParams[index];
					var traitVal:Dynamic = traitParams[index];
					
					switch(Type.typeof(intVal)) {
						case TEnum(e):
							if (!Type.enumEq(intVal, traitVal)) return false;
						default:
							if (intVal!=traitVal) return false;
					}
				}
				return true;
			}
		}else {
			return Std.is(trait, interestedTraitType);
		}
	}
}