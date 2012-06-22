package org.tbyrne.composure.core;

import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.concerns.ConcernMarrier;
import org.tbyrne.composure.concerns.IConcern;
import org.tbyrne.composure.traits.ITrait;
import org.tbyrne.composure.traits.TraitCollection;
import org.tbyrne.composure.restrictions.ITraitRestriction;


class ComposeItem
{


	public var parentItem(getParentItem, setParentItem):ComposeGroup;
	private function getParentItem():ComposeGroup{
		return _parentItem;
	}
	private function setParentItem(value:ComposeGroup):ComposeGroup{
		if(_parentItem!=value){
			if(_parentItem!=null){
				onParentRemove();
			}
			_parentItem = value;
			if(_parentItem!=null){
				onParentAdd();
			}
		}
		return value;
	}
	public var root(getRoot, null):ComposeRoot;
	private function getRoot():ComposeRoot{
		return _root;
	}

	private var _parentItem:ComposeGroup;
	private var _root:ComposeRoot;
	private var _traitCollection:TraitCollection;
	private var _siblingMarrier:ConcernMarrier; // Marries traits owned by this Item to siblings' concerns
	private var _parentMarrier:ConcernMarrier; // Marries traits owned by this Item to ascendants' concerns
	private var _ascConcerns:IndexedList<IConcern>;

	public function new(initTraits:Array<Dynamic>=null){
		_traitCollection = new TraitCollection();
		_siblingMarrier = new ConcernMarrier(this,_traitCollection);
		_parentMarrier = new ConcernMarrier(this,_traitCollection);
		if(initTraits!=null){
			for(trait in initTraits){
				addTrait(trait);
			}
		}
	}
	private function setRoot(root:ComposeRoot):Void{
		_root = root;
	}
	public function getTrait<TraitType>(TraitType:Class<TraitType>):TraitType{
		return _traitCollection.getTrait(TraitType);
	}
	public function getTraits<TraitType>(TraitType:Class<TraitType>=null):Array<TraitType>{
		return _traitCollection.getTraits(TraitType);
	}



	/**
	 * handler(composeItem:ComposeItem, trait:ITrait);
	 */
	public function callForTraits(func:ComposeItem->ITrait->Void, ifMatches:Class<ITrait>=null/*, params:Array=null*/):Void{
		_traitCollection.callForTraits(func,ifMatches,this/*,params*/);
	}
	public function addTrait(trait:Dynamic):Void{
		_addTrait(trait);
	}
	public function addTraits(traits:Array<Dynamic>):Void{
		for(trait in traits){
			_addTrait(trait);
		}
	}
	private function _addTrait(trait:Dynamic):Void{
		/*CONFIG::debug{
		if(_root && _root!=this){
			Log.trace("WARNING:: ITrait being added while ComposeItem added to root");
		}
		}*/
		var castTrait:ITrait;
		var restrictions:Array<ITraitRestriction>;
		if(Std.is(trait,ITrait)){
			castTrait = cast(trait, ITrait);
			castTrait.item = this;
			
			restrictions = castTrait.getRestrictions();
			for (restriction in restrictions) {
				if(!restriction.allowAddTo(trait, this)) {
					return;
				}
			}
		}else {
			castTrait = null;
		}
		
		var traits:Array<Dynamic> = _traitCollection.traits.list;
		for (otherTrait in traits) {
			if(Std.is(otherTrait, ITrait)){
				var castTrait:ITrait = cast(otherTrait, ITrait);
				restrictions = castTrait.getRestrictions();
				for (restriction in restrictions) {
					if(!restriction.allowNewSibling(otherTrait, this, trait)) {
						return;
					}
				}
			}
		}
		
		_traitCollection.addTrait(trait);
		if (_parentItem != null)_parentItem.addChildTrait(trait);
		
		if (castTrait != null) {
			var castConcerns:Array<IConcern> = castTrait.getConcerns();
			for(concern in castConcerns){
				addTraitConcern(concern);
			}
		}
	}

	public function removeTrait(trait:Dynamic):Void{
		_removeTrait(trait);
	}
	public function removeTraits(traits:Array<Dynamic>):Void{
		for(trait in traits){
			_removeTrait(trait);
		}
	}
	public function removeAllTraits():Void{
		var list:Array<Dynamic> = _traitCollection.traits.list;
		while(list.length>0){
			_removeTrait(list[0]);
		}
	}
	private function _removeTrait(trait:Dynamic):Void{
		/*#id debug
		if(_root){
			Log.trace("WARNING:: ITrait being removed while ComposeItem added to root");
		}
		#end*/
		
		var castTrait:ITrait;
		if(Std.is(trait,ITrait)){
			castTrait = cast(trait, ITrait);
			var castConcerns:Array<IConcern> = castTrait.getConcerns();
			for(concern in castConcerns){
				removeTraitConcern(concern);
			}
		}else {
			castTrait = null;
		}
		
		
		_traitCollection.removeTrait(trait);
		if(_parentItem!=null)_parentItem.removeChildTrait(trait);
		
		if(castTrait!=null){
			castTrait.item = null;
		}
	}


	private function addTraitConcern(concern:IConcern):Void{
		if(concern.siblings){
			_siblingMarrier.addConcern(concern);
		}
		if(concern.ascendants){
			if(_ascConcerns==null)_ascConcerns = new IndexedList();
			_ascConcerns.add(concern);
			if(_parentItem!=null)_parentItem.addAscendingConcern(concern);
		}
	}
	private function removeTraitConcern(concern:IConcern):Void{
		if(concern.siblings){
			_siblingMarrier.removeConcern(concern);
		}
		if(concern.ascendants){
			_ascConcerns.remove(concern);
			if(_parentItem!=null)_parentItem.removeAscendingConcern(concern);
		}
	}


	private function onParentAdd():Void{
		for(trait in _traitCollection.traits.list){
			_parentItem.addChildTrait(trait);
		}
		if(_ascConcerns!=null){
			for(concern in _ascConcerns.list){
				_parentItem.addAscendingConcern(concern);
			}
		}
	}
	private function onParentRemove():Void{
		for(trait in _traitCollection.traits.list){
			_parentItem.removeChildTrait(trait);
		}
		if(_ascConcerns!=null){
			for(concern in _ascConcerns.list){
				_parentItem.removeAscendingConcern(concern);
			}
		}
	}


	private function addParentConcern(concern:IConcern):Void{
		_parentMarrier.addConcern(concern);
	}

	private function removeParentConcern(concern:IConcern):Void{
		_parentMarrier.removeConcern(concern);
	}
}