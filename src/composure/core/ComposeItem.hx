package composure.core;

import org.tbyrne.collections.UniqueList;
import composure.injectors.IInjector;
import composure.injectors.InjectorMarrier;
import composure.traits.ITrait;
import composure.traits.TraitCollection;
import cmtc.ds.hash.ObjectHash;


/**
 * ComposeItem forms is the base class of all conceptual items in Composure.
 * It allows traits to be added and removed.<br/>
 * ComposeItem should only be used for performance critical items, it is recommended
 * that most items be represented by the subclass ComposeGroup, which adds the ability
 * to add/remove child items.
 * @author		Tom Byrne
 */
class ComposeItem
{


	/**
	 * The ComposeGroup to which this item is added, if this is the root 'parentItem' will be a self-reference.
	 * This value is set automatically and shouldn't be manually changed.
	 */
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
	/**
	 * The ComposeRoot which is the top-level parent, if this is the root 'root' will be a self-reference.
	 * This value is set automatically and shouldn't be manually changed.
	 */
	public var root(getRoot, null):ComposeRoot;
	private function getRoot():ComposeRoot{
		return _root;
	}

	private var _parentItem:ComposeGroup;
	private var _root:ComposeRoot;
	private var _traitCollection:TraitCollection;
	private var _siblingMarrier:InjectorMarrier; // Marries traits owned by this Item to siblings' injectors
	private var _parentMarrier:InjectorMarrier; // Marries traits owned by this Item to ascendants' injectors
	private var _ascInjectors:UniqueList<IInjector>;
	private var _traitToCast:ObjectHash<Dynamic,ITrait>;

	/**
	 * @param	initTraits		A list of traits to add to this ComposeItem initially.
	 */
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
	/**
	 * Gets the first trait of a certain type.
	 * @param	TraitType		The type which the returned trait must implement.
	 * @return		A trait object, returns null if no matching trait is found.
	 */
	public function getTrait<TraitType>(TraitType:Class<TraitType>):TraitType{
		return _traitCollection.getTrait(TraitType);
	}
	/**
	 * Gets a list of traits of a certain type.
	 * @param	TraitType		The type which the returned traits must implement.
	 * 							If no type is passed in, all traits are returned.
	 * @return		An array of traits, returns null if no matching traits are found.
	 * 				CAUTION: Do not modify the returned Array, for performance reasons,
	 * 				it is passed out by reference and reused internally.
	 */
	public function getTraits<TraitType>(TraitType:Class<TraitType>=null):Iterable<TraitType>{
		return _traitCollection.getTraits(TraitType);
	}



	/**
	 * Calls a function once for each trait that matches a certain type. The ComposeItem and
	 * trait are passed through as arguments. A function should have a signature like:<br/>
	 * <code>
	 * function myTraitFunction(item:ComposeItem, trait:ITrait):Void;
	 * </code>
	 * @param	func		The function to call.
	 * @param	TraitType	The type which the returned traits must implement.
	 * 						If no type is passed in, the function is called for all traits.
	 */
	public function callForTraits<TraitType>(func:ComposeItem->TraitType->Void, TraitType:Class<TraitType>=null):Void{
		_traitCollection.callForTraits(func,TraitType,this);
	}
	/**
	 * Adds a trait to this item. Any type of object can be added, but if it implements ITrait
	 * it will have access to more information about the item and it's other traits. If, for structural reasons,
	 * it is inconvenient to implement ITrait, the object can expose a method called 'getProxiedTrait()' which should
	 * return an ITrait object to operate as it's proxy regarding other traits etc.
	 * @param	trait		The trait to add to this item.
	 */
	public function addTrait(trait:Dynamic):Void{
		_addTrait(trait);
	}
	/**
	 * Adds multiple traits to this item.
	 * @see					addTrait
	 * @param	traits		The traits to add to this item.
	 */
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
			_traitToCast.set(trait, castTrait);
		}
		
		_traitCollection.addTrait(trait);
		if (_parentItem != null)_parentItem.addChildTrait(trait);
		
		if (castTrait != null) {
			var castInjectors:Iterable<IInjector> = castTrait.getInjectors();
			for(injector in castInjectors){
				addTraitInjector(injector);
			}
		}
	}

	/**
	 * Removes a trait from this item.
	 * @see					addTrait
	 * @param	trait		The trait to remove from this item.
	 */
	public function removeTrait(trait:Dynamic):Void{
		_removeTrait(trait);
	}
	/**
	 * Removes a list of traits from this item.
	 * @see					addTrait
	 * @param	trait		The list of traits to remove from this item.
	 */
	public function removeTraits(traits:Array<Dynamic>):Void{
		for(trait in traits){
			_removeTrait(trait);
		}
	}
	/**
	 * Removes all traits from this item.
	 */
	public function removeAllTraits():Void{
		while(_traitCollection.traits.length>0){
			_removeTrait(_traitCollection.traits.first());
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
			var castInjectors:Iterable<IInjector> = castTrait.getInjectors();
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
			if(_ascInjectors==null)_ascInjectors = new UniqueList();
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
		for(trait in _traitCollection.traits){
			_parentItem.addChildTrait(trait);
		}
		if(_ascInjectors!=null){
			for(injector in _ascInjectors){
				_parentItem.addAscendingInjector(injector);
			}
		}
	}
	private function onParentRemove():Void{
		for(trait in _traitCollection.traits){
			_parentItem.removeChildTrait(trait);
		}
		if(_ascInjectors!=null){
			for(injector in _ascInjectors){
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