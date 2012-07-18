package composure.traits;

import haxe.Log;
import org.tbyrne.collections.IndexedList;
import composure.injectors.IInjector;
import composure.core.ComposeGroup;
import composure.core.ComposeItem;
import org.tbyrne.logging.LogMsg;

/**
 * The AbstractTrait class can be extended by any trait to gain access
 * to the trait to which it is added. It also allows traits to access
 * other traits in the application either via the injection metadata
 * or via manually adding injectors via the addInjector method.<br/>
 * <br/>
 * If, for whatever reason, it is not possible or convenient to extend 
 * AbstractTrait, it is also possible to instantiate it within your trait
 * (passing <code>this</code> in as the constructor argument) and returning this
 * instance via a <code>getProxiedTrait</code> method. To use injection metadata in
 * this situation you must also add the <code>@build(composure.macro.InjectorMacro.inject())</code>
 * metadata to your class.
 * 
 * @author		Tom Byrne
 */
@:autoBuild(composure.macro.InjectorMacro.inject())
class AbstractTrait implements ITrait
{
	/**
	 * The group to which this item is added. This is a method of convenience,
	 * and returns the 'item' property cast as a ComposeGroup.
	 */
	public var group(default, null):ComposeGroup;
	/**
	 * The item which this trait is added to. Do not set this manually,
	 * the ComposeItem class sets this property automatically when the 
	 * trait is added to it.
	 */
	public var item(default, set_item):ComposeItem;
	private function set_item(value:ComposeItem):ComposeItem{
		if(item!=value){
			if (item != null) {
				if(_siblingTraits!=null){
					for (trait in _siblingTraits.list) {
						item.removeTrait(trait);
					}
				}
				if(group!=null && _childItems!=null){
					for (trait in _childItems.list) {
						group.removeItem(trait);
					}
				}
				onItemRemove();
			}
			item = value;
			group = null;
			if(this.item!=null){
				if (Std.is(value, ComposeGroup)){
					group = cast(value, ComposeGroup);
					if(_childItems!=null){
						for (child in _childItems.list) {
							group.addItem(child);
						}
					}
				}
				#if debug
				if(group==null && (_groupOnly || (_childItems!=null && _childItems.list.length>0))){
					Log.trace(new LogMsg("Group only Trait added to non-group",LogType.devWarning));
				}
				#end
				onItemAdd();
				if(_siblingTraits!=null){
					for (trait in _siblingTraits.list) {
						item.addTrait(trait);
					}
				}
			}
		}
		return value;
	}


	private var _injectors:IndexedList<IInjector>;
	private var _siblingTraits:IndexedList<Dynamic>;
	private var _childItems:IndexedList<ComposeItem>;

	/**
	 * Set to true to force Trait to only be added for groups.
	 */
	private var _groupOnly:Bool;
	private var _ownerTrait:Dynamic;

	/**
	 * @param ownerTrait When using this Class as a Proxied Trait, pass through the actual trait
	 * object as the first parameter.
	 */
	public function new(ownerTrait:Dynamic=null) {
		_groupOnly = false;
		if (ownerTrait != null) {
			_ownerTrait = ownerTrait;
		}else {
			_ownerTrait = this;
		}
	}
	private function onItemRemove():Void{
		// override me
	}
	private function onItemAdd():Void{
		// override me
	}

	/**
	 * This provides a way for this trait to gain access to other traits in the
	 * application.
	 * @return A list of IInjectors, each one describing which traits it is concerned with.
	 */
	public function getInjectors():Array<IInjector>{
		if(_injectors==null)_injectors = new IndexedList<IInjector>();
		return _injectors.list;
	}

	private function addSiblingTrait(trait:Dynamic):Void{
		if(_siblingTraits==null)_siblingTraits = new IndexedList<Dynamic>();
		if(_siblingTraits.add(trait)){
			if (item != null) {
				item.addTrait(trait);
			}
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add sibling twice",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeSiblingTrait(trait:Dynamic):Void{
		if(_siblingTraits!=null && _siblingTraits.remove(trait)){
			if (item != null) {
				item.removeTrait(trait);
			}
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added sibling",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeSiblingTraits(traits:Array<ITrait>):Void{
		for (trait in traits) {
			removeSiblingTrait(trait);
		}
	}

	private function addChildItem(child:ComposeItem):Void{
		if(_childItems==null)_childItems = new IndexedList<ComposeItem>();
		if(_childItems.add(child)){
			if (group != null) {
				group.addItem(child);
			}
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add child twice",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeChildItem(child:ComposeItem):Void{
		if(_childItems!=null && _childItems.remove(child)){
			if (group != null) {
				group.removeItem(child);
			}
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added child",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeChildItems(children:Array<ComposeItem>):Void{
		for (child in children) {
			removeChildItem(child);
		}
	}

	/**
	 * Adds an injector to this trait, each injector is a description of a certain other trait
	 * that this trait would like access to.
	 * @param injector The injector to add to this trait.
	 */
	public function addInjector(injector:IInjector):Void{
		if(_injectors==null)_injectors = new IndexedList<IInjector>();
		if(_injectors.add(injector)){
			injector.ownerTrait = _ownerTrait;
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add injector twice",[LogType.performanceWarning]));
			}
		#end
	}
	/**
	 * Removes an injector from this trait.
	 * @see addInjector
	 * @param injector The injector to remove from this trait.
	 */
	public function removeInjector(injector:IInjector):Void{
		if(_injectors!=null && _injectors.remove(injector)){
			injector.ownerTrait = null;
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added injector",[LogType.performanceWarning]));
			}
		#end
	}

}