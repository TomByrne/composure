package org.tbyrne.composure.traits;

import haxe.Log;
import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.injectors.IInjector;
import org.tbyrne.composure.core.ComposeGroup;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.restrictions.ITraitRestriction;
import org.tbyrne.logging.LogMsg;

@:autoBuild(org.tbyrne.composure.macro.InjectorMacro.inject())
class AbstractTrait implements ITrait
{
	public var group(default, null):ComposeGroup;
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
	private var _restrictions:IndexedList<ITraitRestriction>;
	private var _siblingTraits:IndexedList<Dynamic>;
	private var _childItems:IndexedList<ComposeItem>;

	/**
	 * Set to true to force Trait to only be added for groups.
	 */
	private var _groupOnly:Bool;
	private var _ownerTrait:Dynamic;

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

	public function getInjectors():Array<IInjector>{
		if(_injectors==null)_injectors = new IndexedList<IInjector>();
		return _injectors.list;
	}
	public function getRestrictions():Array<ITraitRestriction>{
		if(_restrictions==null)_restrictions = new IndexedList<ITraitRestriction>();
		return _restrictions.list;
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

	public function addInjector(injector:IInjector):Void{
		if(_injectors==null)_injectors = new IndexedList<IInjector>();
		if(_injectors.add(injector)){
			injector.ownerTrait = _ownerTrait;
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add injector twice",[LogType.performanceWarning]));
			}
		#end
	}
	public function removeInjector(injector:IInjector):Void{
		if(_injectors!=null && _injectors.remove(injector)){
			injector.ownerTrait = null;
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added injector",[LogType.performanceWarning]));
			}
		#end
	}


	private function addRestriction(restriction:ITraitRestriction):Void{
		if(_restrictions==null)_restrictions = new IndexedList<ITraitRestriction>();
		if(_restrictions.add(restriction)){
			
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add restriction twice",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeRestriction(restriction:ITraitRestriction):Void{
		if(_injectors!=null && _restrictions.remove(restriction)){
			
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added restriction",[LogType.performanceWarning]));
			}
		#end
	}

}