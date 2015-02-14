package composure.traits;

import haxe.Log;
import org.tbyrne.collections.UniqueList;
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
@:autoBuild(composure.macro.PromiseMacro.inject())
@:autoBuild(composure.macro.InjectorMacro.inject())
@:autoBuild(LazyInst.check())
class AbstractTrait implements ITrait
{
	/**
	 * The group to which this item is added. This is a method of convenience,
	 * and returns the 'item' property cast as a ComposeGroup.
	 */
	@:isVar public var group(default, null):ComposeGroup;
	/**
	 * The item which this trait is added to. Do not set this manually,
	 * the ComposeItem class sets this property automatically when the 
	 * trait is added to it.
	 */
	@:isVar public var item(default, set):ComposeItem;
	private function set_item(value:ComposeItem):ComposeItem{
		if(item!=value){
			if (item != null) {
				if(_siblingTraits!=null){
					for (trait in _siblingTraits) {
						item.removeTrait(trait);
					}
				}
				if(group!=null && _childItems!=null){
					for (trait in _childItems) {
						group.removeChild(trait);
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
						for (child in _childItems) {
							group.addChild(child);
						}
					}
				}
				#if debug
				if(group==null && (_groupOnly || (_childItems!=null && _childItems.length>0))){
					Log.trace(new LogMsg("Group only Trait added to non-group",LogType.devWarning));
				}
				#end
				onItemAdd();
				if(_siblingTraits!=null){
					for (trait in _siblingTraits) {
						item.addTrait(trait);
					}
				}
			}
		}
		return value;
	}


	private var _injectors:UniqueList<IInjector>;
	private var _siblingTraits:UniqueList<Dynamic>;
	private var _childItems:UniqueList<ComposeItem>;

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
	public function getInjectors():Iterable<IInjector>{
		if(_injectors==null)_injectors = new UniqueList<IInjector>();
		return _injectors;
	}

	private function addSiblingTrait(trait:Dynamic):Void{
		if(_siblingTraits==null)_siblingTraits = new UniqueList<Dynamic>();
		if(_siblingTraits.add(trait)){
			if (item != null) {
				item.addTrait(trait);
			}
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add sibling trait twice",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeSiblingTrait(trait:Dynamic):Void{
		if(_siblingTraits!=null && _siblingTraits.remove(trait)){
			if (item != null) {
				item.removeTrait(trait);
			}
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added sibling trait",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeSiblingTraits(traits:Array<Dynamic>):Void{
		for (trait in traits) {
			removeSiblingTrait(trait);
		}
	}

	private function addChildItem(child:ComposeItem):Void{
		if(_childItems==null)_childItems = new UniqueList<ComposeItem>();
		if(_childItems.add(child)){
			if (group != null) {
				group.addChild(child);
			}
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add child twice",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeChildItem(child:ComposeItem):Void{
		if(_childItems!=null && _childItems.remove(child)){
			if (group != null) {
				group.removeChild(child);
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
		if(_injectors==null)_injectors = new UniqueList<IInjector>();
		if (_injectors.add(injector)) {
			injector.ownerTraitTyped = this;
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
			injector.ownerTraitTyped = null;
			injector.ownerTrait = null;
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added injector",[LogType.performanceWarning]));
			}
		#end
	}

}