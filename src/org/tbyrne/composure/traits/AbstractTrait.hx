package org.tbyrne.composure.traits;

import haxe.Log;
import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.concerns.IConcern;
import org.tbyrne.composure.core.ComposeGroup;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.logging.LogMsg;

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

	public var concerns(get_concerns, null):Array<IConcern>;
	private function get_concerns():Array<IConcern>{
		if(_concerns==null)_concerns = new IndexedList<IConcern>();
		return _concerns.list;
	}


	private var _concerns:IndexedList<IConcern>;
	private var _siblingTraits:IndexedList<Dynamic>;
	private var _childItems:IndexedList<ComposeItem>;

	/**
	 * Set to true to force Trait to only be added for groups.
	 */
	private var _groupOnly:Bool;

	public function new() {
		_groupOnly = false;	
	}
	private function onItemRemove():Void{
		// override me
	}
	private function onItemAdd():Void{
		// override me
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

	private function addConcern(concern:IConcern):Void{
		if(_concerns==null)_concerns = new IndexedList<IConcern>();
		if(_concerns.add(concern)){
			concern.ownerTrait = this;
		}#if debug else{
				Log.trace(new LogMsg("Attempting to add concern twice",[LogType.performanceWarning]));
			}
		#end
	}
	private function removeConcern(concern:IConcern):Void{
		if(_concerns!=null && _concerns.remove(concern)){
			concern.ownerTrait = null;
		}#if debug else{
				Log.trace(new LogMsg("Attempting to remove non-added concern",[LogType.performanceWarning]));
			}
		#end
	}

}