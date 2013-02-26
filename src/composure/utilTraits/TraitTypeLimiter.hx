package composure.utilTraits;
import composure.core.ComposeItem;
import composure.injectors.AbstractInjector;
import composure.injectors.Injector;
import composure.traits.AbstractTrait;
import cmtc.ds.hash.ObjectHash;

/**
 * TraitTypeLimiter is used to restrict the amount of a certain type of trait
 * which can be added to a certain item. It could be used, for example, to limit the
 * amount of IMatrixTransform traits on a certain item to 1.<br/>
 * If the initially added trait (i.e. the last one added before maxCount was reached)
 * implements ITransmittableTrait, then the removed trait will be passed into this
 * trait using the transmitFrom method, this allows the existing trait to copy over
 * information from the new trait.<br/>
 * Typically this class is used when the end user has control over trait structures
 * to enforce certain rules.
 * @author Tom Byrne
 */

@:keep
class TraitTypeLimiter extends AbstractTrait
{
	
	@:isVar public var maxCount(default, set):Int;
	private function set_maxCount(value:Int):Int {
		if (maxCount != value) {
			maxCount = value;
			checkTraits();
		}
		return value;
	}
	
	public var policy:LimitPolicy;
	
	private var injector:Injector;
	private var added:Bool;
	
	private var _added:ObjectHash<ComposeItem, Array<Dynamic>>;
	private var _removed:ObjectHash < ComposeItem, Array<Dynamic> > ;
	
	private var _ignoreChanges:Bool;

	public function new(traitType:Class<Dynamic>=null, policy:LimitPolicy=null, maxCount:Int=1, siblings:Bool=true, descendants:Bool=false, ascendants:Bool=false) 
	{
		super();
		
		if (policy == null) {
			policy = FirstInLastOut;
		}
		
		_added = new ObjectHash();
		_removed = new ObjectHash();
		
		injector = new Injector(traitType, onTraitAdded, onTraitRemoved);
		injector.passThroughItem = true;
		
		this.maxCount = maxCount;
		this.policy = policy;
		setConcern(traitType, siblings, descendants, ascendants);
	}
	public function setConcern(traitType:Class<Dynamic>, siblings:Bool=true, descendants:Bool=false, ascendants:Bool=false):Void {
		if (added) {
			reAddAll();
			added = false;
			removeInjector(injector);
		}
		injector.interestedTraitType = traitType;
		injector.siblings = siblings;
		injector.descendants = descendants;
		injector.ascendants = ascendants;
		if (traitType != null) {
			added = true;
			addInjector(injector);
		}
	}
	
	private function reAddAll():Void {
		_ignoreChanges = true;
		var keys = _removed.keys();
		for (item in keys) {
			var removed = _removed.get(item);
			if (removed!=null && removed.length > 0) {
				var added = _added.get(item);
				while (removed.length > 0) {
					reAddTrait(item, added, removed);
				}
			}
		}
		_added = new ObjectHash();
		_removed = new ObjectHash();
		_ignoreChanges = false;
	}
	private function checkTraits():Void {
		_ignoreChanges = true;
		var keys = _added.keys();
		for (item in keys) {
			var added = _added.get(item);
			if (added.length > maxCount) {
				var removed = _removed.get(item);
				if (removed!=null) {
					while (removed.length > 0 && added.length > maxCount) {
						reAddTrait(item, added, removed);
					}
				}
			}
		}
		_ignoreChanges = false;
	}
	private function onTraitAdded(trait:Dynamic, item:ComposeItem):Void {
		if (_ignoreChanges) return;
		
		_ignoreChanges = true;
		var added = _added.get(item);
		if (added == null) {
			added = [];
			_added.set(item, added);
		}
		if (added.length == maxCount) {
			var removed = _removed.get(item);
			if (removed == null) {
				removed = [];
				_removed.set(item, removed);
			}
			switch(policy) {
				case FirstInFirstOut:
					var firstTrait = added.shift();
					removed.unshift(firstTrait);
					item.removeTrait(firstTrait);
					added.push(trait);
					attemptTransmit(trait, firstTrait);
				case FirstInLastOut:
					removed.push(trait);
					item.removeTrait(trait);
					var addedTrait = added[added.length-1];
					attemptTransmit(addedTrait, trait);
			}
		}else {
			added.push(trait);
		}
		_ignoreChanges = false;
	}
	private function onTraitRemoved(trait:Dynamic, item:ComposeItem):Void {
		if (_ignoreChanges) return;
		
		_ignoreChanges = true;
		var added = _added.get(item);
		if (added.remove(trait)) {
			var removed = _removed.get(item);
			
			if (removed != null && removed.length > 0) {
				reAddTrait(item, added, removed);
			}
		}
		_ignoreChanges = false;
	}
	private function reAddTrait(item:ComposeItem, added:Array<Dynamic>, removed:Array<Dynamic>):Void {
		var trait:Dynamic;
		switch(policy) {
			case FirstInFirstOut:
				trait = removed.shift();
				added.unshift(trait);
			case FirstInLastOut:
				trait = removed.pop();
				added.push(trait);
		}
		item.addTrait(trait);
	}
	private function attemptTransmit(toTrait:Dynamic, fromTrait:Dynamic):Void {
		if (Std.is(toTrait, ITransmittableTrait)) {
			var trans:ITransmittableTrait = cast(toTrait, ITransmittableTrait);
			trans.transmitFrom(fromTrait);
		}
	}
}
enum LimitPolicy {
	FirstInFirstOut;
	FirstInLastOut;
}
interface ITransmittableTrait {
	function transmitFrom(trait:Dynamic):Void;
}