package composure.core;

import haxe.Log;
import org.tbyrne.collections.UniqueList;
import composure.injectors.InjectorMarrier;
import composure.injectors.IInjector;
import composure.traits.TraitCollection;
import org.tbyrne.logging.LogMsg;


/**
 * ComposeGroup is the core item used in Composure. It represents one conceptual object.
 * It shouldn't be directly overriden, instead it should be instantiated and then
 * populated with traits, each adding one atomic piece of behaviour.<br/>
 * ComposeGroup adds to the functionality of ComposeItem by allowing child items. For
 * performance critical items that will never need to house children, ComposeItem can
 * be used instead.
 * @author		Tom Byrne
 */
class ComposeGroup extends ComposeItem
{
	public var children(get_children, null):Iterable<ComposeItem>;
	private function get_children():Iterable<ComposeItem> {
		return _children;
	}

	private var _descendantTraits:TraitCollection;
	private var _children:UniqueList<ComposeItem>;
	
	private var _childAscInjectors:UniqueList<IInjector>;
	private var _ignoredChildAscInjectors:UniqueList<IInjector>;
	private var _childAscendingMarrier:InjectorMarrier;
	
	private var _descInjectors:UniqueList<IInjector>;
	private var _parentDescInjectors:UniqueList<IInjector>;
	private var _ignoredParentDescInjectors:UniqueList<IInjector>;

	/**
	 * @param	initTraits		A list of traits to add to this ComposeItem initially.
	 */
	public function new(initTraits:Array<Dynamic> = null) {
		_descendantTraits = new TraitCollection();
		_children = new UniqueList<ComposeItem>();
		_descInjectors = new UniqueList<IInjector>();
		super(); // don't send through initTraits until after _childAscendingMarrier is created
		_childAscendingMarrier = new InjectorMarrier(this, _traitCollection);
		if(initTraits!=null)addTraits(initTraits);
	}
	override private function setRoot(game:ComposeRoot):Void{
		super.setRoot(game);
		for(child in _children){
			child.setRoot(game);
		}
	}
	/**
	 * Adds a child ComposeItem to this ComposeGroup.
	 * @param	item		A ComposeItem object to add as a child to this group.
	 */
	public function addChild(item:ComposeItem):Void{
		#if debug
		if (item == null) {
			Log.trace(new LogMsg("ComposeGroup.addChild must have child ComposeItem supplied", [LogType.devWarning]));
			return;
		}
		if (_children.containsItem(item)) {
			Log.trace(new LogMsg("ComposeGroup.addChild already contains child item.", [LogType.devWarning]));
			return;
		}
		#end
		
		_children.add(item);
		
		item.parentItem = this;
		
		for(traitInjector in _descInjectors){
			item.addParentInjector(traitInjector);
		}
		if(_parentDescInjectors!=null){
			for(traitInjector in _parentDescInjectors){
				item.addParentInjector(traitInjector);
			}
		}
		item.setRoot(_root);
	}
	/**
	 * Removes a child ComposeItem from this ComposeGroup.
	 * @param	item		A ComposeItem object to remove as a child from this group.
	 */
	public function removeChild(item:ComposeItem):Void{
		#if debug
		if (item == null) {
			Log.trace(new LogMsg("ComposeGroup.removeChild must have child ComposeItem supplied", [LogType.devWarning]));
			return;
		}
		if (!_children.containsItem(item)) {
			Log.trace(new LogMsg("ComposeGroup.removeChild doesn't contain child item.", [LogType.devWarning]));
			return;
		}
		#end
		
		_children.remove(item);
		item.parentItem = null;
		
		for(traitInjector in _descInjectors){
			item.removeParentInjector(traitInjector);
		}
		if(_parentDescInjectors!=null){
			for(traitInjector in _parentDescInjectors){
				item.removeParentInjector(traitInjector);
			}
		}
		
		item.setRoot(null);
	}
	/**
	 * Removes all children from this ComposeGroup.
	 */
	public function removeAllItem():Void{
		while( _children.length>0 ){
			removeChild(_children.first());
		}
	}
	/**
	 * This is an interal function of Composure. Do not call this method.
	 */
	public function addChildTrait(trait:Dynamic):Void{
		_descendantTraits.addTrait(trait);
		if(_parentItem!=null)_parentItem.addChildTrait(trait);
	}
	/**
	 * This is an interal function of Composure. Do not call this method.
	 */
	public function removeChildTrait(trait:Dynamic):Void{
		_descendantTraits.removeTrait(trait);
		if(_parentItem!=null)_parentItem.removeChildTrait(trait);
	}
	/**
	 * @inheritDoc
	 */
	override public function addTrait(trait:Dynamic):Void{
		super.addTrait(trait);
		checkForNewlyIgnoredInjectors();
	}
	/**
	 * @inheritDoc
	 */
	override public function addTraits(traits:Array<Dynamic>):Void{
		super.addTraits(traits);
		checkForNewlyIgnoredInjectors();
	}
	/**
	 * @inheritDoc
	 */
	override public function removeTrait(trait:Dynamic):Void{
		super.removeTrait(trait);
		checkForNewlyUnignoredInjectors();
	}
	/**
	 * @inheritDoc
	 */
	override public function removeTraits(traits:Array<Dynamic>):Void{
		super.removeTraits(traits);
		checkForNewlyUnignoredInjectors();
	}
	/**
	 * @inheritDoc
	 */
	override public function removeAllTraits():Void{
		super.removeAllTraits();
		checkForNewlyUnignoredInjectors();
	}
	override private function addTraitInjector(injector:IInjector):Void{
		super.addTraitInjector(injector);
		if(injector.descendants){
			_descInjectors.add(injector);
			for(child in _children){
				child.addParentInjector(injector);
			}
		}
	}
	override private function removeTraitInjector(injector:IInjector):Void{
		super.removeTraitInjector(injector);
		if(_descInjectors.containsItem(injector)){
			_descInjectors.remove(injector);
			for(child in _children){
				child.removeParentInjector(injector);
			}
		}
	}
	/**
	 * Gets the first trait of a certain type from any of this groups descendant items.
	 * @param	TraitType		The type which the returned trait must implement.
	 * @return		A trait object, returns null if no matching trait is found.
	 */
	public function getDescTrait<TraitType>(TraitType:Class<TraitType>):TraitType{
		return _descendantTraits.getTrait(TraitType);
	}
	/**
	 * Gets a list of traits of a certain type from any of this groups descendant items.
	 * @param	TraitType		The type which the returned trait must implement.
	 * @return		A trait object, returns null if no matching trait is found.
	 */
	public function getDescTraits<TraitType>(TraitType:Class<TraitType>=null):Iterable<TraitType>{
		return _descendantTraits.getTraits(TraitType);
	}
	/**
	 * Calls a function once for each descendant trait that matches a certain type. This ComposeGroup and
	 * the matched trait are passed through as arguments. A function should have a signature like:<br/>
	 * <code>
	 * function myTraitFunction(item:ComposeItem, trait:ITrait):Void;
	 * </code>
	 * @see					callForTraits
	 * @param	func		The function to call.
	 * @param	TraitType	The type which the returned traits must implement.
	 * 						If no type is passed in, the function is called for all traits.
	 */
	public function callForDescTraits<TraitType>(func:ComposeItem->Dynamic->Void, TraitType:Class<TraitType>=null):Void{
		_descendantTraits.callForTraits(func, TraitType, this);
	}
	override private function onParentAdd():Void{
		super.onParentAdd();
		for(trait in _descendantTraits.traits){
			_parentItem.addChildTrait(trait);
		}
		if(_childAscInjectors!=null){
			for(injector in _childAscInjectors){
				_parentItem.addAscendingInjector(injector);
			}
		}
	}
	override private function onParentRemove():Void{
		super.onParentRemove();
		for(trait in _descendantTraits.traits){
			_parentItem.removeChildTrait(trait);
		}
		if(_childAscInjectors!=null){
			for(injector in _childAscInjectors){
				_parentItem.removeAscendingInjector(injector);
			}
		}
	}
	/**
	 * This is an interal function of Composure. Do not call this method.
	 */
	public function addAscendingInjector(injector:IInjector):Void {
		_childAscendingMarrier.addInjector(injector);
		if(injector.shouldAscend(this)){
			_addAscendingInjector(injector);
		}else {
			if(_ignoredChildAscInjectors==null)_ignoredChildAscInjectors = new UniqueList<IInjector>();
			_ignoredChildAscInjectors.add(injector);
		}
	}
	private function _addAscendingInjector(injector:IInjector):Void {
		if(_childAscInjectors==null)_childAscInjectors = new UniqueList();
		_childAscInjectors.add(injector);
		if (_parentItem != null)_parentItem.addAscendingInjector(injector);
	}
	/**
	 * This is an interal function of Composure. Do not call this method.
	 */
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
			if(_ignoredParentDescInjectors==null)_ignoredParentDescInjectors = new UniqueList<IInjector>();
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
		if (_parentDescInjectors != null) {
			
			var shouldNotDesc:List<IInjector> = Lambda.filter(_parentDescInjectors, function(inj:IInjector):Bool { return !inj.shouldDescend(this); } );
			for (inj in shouldNotDesc) {
				removeDescParentInjector(inj);
				if(_ignoredParentDescInjectors==null)_ignoredParentDescInjectors = new UniqueList<IInjector>();
				_ignoredParentDescInjectors.add(inj);
			}
		}
		if(_childAscInjectors!=null){
			var shouldNotAsc:List<IInjector> = Lambda.filter(_childAscInjectors, function(inj:IInjector):Bool { return !inj.shouldAscend(this); } );
			for (inj in shouldNotAsc) {
				_removeAscendingInjector(inj);	
				if(_ignoredChildAscInjectors==null)_ignoredChildAscInjectors = new UniqueList<IInjector>();
				_ignoredChildAscInjectors.add(inj);
			}
		}
	}
	private function checkForNewlyUnignoredInjectors():Void{
		if (_ignoredParentDescInjectors != null) {
			var shouldDesc:List<IInjector> = Lambda.filter(_ignoredParentDescInjectors, function(inj:IInjector):Bool { return inj.shouldDescend(this); } );
			for (inj in shouldDesc) {
				addDescParentInjector(inj);
				_ignoredParentDescInjectors.remove(inj);
			}
		}
		if(_ignoredChildAscInjectors!=null){
			var shouldAsc:List<IInjector> = Lambda.filter(_ignoredChildAscInjectors, function(inj:IInjector):Bool { return inj.shouldAscend(this); } );
			for (inj in shouldAsc) {
					_addAscendingInjector(inj);
					_ignoredChildAscInjectors.remove(inj);
			}
		}
	}


	private function addDescParentInjector(injector:IInjector):Void{
		if(_parentDescInjectors==null)_parentDescInjectors = new UniqueList<IInjector>();
		_parentDescInjectors.add(injector);
		for(child in _children){
			child.addParentInjector(injector);
		}
	}
	private function removeDescParentInjector(injector:IInjector):Void{
		_parentDescInjectors.remove(injector);
		for(child in _children){
			child.removeParentInjector(injector);
		}
	}
}