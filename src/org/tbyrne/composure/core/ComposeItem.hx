package org.tbyrne.composure.core;

import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.injectors.InjectorMarrier;
import org.tbyrne.composure.injectors.IInjector;
import org.tbyrne.composure.traits.ITrait;
import org.tbyrne.composure.traits.ITraitProxy;
import org.tbyrne.composure.traits.TraitCollection;
import org.tbyrne.composure.restrictions.ITraitRestriction;
import time.types.ds.ObjectHash;


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
	private var _siblingMarrier:InjectorMarrier; // Marries traits owned by this Item to siblings' injectors
	private var _parentMarrier:InjectorMarrier; // Marries traits owned by this Item to ascendants' injectors
	private var _ascInjectors:IndexedList<IInjector>;
	private var _traitToCast:ObjectHash<Dynamic,ITrait>;

	public function new(initTraits:Array<Dynamic>=null){
		_traitCollection = new TraitCollection();
		_siblingMarrier = new InjectorMarrier(this,_traitCollection);
		_parentMarrier = new InjectorMarrier(this, _traitCollection);
		_traitToCast = new ObjectHash();
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
		/*#if debug
		if(_root && _root!=this){
			Log.trace("WARNING:: ITrait being added while ComposeItem added to root");
		}
		#end*/
		
		var castTrait:ITrait = null;
		var restrictions:Array<ITraitRestriction>;
		
		var getProxyTrait = Reflect.field(trait, "getProxiedTrait");
		if (getProxyTrait != null) {
			var proxy = trait.getProxiedTrait();
			if (Std.is(proxy, ITrait)) castTrait = cast(proxy, ITrait);
		}
		if (castTrait == null && Std.is(trait, ITrait)) {
			castTrait = cast(trait, ITrait);
		}
		if (castTrait != null) {
			castTrait.item = this;
			
			restrictions = castTrait.getRestrictions();
			for (restriction in restrictions) {
				if(!restriction.allowAddTo(trait, this)) {
					return;
				}
			}
			_traitToCast.set(trait, castTrait);
		}
		var traits:Array<Dynamic> = _traitCollection.traits.list;
		for (otherTrait in traits) {
			var otherCast:ITrait = _traitToCast.get(otherTrait);
			if(otherCast!=null){
				restrictions = otherCast.getRestrictions();
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
			var castInjectors:Array<IInjector> = castTrait.getInjectors();
			for(injector in castInjectors){
				addTraitInjector(injector);
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
		/*#if debug
		if(_root){
			Log.trace("WARNING:: ITrait being removed while ComposeItem added to root");
		}
		#end*/
		
		var castTrait:ITrait = _traitToCast.get(trait);
		if(castTrait!=null){
			castTrait = cast(trait, ITrait);
			var castInjectors:Array<IInjector> = castTrait.getInjectors();
			for(injector in castInjectors){
				removeTraitInjector(injector);
			}
			_traitToCast.remove(trait);
		}
		
		_traitCollection.removeTrait(trait);
		if(_parentItem!=null)_parentItem.removeChildTrait(trait);
		
		if(castTrait!=null){
			castTrait.item = null;
		}
	}


	private function addTraitInjector(injector:IInjector):Void {
		if(injector.siblings){
			_siblingMarrier.addInjector(injector);
		}
		if(injector.ascendants){
			if(_ascInjectors==null)_ascInjectors = new IndexedList();
			_ascInjectors.add(injector);
			if(_parentItem!=null)_parentItem.addAscendingInjector(injector);
		}
	}
	private function removeTraitInjector(injector:IInjector):Void{
		if(injector.siblings){
			_siblingMarrier.removeInjector(injector);
		}
		if(injector.ascendants){
			_ascInjectors.remove(injector);
			if(_parentItem!=null)_parentItem.removeAscendingInjector(injector);
		}
	}


	private function onParentAdd():Void{
		for(trait in _traitCollection.traits.list){
			_parentItem.addChildTrait(trait);
		}
		if(_ascInjectors!=null){
			for(injector in _ascInjectors.list){
				_parentItem.addAscendingInjector(injector);
			}
		}
	}
	private function onParentRemove():Void{
		for(trait in _traitCollection.traits.list){
			_parentItem.removeChildTrait(trait);
		}
		if(_ascInjectors!=null){
			for(injector in _ascInjectors.list){
				_parentItem.removeAscendingInjector(injector);
			}
		}
	}


	private function addParentInjector(injector:IInjector):Void{
		_parentMarrier.addInjector(injector);
	}

	private function removeParentInjector(injector:IInjector):Void{
		_parentMarrier.removeInjector(injector);
	}
}