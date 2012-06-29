package org.tbyrne.composure.concerns;

import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.TraitCollection;
import time.types.ds.ObjectHash;
import haxe.Log;
import org.tbyrne.logging.LogMsg;


class ConcernMarrier
{

	public var traits(get_traits, set_traits):TraitCollection;
	private function get_traits():TraitCollection{
		return _traits;
	}
	private function set_traits(value:TraitCollection):TraitCollection{
		if(_traits!=value){
			if(_traits!=null){
				_traits.traitAdded.unbind(onTraitAdded);
				_traits.traitRemoved.unbind(onTraitRemoved);
			}
			_traits = value;
			if(_traits!=null){
				_traits.traitAdded.bind(onTraitAdded);
				_traits.traitRemoved.bind(onTraitRemoved);
			}
		}
		return value;
	}
	public var traitConcerns(getTraitConcerns, null):IndexedList<IConcern>;
	private function getTraitConcerns():IndexedList<IConcern>{
		return _traitConcerns;
	}

	private var _traits:TraitCollection;
	private var _traitConcerns:IndexedList<IConcern>;

	// mapped concern > [traits]
	private var _concernLookup:ObjectHash<IConcern,IndexedList<Dynamic>>;

	// mapped trait > [concerns]
	private var _traitLookup:ObjectHash < Dynamic, IndexedList<IConcern> > ;

	private var _item:ComposeItem;

	public function new(item:ComposeItem, traits:TraitCollection) {
		_traitConcerns = new IndexedList<IConcern>();
		_concernLookup = new ObjectHash < IConcern, IndexedList<Dynamic> > ();
		_traitLookup = new ObjectHash < Dynamic, IndexedList<IConcern> > ();
		_item = item;
		this.traits = traits;
		
	}

	public function addConcern(traitConcern:IConcern):Void{
		#if debug
		if (traitConcern == null) {
			Log.trace(new LogMsg("ConcernMarrier.addConcern must have concern supplied", [LogType.devWarning]));
			return;
		}
		/*if (_traitConcerns.containsItem(traitConcern)) {
			Log.trace(new LogMsg("ConcernMarrier.addConcern already contains concern.", [LogType.devWarning]));
			return;
		}*/
		#end
		if(_traitConcerns.add(traitConcern)){
			
			for(trait in _traits.traits.list){
				compareTrait(trait, traitConcern);
			}
		}
		//testCheck();
	}
	public function removeConcern(traitConcern:IConcern):Void{
		#if debug
		if (traitConcern == null) {
			Log.trace(new LogMsg("ConcernMarrier.removeConcern must have concern supplied", [LogType.devWarning]));
			return;
		}
		/*if (!_traitConcerns.containsItem(traitConcern)) {
			Log.trace(new LogMsg("ConcernMarrier.removeConcern doesn't contain concern.", [LogType.devWarning]));
			return;
		}*/
		#end
		
		if(_traitConcerns.remove(traitConcern)){
		
			var traits:IndexedList<Dynamic> = _concernLookup.get(traitConcern);
			if(traits!=null){
				for(trait in traits.list){
					traitConcern.concernRemoved(trait, _item);
					
					var traitLookup:IndexedList<IConcern> = _traitLookup.get(trait);
					traitLookup.remove(traitConcern);
				}
				traits.clear();
				_concernLookup.remove(traitConcern);
			}
		}
		//testCheck();
	}

	/*private function testCheck():Void
	{
		for each(var traitLookup:IndexedList<IConcern> in _traitLookup){
		if(traitLookup.list.length>_traitConcerns.list.length){
			Log.error("Holy Funk");
		}
		}
		for each(var concernLookup:IndexedList<Dynamic> in _concernLookup){
		if(concernLookup.list.length>_traits.traits.list.length){
			Log.error("Holy Funk");
		}
		}
	}*/

	private function onTraitAdded(trait:Dynamic):Void{
		for(traitConcern in _traitConcerns.list){
			compareTrait(trait, traitConcern);
		}
		//testCheck();
	}

	private function onTraitRemoved(trait:Dynamic):Void{
		var concerns:IndexedList<IConcern> = _traitLookup.get(trait);
		if(concerns!=null){
			for(traitConcern in concerns.list){
				traitConcern.concernRemoved(trait, _item);
				
				var concernLookup:IndexedList<Dynamic> = _concernLookup.get(traitConcern);
				concernLookup.remove(trait);
			}
			concerns.clear();
			_traitLookup.remove(trait);
		}
		//testCheck();
	}


	private function compareTrait(trait:Dynamic, traitConcern:IConcern):Void {
		if((trait!=traitConcern.ownerTrait || traitConcern.acceptOwnerTrait) && traitConcern.isInterestedIn(trait)){
		
			// add to concern lookup
			var concernList:IndexedList<Dynamic> = _concernLookup.get(traitConcern);
			if(concernList==null){
				concernList = new IndexedList<Dynamic>();
				_concernLookup.set(traitConcern,concernList);
			}
			concernList.add(trait);
			
			// add to trait lookup
			var traitList:IndexedList<IConcern> = _traitLookup.get(trait);
			if(traitList==null){
				traitList = new IndexedList<IConcern>();
				_traitLookup.set(trait, traitList);
			}
			traitList.add(traitConcern);
			
			traitConcern.concernAdded(trait, _item);
		}
		//testCheck();
	}
}