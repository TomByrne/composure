package org.tbyrne.composure.injectors;

import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.TraitCollection;
import time.types.ds.ObjectHash;
import haxe.Log;
import org.tbyrne.logging.LogMsg;


class InjectorMarrier
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
	public var traitInjectors(getTraitInjectors, null):IndexedList<IInjector>;
	private function getTraitInjectors():IndexedList<IInjector>{
		return _traitInjectors;
	}

	private var _traits:TraitCollection;
	private var _traitInjectors:IndexedList<IInjector>;

	// mapped injector > [traits]
	private var _injectorLookup:ObjectHash<IInjector,IndexedList<Dynamic>>;

	// mapped trait > [injectors]
	private var _traitLookup:ObjectHash < Dynamic, IndexedList<IInjector> > ;

	private var _item:ComposeItem;

	public function new(item:ComposeItem, traits:TraitCollection) {
		_traitInjectors = new IndexedList<IInjector>();
		_injectorLookup = new ObjectHash < IInjector, IndexedList<Dynamic> > ();
		_traitLookup = new ObjectHash < Dynamic, IndexedList<IInjector> > ();
		_item = item;
		this.traits = traits;
		
	}

	public function addInjector(traitInjector:IInjector):Void{
		#if debug
		if (traitInjector == null) {
			Log.trace(new LogMsg("InjectorMarrier.addInjector must have injector supplied", [LogType.devWarning]));
			return;
		}
		/*if (_traitInjectors.containsItem(traitInjector)) {
			Log.trace(new LogMsg("InjectorMarrier.addInjector already contains injector.", [LogType.devWarning]));
			return;
		}*/
		#end
		if(_traitInjectors.add(traitInjector)){
			
			for(trait in _traits.traits.list){
				compareTrait(trait, traitInjector);
			}
		}
	}
	public function removeInjector(traitInjector:IInjector):Void{
		#if debug
		if (traitInjector == null) {
			Log.trace(new LogMsg("InjectorMarrier.removeInjector must have injector supplied", [LogType.devWarning]));
			return;
		}
		/*if (!_traitInjectors.containsItem(traitInjector)) {
			Log.trace(new LogMsg("InjectorMarrier.removeInjector doesn't contain injector.", [LogType.devWarning]));
			return;
		}*/
		#end
		
		if(_traitInjectors.remove(traitInjector)){
		
			var traits:IndexedList<Dynamic> = _injectorLookup.get(traitInjector);
			if(traits!=null){
				for(trait in traits.list){
					traitInjector.injectorRemoved(trait, _item);
					
					var traitLookup:IndexedList<IInjector> = _traitLookup.get(trait);
					traitLookup.remove(traitInjector);
				}
				traits.clear();
				_injectorLookup.remove(traitInjector);
			}
		}
	}

	private function onTraitAdded(trait:Dynamic):Void{
		for(traitInjector in _traitInjectors.list){
			compareTrait(trait, traitInjector);
		}
	}

	private function onTraitRemoved(trait:Dynamic):Void{
		var injectors:IndexedList<IInjector> = _traitLookup.get(trait);
		if(injectors!=null){
			for(traitInjector in injectors.list){
				traitInjector.injectorRemoved(trait, _item);
				
				var injectorLookup:IndexedList<Dynamic> = _injectorLookup.get(traitInjector);
				injectorLookup.remove(trait);
			}
			injectors.clear();
			_traitLookup.remove(trait);
		}
	}


	private function compareTrait(trait:Dynamic, traitInjector:IInjector):Void {
		if((trait!=traitInjector.ownerTrait || traitInjector.acceptOwnerTrait) && traitInjector.isInterestedIn(trait)){
		
			// add to injector lookup
			var injectorList:IndexedList<Dynamic> = _injectorLookup.get(traitInjector);
			if(injectorList==null){
				injectorList = new IndexedList<Dynamic>();
				_injectorLookup.set(traitInjector,injectorList);
			}
			injectorList.add(trait);
			
			// add to trait lookup
			var traitList:IndexedList<IInjector> = _traitLookup.get(trait);
			if(traitList==null){
				traitList = new IndexedList<IInjector>();
				_traitLookup.set(trait, traitList);
			}
			traitList.add(traitInjector);
			
			traitInjector.injectorAdded(trait, _item);
		}
	}
}