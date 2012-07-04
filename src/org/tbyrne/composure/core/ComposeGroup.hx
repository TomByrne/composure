package org.tbyrne.composure.core;

import haxe.Log;
import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.injectors.InjectorMarrier;
import org.tbyrne.composure.injectors.IInjector;
import org.tbyrne.composure.traits.TraitCollection;
import org.tbyrne.logging.LogMsg;


class ComposeGroup extends ComposeItem
{

	private var _descendantTraits:TraitCollection;
	private var _children:IndexedList<ComposeItem>;
	
	private var _childAscInjectors:IndexedList<IInjector>;
	private var _ignoredChildAscInjectors:IndexedList<IInjector>;
	private var _childAscendingMarrier:InjectorMarrier;
	
	private var _descInjectors:IndexedList<IInjector>;
	private var _parentDescInjectors:IndexedList<IInjector>;
	private var _ignoredParentDescInjectors:IndexedList<IInjector>;

	public function new(initTraits:Array<Dynamic> = null) {
		_descendantTraits = new TraitCollection();
		_children = new IndexedList<ComposeItem>();
		_descInjectors = new IndexedList<IInjector>();
		super(initTraits);
		_childAscendingMarrier = new InjectorMarrier(this,_traitCollection);
	}
	override private function setRoot(game:ComposeRoot):Void{
		super.setRoot(game);
		for(child in _children.list){
			child.setRoot(game);
		}
	}
	public function addItem(item:ComposeItem):Void{
		#if debug
		if (item == null) {
			Log.trace(new LogMsg("ComposeGroup.addItem must have child ComposeItem supplied", [LogType.devWarning]));
			return;
		}
		if (_children.containsItem(item)) {
			Log.trace(new LogMsg("ComposeGroup.addItem already contains child item.", [LogType.devWarning]));
			return;
		}
		#end
		
		_children.add(item);
		
		item.parentItem = this;
		
		for(traitInjector in _descInjectors.list){
			item.addParentInjector(traitInjector);
		}
		if(_parentDescInjectors!=null){
			for(traitInjector in _parentDescInjectors.list){
				item.addParentInjector(traitInjector);
			}
		}
		item.setRoot(_root);
	}
	public function removeItem(item:ComposeItem):Void{
		#if debug
		if (item == null) {
			Log.trace(new LogMsg("ComposeGroup.removeItem must have child ComposeItem supplied", [LogType.devWarning]));
			return;
		}
		if (!_children.containsItem(item)) {
			Log.trace(new LogMsg("ComposeGroup.removeItem doesn't contain child item.", [LogType.devWarning]));
			return;
		}
		#end
		
		_children.remove(item);
		item.parentItem = null;
		
		for(traitInjector in _descInjectors.list){
			item.removeParentInjector(traitInjector);
		}
		if(_parentDescInjectors!=null){
			for(traitInjector in _parentDescInjectors.list){
				item.removeParentInjector(traitInjector);
			}
		}
		
		item.setRoot(null);
	}
	public function removeAllItem():Void{
		while( _children.list.length>0 ){
			removeItem(_children.list[0]);
		}
	}
	public function addChildTrait(trait:Dynamic):Void{
		_descendantTraits.addTrait(trait);
		if(_parentItem!=null)_parentItem.addChildTrait(trait);
	}
	public function removeChildTrait(trait:Dynamic):Void{
		_descendantTraits.removeTrait(trait);
		if(_parentItem!=null)_parentItem.removeChildTrait(trait);
	}
	override public function addTrait(trait:Dynamic):Void{
		super.addTrait(trait);
		checkForNewlyIgnoredInjectors();
	}
	override public function addTraits(traits:Array<Dynamic>):Void{
		super.addTraits(traits);
		checkForNewlyIgnoredInjectors();
	}
	override public function removeTrait(trait:Dynamic):Void{
		super.removeTrait(trait);
		checkForNewlyUnignoredInjectors();
	}
	override public function removeTraits(traits:Array<Dynamic>):Void{
		super.removeTraits(traits);
		checkForNewlyUnignoredInjectors();
	}
	override public function removeAllTraits():Void{
		super.removeAllTraits();
		checkForNewlyUnignoredInjectors();
	}
	override private function addTraitInjector(injector:IInjector):Void{
		super.addTraitInjector(injector);
		if(injector.descendants){
			_descInjectors.add(injector);
			for(child in _children.list){
				child.addParentInjector(injector);
			}
		}
	}
	override private function removeTraitInjector(injector:IInjector):Void{
		super.removeTraitInjector(injector);
		if(_descInjectors.containsItem(injector)){
			_descInjectors.remove(injector);
			for(child in _children.list){
				child.removeParentInjector(injector);
			}
		}
	}
	public function getDescTrait(matchType:Class<Dynamic>):Dynamic{
		return _descendantTraits.getTrait(matchType);
	}
	public function getDescTraits(ifMatches:Class<Dynamic>=null):Array<Dynamic>{
		return _descendantTraits.getTraits(ifMatches);
	}
	public function callForDescTraits(func:ComposeItem->Dynamic->Void, ifMatches:Class<Dynamic>=null/*, params:Array=null*/):Void{
		_descendantTraits.callForTraits(func, ifMatches, this/*, params*/);
	}
	override private function onParentAdd():Void{
		super.onParentAdd();
		for(trait in _descendantTraits.traits.list){
			_parentItem.addChildTrait(trait);
		}
		if(_childAscInjectors!=null){
			for(injector in _childAscInjectors.list){
				_parentItem.addAscendingInjector(injector);
			}
		}
	}
	override private function onParentRemove():Void{
		super.onParentRemove();
		for(trait in _descendantTraits.traits.list){
			_parentItem.removeChildTrait(trait);
		}
		if(_childAscInjectors!=null){
			for(injector in _childAscInjectors.list){
				_parentItem.removeAscendingInjector(injector);
			}
		}
	}
	public function addAscendingInjector(injector:IInjector):Void {
		_childAscendingMarrier.addInjector(injector);
		if(injector.shouldAscend(this)){
			_addAscendingInjector(injector);
		}else {
			if(_ignoredChildAscInjectors==null)_ignoredChildAscInjectors = new IndexedList<IInjector>();
			_ignoredChildAscInjectors.add(injector);
		}
	}
	public function _addAscendingInjector(injector:IInjector):Void {
		if(_childAscInjectors==null)_childAscInjectors = new IndexedList();
		_childAscInjectors.add(injector);
		if (_parentItem != null)_parentItem.addAscendingInjector(injector);
	}
	public function removeAscendingInjector(injector:IInjector):Void {
		_childAscendingMarrier.removeInjector(injector);
		if (_childAscInjectors!=null && _childAscInjectors.containsItem(injector)) {
			_removeAscendingInjector(injector);	
		}else {
			_ignoredChildAscInjectors.remove(injector);
		}
	}
	private function _removeAscendingInjector(injector:IInjector):Void {
		_childAscInjectors.remove(injector);
		if (_parentItem != null)_parentItem.removeAscendingInjector(injector);
	}

	override private function addParentInjector(injector:IInjector):Void{
		super.addParentInjector(injector);
		if(injector.shouldDescend(this)){
			addDescParentInjector(injector);
		}else{
			if(_ignoredParentDescInjectors==null)_ignoredParentDescInjectors = new IndexedList<IInjector>();
			_ignoredParentDescInjectors.add(injector);
		}
	}

	override private function removeParentInjector(injector:IInjector):Void{
		super.removeParentInjector(injector);
		
		if(_parentDescInjectors!=null && _parentDescInjectors.containsItem(injector)){
			removeDescParentInjector(injector);
		}else if(_ignoredParentDescInjectors!=null){
			_ignoredParentDescInjectors.remove(injector);
		}
	}

	private function checkForNewlyIgnoredInjectors():Void {
		var	i:Int = 0;
		if(_parentDescInjectors!=null){
			while(i<_parentDescInjectors.list.length){
				var injector:IInjector = _parentDescInjectors.list[i];
				if(!injector.shouldDescend(this)){
					removeDescParentInjector(injector);
					if(_ignoredParentDescInjectors==null)_ignoredParentDescInjectors = new IndexedList<IInjector>();
					_ignoredParentDescInjectors.add(injector);
				}else{
					++i;
				}
			}
		}
		if(_childAscInjectors!=null){
			i = 0;
			while(i<_childAscInjectors.list.length){
				var injector:IInjector = _childAscInjectors.list[i];
				if(!injector.shouldAscend(this)){
					_removeAscendingInjector(injector);	
					if(_ignoredChildAscInjectors==null)_ignoredChildAscInjectors = new IndexedList<IInjector>();
					_ignoredChildAscInjectors.add(injector);
				}else{
					++i;
				}
			}
		}
	}
	private function checkForNewlyUnignoredInjectors():Void{
		var	i:Int = 0;
		if(_ignoredParentDescInjectors!=null){
			while(i<_ignoredParentDescInjectors.list.length){
				var injector:IInjector = _ignoredParentDescInjectors.list[i];
				if(injector.shouldDescend(this)){
					addDescParentInjector(injector);
					_ignoredParentDescInjectors.remove(injector);
				}else{
					++i;
				}
			}
		}
		if(_ignoredChildAscInjectors!=null){
			i = 0;
			while(i<_ignoredChildAscInjectors.list.length){
				var injector:IInjector = _ignoredChildAscInjectors.list[i];
				if (injector.shouldAscend(this)) {
					_addAscendingInjector(injector);
					_ignoredChildAscInjectors.remove(injector);
				}else{
					++i;
				}
			}
		}
	}


	private function addDescParentInjector(injector:IInjector):Void{
		if(_parentDescInjectors==null)_parentDescInjectors = new IndexedList<IInjector>();
		_parentDescInjectors.add(injector);
		for(child in _children.list){
			child.addParentInjector(injector);
		}
	}
	private function removeDescParentInjector(injector:IInjector):Void{
		_parentDescInjectors.remove(injector);
		for(child in _children.list){
			child.removeParentInjector(injector);
		}
	}
}