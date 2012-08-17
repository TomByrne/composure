package composure.utilTraits;
import haxe.Log;
import org.tbyrne.collections.UniqueList;
import composure.injectors.Injector;
import composure.core.ComposeGroup;
import composure.core.ComposeItem;
import composure.traits.AbstractTrait;
import org.tbyrne.logging.LogMsg;
import cmtc.ds.hash.ObjectHash;

/**
 * The TraitFurnisher class is used to add traits to an item in response
 * to a certain type of trait being added to the item.<br/>
 * <br/>
 * This is very useful when creating interchangable libraries. For example,
 * when wanting to add a platform specific display trait to a items in the
 * presence of another trait:
 * <pre><code>
 * var traitFurnisher:TraitFurnisher = new TraitFurnisher(AddType.traitItem, RectangleInfo, [HtmlRectangleDisplay]);
 * stage.addTrait(traitFurnisher);
 * </code></pre>
 * In this example, any item which has a RectangleInfo trait added to it (representing
 * a rectangle's position and size) will also get a HtmlRectangleDisplay trait added to
 * it. The HtmlRectangleDisplay object can then access the RectangleInfo's size and 
 * position properties using injection metadata. In this way, the display method for
 * all rectangles could be quickly and easily be swapped out for another display trait.
 * 
 * @author Tom Byrne
 */

class TraitFurnisher extends AbstractTrait
{
	public var concernedTraitType(default, set_concernedTraitType):Class<Dynamic>;
	private function set_concernedTraitType(value:Class<Dynamic>):Class<Dynamic> {
		if (_injector == null) {
			_injector = new Injector(value, onConcernedTraitAdded, onConcernedTraitRemoved, searchSiblings, searchDescendants, searchAscendants);
			_injector.passThroughItem = true;
		}else {
			removeInjector(_injector);
			_injector.interestedTraitType = value;
		}
		concernedTraitType = value;
		if (concernedTraitType != null) {
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
				for (trait in _foundTraits) {
					var item = getItem(trait);
					var origItem = _originalItems.get(trait);
					if (item != origItem) {
						origItem.removeTrait(trait);
						item.addTrait(trait);
					}
				}
			}else {
				for (trait in _foundTraits) {
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
	private var _traits:UniqueList<Dynamic>;
	private var _traitTypes:UniqueList<Dynamic>;
	private var _traitFactories:UniqueList<Void->Dynamic>;
	private var _foundTraits:UniqueList<Dynamic>;
	private var _addedTraits:ObjectHash<Dynamic,Array<Dynamic>>;
	private var _traitToItems:ObjectHash<Dynamic,ComposeItem>;
	private var _originalItems:ObjectHash<Dynamic,ComposeItem>;
	private var _originalParents:ObjectHash<Dynamic,ComposeGroup>;
	
	private var _ignoreTraitChanges:Bool;

	public function new(addType:AddType, ?concernedTraitType:Class<Dynamic>,?traitTypes:Array<Dynamic>,?traitFactories:Array<Void->Dynamic>,searchSiblings:Bool=true,searchDescendants:Bool=true,searchAscendants:Bool=false,?adoptTrait:Bool) 
	{
		super();
		
		_addType = addType;
		
		_addedTraits = new ObjectHash < Dynamic, Array<Dynamic> > ();
		
		if(traitTypes!=null)_traitTypes = new UniqueList<Dynamic>(traitTypes);
		if(traitFactories!=null)_traitFactories = new UniqueList<Void->Dynamic>(traitFactories);
		
		this.adoptTrait = adoptTrait;
		this.searchSiblings = searchSiblings;
		this.searchDescendants = searchDescendants;
		this.searchAscendants = searchAscendants;
		this.concernedTraitType = concernedTraitType;
		
	}
	
	private function onConcernedTraitAdded(trait:Dynamic, origItem:ComposeItem):Void {
		if (_ignoreTraitChanges) return;
		_ignoreTraitChanges = true;
		
		
		if (_foundTraits == null) {
			_foundTraits = new UniqueList<Dynamic>();
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
			for (otherTrait in _traits) {
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		if (_traitTypes != null) {
			for (traitType in _traitTypes) {
				var otherTrait:Dynamic = Type.createInstance(traitType,[]);
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		if (_traitFactories != null) {
			for (traitFactory in _traitFactories) {
				var otherTrait:Dynamic = traitFactory();
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		_addedTraits.set(trait, traitsAdded);
		_ignoreTraitChanges = false;
	}
	private function onConcernedTraitRemoved(trait:Dynamic, currItem:ComposeItem):Void {
		if (_ignoreTraitChanges) return;
			_ignoreTraitChanges = true;
		
		_foundTraits.remove(trait);
		
		var origItem = _originalItems.get(trait);
		if (adoptTrait && origItem != currItem) {
			currItem.removeTrait(trait);
			origItem.addTrait(trait);
		}
		_originalItems.delete(trait);
		
		var item:ComposeItem = getItem(trait);
		var traitsAdded:Array<Dynamic> = _addedTraits.get(trait);
		for (otherTrait in traitsAdded) {
			item.removeTrait(otherTrait);
		}
		_addedTraits.delete(trait);
		
		unregisterItem(trait, item);
		
		_ignoreTraitChanges = false;
	}
	
	public function addTrait(trait:Dynamic):Void {
		if (_traits == null) {
			_traits = new UniqueList<Dynamic>();
		}
		_traits.add(trait);
		
		if(_foundTraits!=null){
			for (foundTrait in _foundTraits) {
				getItem(foundTrait).addTrait(trait);
				var traitsAdded:Array<Dynamic> = _addedTraits.get(foundTrait);
				traitsAdded.push(trait);
			}
		}
	}
	
	public function addTraitType(traitType:Class<Dynamic>):Void {
		if (_traitTypes == null) {
			_traitTypes = new UniqueList<Dynamic>();
		}
		_traitTypes.add(traitType);
		
		if(_foundTraits!=null){
			for (trait in _foundTraits) {
				var otherTrait:Dynamic = Type.createInstance(traitType,[]);
				getItem(trait).addTrait(otherTrait);
				var traitsAdded:Array<Dynamic> = _addedTraits.get(trait);
				traitsAdded.push(otherTrait);
			}
		}
	}
	
	public function addTraitFactory(traitFactory:Void->Dynamic):Void {
		if (_traitFactories == null) {
			_traitFactories = new UniqueList<Void->Dynamic>();
		}
		_traitFactories.add(traitFactory);
		
		if(_foundTraits!=null){
			for (trait in _foundTraits) {
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
					origItem.parentItem.removeChild(origItem);
					newParent.addChild(origItem);
				}
			case AddType.item(specItem):
				item = specItem;
			default:
				item = new ComposeGroup();
				switch(_addType) {
					case AddType.selfSibling:
						this.item.parentItem.addChild(item);
					case AddType.traitSibling:
						origItem.parentItem.addChild(item);
					case AddType.selfChild:
						this.group.addChild(item);
					case AddType.traitChild:
						if (Std.is(origItem, ComposeGroup)) {
							var origGroup:ComposeGroup;
							untyped origGroup = origItem;
							origGroup.addChild(item);
						}
						#if debug
						else Log.trace(new LogMsg("AddType traitChild must be used on a ComposeGroup"));
						#end
					case AddType.itemChild(group):
						group.addChild(item);
					case AddType.itemSibling(sibling):
						sibling.parentItem.addChild(item);
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
				currItem.parentItem.removeChild(currItem);
			case AddType.itemChild(group):
				currItem.parentItem.removeChild(currItem);
			case AddType.itemSibling(group):
				currItem.parentItem.removeChild(currItem);
			case AddType.adoptItem(newParent):
				var oldParent:ComposeGroup = _originalParents.get(trait);
				if (oldParent != currItem.parentItem) {
					item.parentItem.removeChild(currItem);
					oldParent.addChild(currItem);
				}
			default:
		}
		_traitToItems.delete(trait);
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