package org.tbyrne.composure.utils;
import haxe.Log;
import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.injectors.Injector;
import org.tbyrne.composure.core.ComposeGroup;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.AbstractTrait;
import org.tbyrne.logging.LogMsg;
import time.types.ds.ObjectHash;

/**
 * ...
 * @author Tom Byrne
 */

class TraitFurnisher extends AbstractTrait
{
	public var injectoredTraitType(default, set_injectoredTraitType):Class<Dynamic>;
	private function set_injectoredTraitType(value:Class<Dynamic>):Class<Dynamic> {
		if (_injector == null) {
			_injector = new Injector(value, onInjectoredTraitAdded, onInjectoredTraitRemoved, searchSiblings, searchDescendants, searchAscendants);
			_injector.passThroughItem = true;
		}else {
			removeInjector(_injector);
			_injector.interestedTraitType = value;
		}
		injectoredTraitType = value;
		if (injectoredTraitType != null) {
			addInjector(_injector);
		}
		return value;
	}
	public var searchSiblings(default, set_searchSiblings):Bool;
	private function set_searchSiblings(value:Bool):Bool{
		if (_injector != null) {
			removeInjector(_injector);
			_injector.siblings = value;
			addInjector(_injector);
		}
		searchSiblings = value;
		return value;
	}
	public var searchDescendants(default, set_searchDescendants):Bool;
	private function set_searchDescendants(value:Bool):Bool{
		if (_injector != null) {
			removeInjector(_injector);
			_injector.descendants = value;
			addInjector(_injector);
		}
		searchDescendants = value;
		return value;
	}
	public var searchAscendants(default, set_searchAscendants):Bool;
	private function set_searchAscendants(value:Bool):Bool{
		if (_injector != null) {
			removeInjector(_injector);
			_injector.ascendants = value;
			addInjector(_injector);
		}
		searchAscendants = value;
		return value;
	}
	public var adoptTrait(default, set_adoptTrait):Bool;
	private function set_adoptTrait(value:Bool):Bool{
		adoptTrait = value;
		if(_foundTraits!=null){
			if (value) {
				for (trait in _foundTraits.list) {
					var item = getItem(trait);
					var origItem = _originalItems.get(trait);
					if (item != origItem) {
						origItem.removeTrait(trait);
						item.addTrait(trait);
					}
				}
			}else {
				for (trait in _foundTraits.list) {
					var item = getItem(trait);
					var origItem = _originalItems.get(trait);
					if (item != origItem) {
						item.removeTrait(trait);
						origItem.addTrait(trait);
					}
				}
			}
		}
		return value;
	}
	
	private var _addType:AddType;
	private var _injector:Injector;
	private var _traits:IndexedList<Dynamic>;
	private var _traitTypes:IndexedList<Dynamic>;
	private var _traitFactories:IndexedList<Void->Dynamic>;
	private var _foundTraits:IndexedList<Dynamic>;
	private var _addedTraits:ObjectHash<Dynamic,Array<Dynamic>>;
	private var _traitToItems:ObjectHash<Dynamic,ComposeItem>;
	private var _originalItems:ObjectHash<Dynamic,ComposeItem>;
	private var _originalParents:ObjectHash<Dynamic,ComposeGroup>;
	
	private var _ignoreTraitChanges:Bool;

	public function new(addType:AddType, ?injectoredTraitType:Class<Dynamic>,?traitTypes:Array<Dynamic>,?traitFactories:Array<Void->Dynamic>,searchSiblings:Bool=true,searchDescendants:Bool=true,searchAscendants:Bool=false,?adoptTrait:Bool) 
	{
		super();
		
		_addType = addType;
		
		_addedTraits = new ObjectHash < Dynamic, Array<Dynamic> > ();
		
		if(traitTypes!=null)_traitTypes = new IndexedList<Dynamic>(traitTypes);
		if(traitFactories!=null)_traitFactories = new IndexedList<Void->Dynamic>(traitFactories);
		
		this.adoptTrait = adoptTrait;
		this.searchSiblings = searchSiblings;
		this.searchDescendants = searchDescendants;
		this.searchAscendants = searchAscendants;
		this.injectoredTraitType = injectoredTraitType;
		
	}
	
	private function onInjectoredTraitAdded(trait:Dynamic, origItem:ComposeItem):Void {
		if (_ignoreTraitChanges) return;
		_ignoreTraitChanges = true;
		
		
		if (_foundTraits == null) {
			_foundTraits = new IndexedList<Dynamic>();
			_originalItems = new ObjectHash<Dynamic,ComposeItem>();
		}
		_foundTraits.add(trait);
		_originalItems.set(trait, origItem);
		
		var item:ComposeItem = registerItem(trait, origItem);
		if (adoptTrait && item != origItem) {
			origItem.removeTrait(trait);
			item.addTrait(trait);
		}
		
		var traitsAdded:Array<Dynamic> = [];
		if (_traits != null) {
			for (otherTrait in _traits.list) {
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		if (_traitTypes != null) {
			for (traitType in _traitTypes.list) {
				var otherTrait:Dynamic = Type.createInstance(traitType,[]);
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		if (_traitFactories != null) {
			for (traitFactory in _traitFactories.list) {
				var otherTrait:Dynamic = traitFactory();
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		_addedTraits.set(trait, traitsAdded);
		_ignoreTraitChanges = false;
	}
	private function onInjectoredTraitRemoved(trait:Dynamic, currItem:ComposeItem):Void {
		if (_ignoreTraitChanges) return;
			_ignoreTraitChanges = true;
		
		_foundTraits.remove(trait);
		
		var origItem = _originalItems.get(trait);
		if (adoptTrait && origItem != currItem) {
			currItem.removeTrait(trait);
			origItem.addTrait(trait);
		}
		_originalItems.remove(trait);
		
		var item:ComposeItem = getItem(trait);
		var traitsAdded:Array<Dynamic> = _addedTraits.get(trait);
		for (otherTrait in traitsAdded) {
			item.removeTrait(otherTrait);
		}
		_addedTraits.remove(trait);
		
		unregisterItem(trait, item);
		
		_ignoreTraitChanges = false;
	}
	
	public function addTrait(trait:Dynamic):Void {
		if (_traits == null) {
			_traits = new IndexedList<Dynamic>();
		}
		_traits.add(trait);
		
		if(_foundTraits!=null){
			for (foundTrait in _foundTraits.list) {
				getItem(foundTrait).addTrait(trait);
				var traitsAdded:Array<Dynamic> = _addedTraits.get(foundTrait);
				traitsAdded.push(trait);
			}
		}
	}
	
	public function addTraitType(traitType:Class<Dynamic>):Void {
		if (_traitTypes == null) {
			_traitTypes = new IndexedList<Dynamic>();
		}
		_traitTypes.add(traitType);
		
		if(_foundTraits!=null){
			for (trait in _foundTraits.list) {
				var otherTrait:Dynamic = Type.createInstance(traitType,[]);
				getItem(trait).addTrait(otherTrait);
				var traitsAdded:Array<Dynamic> = _addedTraits.get(trait);
				traitsAdded.push(otherTrait);
			}
		}
	}
	
	public function addTraitFactory(traitFactory:Void->Dynamic):Void {
		if (_traitFactories == null) {
			_traitFactories = new IndexedList<Void->Dynamic>();
		}
		_traitFactories.add(traitFactory);
		
		if(_foundTraits!=null){
			for (trait in _foundTraits.list) {
				var otherTrait:Dynamic = traitFactory();
				getItem(trait).addTrait(otherTrait);
				var traitsAdded:Array<Dynamic> = _addedTraits.get(trait);
				traitsAdded.push(otherTrait);
			}
		}
	}
	
	private function getItem(trait:Dynamic):ComposeItem {
		return _traitToItems.get(trait);
	}
	private function registerItem(trait:Dynamic, origItem:ComposeItem):ComposeItem {
		if (_traitToItems == null) {
			_traitToItems = new ObjectHash<Dynamic,ComposeItem>();
		}
		var item:ComposeItem;
		
		switch(_addType) {
			case AddType.selfItem:
				item = this.item;
			case AddType.traitItem:
				item = origItem;
			case AddType.adoptItem(newParent):
				item = origItem;
				if (_originalParents == null) {
					_originalParents = new ObjectHash<Dynamic,ComposeGroup>();
				}
				_originalParents.set(trait, origItem.parentItem);
				if (origItem.parentItem != newParent) {
					origItem.parentItem.removeItem(origItem);
					newParent.addItem(origItem);
				}
			case AddType.item(specItem):
				item = specItem;
			default:
				item = new ComposeGroup();
				switch(_addType) {
					case AddType.selfSibling:
						this.item.parentItem.addItem(item);
					case AddType.traitSibling:
						origItem.parentItem.addItem(item);
					case AddType.selfChild:
						this.group.addItem(item);
					case AddType.traitChild:
						if (Std.is(origItem, ComposeGroup)) {
							var origGroup:ComposeGroup;
							untyped origGroup = origItem;
							origGroup.addItem(item);
						}
						#if debug
						else Log.trace(new LogMsg("AddType traitChild must be used on a ComposeGroup"));
						#end
					case AddType.itemChild(group):
						group.addItem(item);
					case AddType.itemSibling(sibling):
						sibling.parentItem.addItem(item);
					default:
						Log.trace(new LogMsg("Unsupported AddType",[LogType.devError]));
				}
		}
		_traitToItems.set(trait, item);
		return item;
	}
	private function unregisterItem(trait:Dynamic, currItem:ComposeItem):Void {
		switch(_addType) {
			case AddType.traitSibling, AddType.selfSibling, AddType.traitChild, AddType.selfChild:
				currItem.parentItem.removeItem(currItem);
			case AddType.itemChild(group):
				currItem.parentItem.removeItem(currItem);
			case AddType.itemSibling(group):
				currItem.parentItem.removeItem(currItem);
			case AddType.adoptItem(newParent):
				var oldParent:ComposeGroup = _originalParents.get(trait);
				if (oldParent != currItem.parentItem) {
					item.parentItem.removeItem(currItem);
					oldParent.addItem(currItem);
				}
			default:
		}
		_traitToItems.remove(trait);
	}
}

enum AddType {
	adoptItem(newParent:ComposeGroup);
	
	traitItem;
	traitSibling;
	traitChild;
	
	selfItem;
	selfSibling;
	selfChild;
	
	item(item:ComposeItem);
	itemChild(group:ComposeGroup);
	itemSibling(item:ComposeItem);
}