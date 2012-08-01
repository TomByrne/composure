package composure.injectors;

import org.tbyrne.collections.UniqueList;
import composure.core.ComposeItem;
import composure.traits.TraitCollection;
import cmtc.ds.hash.ObjectHash;
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
	public var traitInjectors(getTraitInjectors, null):UniqueList<IInjector>;
	private function getTraitInjectors():UniqueList<IInjector>{
		return _traitInjectors;
	}

	private var _traits:TraitCollection;
	private var _traitInjectors:UniqueList<IInjector>;

	// mapped injector > [traits]
	private var _injectorLookup:ObjectHash<IInjector,UniqueList<Dynamic>>;

	// mapped trait > [injectors]
	private var _traitLookup:ObjectHash < Dynamic, UniqueList<IInjector> > ;

	private var _item:ComposeItem;

	public function new(item:ComposeItem, traits:TraitCollection) {
		_traitInjectors = new UniqueList<IInjector>();
		_injectorLookup = new ObjectHash < IInjector, UniqueList<Dynamic> > ();
		_traitLookup = new ObjectHash < Dynamic, UniqueList<IInjector> > ();
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
			
			for(trait in _traits.traits){
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
		
			var traits:UniqueList<Dynamic> = _injectorLookup.get(traitInjector);
			if(traits!=null){
				for(trait in traits){
					traitInjector.injectorRemoved(trait, _item);
					
					var traitLookup:UniqueList<IInjector> = _traitLookup.get(trait);
					traitLookup.remove(traitInjector);
				}
				traits.clear();
				_injectorLookup.remove(traitInjector);
			}
		}
	}

	private function onTraitAdded(trait:Dynamic):Void{
		for(traitInjector in _traitInjectors){
			compareTrait(trait, traitInjector);
		}
	}

	private function onTraitRemoved(trait:Dynamic):Void{
		var injectors:UniqueList<IInjector> = _traitLookup.get(trait);
		if(injectors!=null){
			for(traitInjector in injectors){
				traitInjector.injectorRemoved(trait, _item);
				
				var injectorLookup:UniqueList<Dynamic> = _injectorLookup.get(traitInjector);
				injectorLookup.remove(trait);
			}
			injectors.clear();
			_traitLookup.remove(trait);
		}
	}


	private function compareTrait(trait:Dynamic, traitInjector:IInjector):Void {
		if((trait!=traitInjector.ownerTrait || traitInjector.acceptOwnerTrait) && traitInjector.isInterestedIn(_item, trait)){
		
			// add to injector lookup
			var injectorList:UniqueList<Dynamic> = _injectorLookup.get(traitInjector);
			if(injectorList==null){
				injectorList = new UniqueList<Dynamic>();
				_injectorLookup.set(traitInjector,injectorList);
			}
			injectorList.add(trait);
			
			// add to trait lookup
			var traitList:UniqueList<IInjector> = _traitLookup.get(trait);
			if(traitList==null){
				traitList = new UniqueList<IInjector>();
				_traitLookup.set(trait, traitList);
			}
			traitList.add(traitInjector);
			
			traitInjector.injectorAdded(trait, _item);
		}
	}
}