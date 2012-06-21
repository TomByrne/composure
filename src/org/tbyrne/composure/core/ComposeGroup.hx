package org.tbyrne.composure.core;

import haxe.Log;
import org.tbyrne.collections.IndexedList;
import org.tbyrne.logging.LogMsg;
//import org.tbyrne.composure.ComposeNamespace;
import org.tbyrne.composure.concerns.ConcernMarrier;
import org.tbyrne.composure.concerns.IConcern;
import org.tbyrne.composure.traits.ITrait;
import org.tbyrne.composure.traits.TraitCollection;

//
//#use namespace ComposeNamespace;
//using away3d.namespace.ComposeNamespace;


class ComposeGroup extends ComposeItem
{

	private var _descendantTraits:TraitCollection;
	private var _children:IndexedList<ComposeItem>;
	
	private var _childAscConcerns:IndexedList<IConcern>;
	private var _ignoredChildAscConcerns:IndexedList<IConcern>;
	private var _childAscendingMarrier:ConcernMarrier;
	
	private var _descConcerns:IndexedList<IConcern>;
	private var _parentDescConcerns:IndexedList<IConcern>;
	private var _ignoredParentDescConcerns:IndexedList<IConcern>;

	public function new(initTraits:Array<Dynamic> = null) {
		_descendantTraits = new TraitCollection();
		_children = new IndexedList<ComposeItem>();
		_descConcerns = new IndexedList<IConcern>();
		super(initTraits);
		_childAscendingMarrier = new ConcernMarrier(this,_traitCollection);
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
		
		for(traitConcern in _descConcerns.list){
			item.addParentConcern(traitConcern);
		}
		if(_parentDescConcerns!=null){
			for(traitConcern in _parentDescConcerns.list){
				item.addParentConcern(traitConcern);
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
		
		for(traitConcern in _descConcerns.list){
			item.removeParentConcern(traitConcern);
		}
		if(_parentDescConcerns!=null){
			for(traitConcern in _parentDescConcerns.list){
				item.removeParentConcern(traitConcern);
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
		checkForNewlyIgnoredConcerns();
	}
	override public function addTraits(traits:Array<Dynamic>):Void{
		super.addTraits(traits);
		checkForNewlyIgnoredConcerns();
	}
	override public function removeTrait(trait:Dynamic):Void{
		super.removeTrait(trait);
		checkForNewlyUnignoredConcerns();
	}
	override public function removeTraits(traits:Array<Dynamic>):Void{
		super.removeTraits(traits);
		checkForNewlyUnignoredConcerns();
	}
	override public function removeAllTraits():Void{
		super.removeAllTraits();
		checkForNewlyUnignoredConcerns();
	}
	override private function addTraitConcern(concern:IConcern):Void{
		super.addTraitConcern(concern);
		if(concern.descendants){
			_descConcerns.add(concern);
			for(child in _children.list){
				child.addParentConcern(concern);
			}
		}
	}
	override private function removeTraitConcern(concern:IConcern):Void{
		super.removeTraitConcern(concern);
		if(_descConcerns.containsItem(concern)){
			_descConcerns.remove(concern);
			for(child in _children.list){
				child.removeParentConcern(concern);
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
		if(_childAscConcerns!=null){
			for(concern in _childAscConcerns.list){
				_parentItem.addAscendingConcern(concern);
			}
		}
	}
	override private function onParentRemove():Void{
		super.onParentRemove();
		for(trait in _descendantTraits.traits.list){
			_parentItem.removeChildTrait(trait);
		}
		if(_childAscConcerns!=null){
			for(concern in _childAscConcerns.list){
				_parentItem.removeAscendingConcern(concern);
			}
		}
	}
	public function addAscendingConcern(concern:IConcern):Void {
		_childAscendingMarrier.addConcern(concern);
		if(concern.shouldAscend(this)){
			_addAscendingConcern(concern);
		}else {
			if(_ignoredChildAscConcerns==null)_ignoredChildAscConcerns = new IndexedList<IConcern>();
			_ignoredChildAscConcerns.add(concern);
		}
	}
	public function _addAscendingConcern(concern:IConcern):Void {
		if(_childAscConcerns==null)_childAscConcerns = new IndexedList();
		_childAscConcerns.add(concern);
		if (_parentItem != null)_parentItem.addAscendingConcern(concern);
	}
	public function removeAscendingConcern(concern:IConcern):Void {
		_childAscendingMarrier.removeConcern(concern);
		if (_childAscConcerns!=null && _childAscConcerns.containsItem(concern)) {
			_removeAscendingConcern(concern);	
		}else {
			_ignoredChildAscConcerns.remove(concern);
		}
	}
	private function _removeAscendingConcern(concern:IConcern):Void {
		_childAscConcerns.remove(concern);
		if (_parentItem != null)_parentItem.removeAscendingConcern(concern);
	}

	override private function addParentConcern(concern:IConcern):Void{
		super.addParentConcern(concern);
		if(concern.shouldDescend(this)){
			addDescParentConcern(concern);
		}else{
			if(_ignoredParentDescConcerns==null)_ignoredParentDescConcerns = new IndexedList<IConcern>();
			_ignoredParentDescConcerns.add(concern);
		}
	}

	override private function removeParentConcern(concern:IConcern):Void{
		super.removeParentConcern(concern);
		
		if(_parentDescConcerns!=null && _parentDescConcerns.containsItem(concern)){
			removeDescParentConcern(concern);
		}else if(_ignoredParentDescConcerns!=null){
			_ignoredParentDescConcerns.remove(concern);
		}
	}

	private function checkForNewlyIgnoredConcerns():Void {
		var	i:Int = 0;
		if(_parentDescConcerns!=null){
			while(i<_parentDescConcerns.list.length){
				var concern:IConcern = _parentDescConcerns.list[i];
				if(!concern.shouldDescend(this)){
					removeDescParentConcern(concern);
					if(_ignoredParentDescConcerns==null)_ignoredParentDescConcerns = new IndexedList<IConcern>();
					_ignoredParentDescConcerns.add(concern);
				}else{
					++i;
				}
			}
		}
		if(_childAscConcerns!=null){
			i = 0;
			while(i<_childAscConcerns.list.length){
				var concern:IConcern = _childAscConcerns.list[i];
				if(!concern.shouldAscend(this)){
					_removeAscendingConcern(concern);	
					if(_ignoredChildAscConcerns==null)_ignoredChildAscConcerns = new IndexedList<IConcern>();
					_ignoredChildAscConcerns.add(concern);
				}else{
					++i;
				}
			}
		}
	}
	private function checkForNewlyUnignoredConcerns():Void{
		var	i:Int = 0;
		if(_ignoredParentDescConcerns!=null){
			while(i<_ignoredParentDescConcerns.list.length){
				var concern:IConcern = _ignoredParentDescConcerns.list[i];
				if(concern.shouldDescend(this)){
					addDescParentConcern(concern);
					_ignoredParentDescConcerns.remove(concern);
				}else{
					++i;
				}
			}
		}
		if(_ignoredChildAscConcerns!=null){
			i = 0;
			while(i<_ignoredChildAscConcerns.list.length){
				var concern:IConcern = _ignoredChildAscConcerns.list[i];
				if (concern.shouldAscend(this)) {
					_addAscendingConcern(concern);
					_ignoredChildAscConcerns.remove(concern);
				}else{
					++i;
				}
			}
		}
	}


	private function addDescParentConcern(concern:IConcern):Void{
		if(_parentDescConcerns==null)_parentDescConcerns = new IndexedList<IConcern>();
		_parentDescConcerns.add(concern);
		for(child in _children.list){
			child.addParentConcern(concern);
		}
	}
	private function removeDescParentConcern(concern:IConcern):Void{
		_parentDescConcerns.remove(concern);
		for(child in _children.list){
			child.removeParentConcern(concern);
		}
	}
}