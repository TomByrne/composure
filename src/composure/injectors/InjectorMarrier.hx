package composure.injectors;

import org.tbyrne.collections.UniqueList;
import composure.core.ComposeItem;
import composure.traits.TraitCollection;
import cmtc.ds.hash.ObjectHash;
import haxe.Log;
import org.tbyrne.logging.LogMsg;
import composure.traits.ITrait;


class InjectorMarrier
{

	public var traits(get_traits, set_traits):TraitCollection;
	private function get_traits():TraitCollection{
		return _traits;
	}
	private function set_traits(value:TraitCollection):TraitCollection{
		if(_traits!=value){
			if(_traits!=null){
				_traits.traitAdded.remove(onTraitAdded);
				_traits.traitRemoved.remove(onTraitRemoved);
			}
			_traits = value;
			if(_traits!=null){
				_traits.traitAdded.add(onTraitAdded);
				_traits.traitRemoved.add(onTraitRemoved);
			}
		}
		return value;
	}
	public var traitInjectors(getTraitInjectors, null):UniqueList<IInjector>;
	private function getTraitInjectors():UniqueList<IInjector>{
		return _traitInjectors;
	}

	private var _traits:TraitCollection;
	private var _traitInjectors:UniqueList<IInjector>;

	// mapped injector > [traits]
	private var _injectorLookup:ObjectHash<IInjector,UniqueList<TraitPair<Dynamic>>>;

	// mapped trait > [injectors]
	private var _traitLookup:ObjectHash < Dynamic, UniqueList<IInjector> > ;

	public function new(traits:TraitCollection) {
		_traitInjectors = new UniqueList<IInjector>();
		_injectorLookup = new ObjectHash < IInjector, UniqueList<TraitPair<Dynamic>> > ();
		_traitLookup = new ObjectHash < Dynamic, UniqueList<IInjector> > ();
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
			
			for(traitPair in _traits.traitPairs){
				compareTrait(traitPair, traitInjector);
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
		
			var traitPairs:UniqueList<TraitPair<Dynamic>> = _injectorLookup.get(traitInjector);
			if(traitPairs!=null){
				for(traitPair in traitPairs){
					traitInjector.injectorRemoved(traitPair.trait, traitPair.item);
					
					var traitLookup:UniqueList<IInjector> = _traitLookup.get(traitPair.trait);
					traitLookup.remove(traitInjector);
				}
				traitPairs.clear();
				_injectorLookup.delete(traitInjector);
			}
		}
	}

	private function onTraitAdded(traitPair:TraitPair<Dynamic>):Void{
		for(traitInjector in _traitInjectors){
			compareTrait(traitPair, traitInjector);
		}
	}

	private function onTraitRemoved(traitPair:TraitPair<Dynamic>):Void{
		var injectors:UniqueList<IInjector> = _traitLookup.get(traitPair.trait);
		if(injectors!=null){
			for(traitInjector in injectors){
				traitInjector.injectorRemoved(traitPair.trait, traitPair.item);
				
				var injectorLookup:UniqueList<Dynamic> = _injectorLookup.get(traitInjector);
				injectorLookup.remove(traitPair.trait);
			}
			injectors.clear();
			_traitLookup.delete(traitPair.trait);
		}
	}


	private function compareTrait(traitPair:TraitPair<Dynamic>, traitInjector:IInjector):Void {
		if((traitPair.trait!=traitInjector.ownerTrait || traitInjector.acceptOwnerTrait) && traitInjector.isInterestedIn(traitPair.item, traitPair.trait)){
		
			// add to injector lookup
			var injectorList:UniqueList<TraitPair<Dynamic>> = _injectorLookup.get(traitInjector);
			if(injectorList==null){
				injectorList = new UniqueList<TraitPair<Dynamic>>();
				_injectorLookup.set(traitInjector,injectorList);
			}
			injectorList.add(traitPair);
			
			// add to trait lookup
			var traitList:UniqueList<IInjector> = _traitLookup.get(traitPair.trait);
			if(traitList==null){
				traitList = new UniqueList<IInjector>();
				_traitLookup.set(traitPair.trait, traitList);
			}
			traitList.add(traitInjector);
			
			traitInjector.injectorAdded(traitPair, traitPair.item);
		}
	}
}