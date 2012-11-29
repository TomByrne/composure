package composure.traits;

import haxe.Log;
import org.tbyrne.logging.LogMsg;

import org.tbyrne.collections.UniqueList;
import composure.core.ComposeItem;
import cmtc.ds.hash.ObjectHash;
import composure.traits.ITrait;

import msignal.Signal;


/**
 * The TraitCollection holds a collection of traits and has the
 * ability to compare them to a collection of injectors. This is 
 * used internally in Composure.
 * 
 * @author Tom Byrne
 */
@:build(LazyInst.check())
class TraitCollection
{
	@lazyInst
	public var traitAdded:Signal1<TraitPair<Dynamic>>;
	
	@lazyInst
	public var traitRemoved:Signal1<TraitPair<Dynamic>>;
	
	public var testSignal(get_testSignal, null):Signal1<Dynamic>;
	private function get_testSignal():Signal1<Dynamic>{
		if (_testSignal == null)_testSignal = new Signal1();
		return _testSignal;
	}
	private var _testSignal:Signal1<Dynamic>;
	
	private var _traitTypeCache:Hash < TraitTypeCache<Dynamic> > ;
	
	public var traitPairs(default, null):UniqueList<TraitPair<Dynamic>>;

	public function new()
	{
		_traitTypeCache = new Hash();
		traitPairs = new UniqueList();
	}

	public function getTrait(traitType:Dynamic):Dynamic{
		
		if(traitType==null){
			Log.trace("TraitCollection.getTrait must be supplied an ITrait class to match");
			return null;
		}else{
			var cache:TraitTypeCache<Dynamic> = validateCache(traitType);
			if(cache!=null){
				return cache.getTrait;
			}else {
				return null;
			}
		}
	}
	public function getTraits(traitType:Dynamic = null):Iterable<Dynamic> {
		var cache:TraitTypeCache<Dynamic> = validateCache(traitType);
		if(cache!=null){
			return cache.getTraits;
		}else {
			return null;
		}
	}

	public function validateCache(matchType:Dynamic):TraitTypeCache<Dynamic> {
		#if debug
		if(matchType==null)Log.trace(new LogMsg("TraitCollection.validateCache must be called with a matchType",[LogType.devError]));
		#end
		
		var typeName:String;
		if(Std.is(matchType, Enum)){
			typeName = Type.getEnumName(matchType);
		}else{
			typeName = Type.getClassName(matchType);
		}
		
		var cache:TraitTypeCache<Dynamic>;
		untyped{
			cache = _traitTypeCache.get(typeName);
		}
		var invalid:UniqueList<TraitPair<Dynamic>>;
		
		if(cache!=null){
			invalid = cache.invalid;
		}else{
			cache = new TraitTypeCache<Dynamic>();
			_traitTypeCache.set(typeName, cache);
			invalid = traitPairs;
		}
		if(!cache.methodCachesSafe){
			for(traitPair in invalid){
				if(Std.is(traitPair.trait, matchType)){
					untyped cache.matched.add(traitPair);
					untyped cache.getTraitsList.add(traitPair.trait);
				}
			}
			cache.invalid.clear();
			cache.methodCachesSafe = true;
			cache.getTrait = cache.getTraitsList.first();
		}
		return cache;
	}
	public function callForTraits<TraitType>(func:Dynamic, matchType:Class<TraitType>, thisObj:ComposeItem, ?params:Array<Dynamic>, ?collectReturns:Array<Dynamic>):Void{
		var matchingType:Bool = (matchType != null);
		var cache:TraitTypeCache<TraitType>;
		var typeName:String;
		if (matchingType) {
			typeName = Type.getClassName(matchType);
			untyped cache = _traitTypeCache.get(typeName);
		}else {
			cache = null;
			typeName = null;
		}
		
		var realParams:Array<Dynamic> = [thisObj,null];
		if(params!=null){
			realParams = realParams.concat(params);
		}
		var invalid:UniqueList<TraitPair<Dynamic>>;
		
		if(cache!=null){
			for(traitPair in cache.matched){
				realParams[1] = traitPair.trait;
				Reflect.callMethod(thisObj, func, realParams);
			}
			invalid = cache.invalid;
		}else{
			if(matchingType){
				cache = new TraitTypeCache();
				_traitTypeCache.set(typeName, cache);
			}
			invalid = traitPairs;
		}
		if(matchingType){
			if(cache!=null && cache.methodCachesSafe==false){
				for(traitPair in invalid){
					if(Std.is(traitPair.trait, matchType)){
						realParams[1] = traitPair.trait;
						if (matchingType) {
							untyped cache.matched.add(traitPair);
							untyped cache.getTraitsList.add(traitPair.trait);
						}
						if (collectReturns != null){
							collectReturns.push(Reflect.callMethod(thisObj, func, realParams));
						}else {
							Reflect.callMethod(thisObj, func, realParams);
						}
					}
				}
				cache.invalid.clear();
				cache.methodCachesSafe = true;
				cache.getTrait = cache.getTraitsList.first();
			}
		}else{
			for(trait in invalid){
				realParams[1] = trait;
				if (collectReturns != null){
					collectReturns.push(Reflect.callMethod(thisObj, func, realParams));
				}else {
					Reflect.callMethod(thisObj, func, realParams);
				}
			}
		}
	}
	public function addTrait(traitPair:TraitPair<Dynamic>):Void {
		traitPairs.add(traitPair);
		for (cache in _traitTypeCache) {
			cache.invalid.add(traitPair);
			cache.methodCachesSafe = false;
		}
		LazyInst.exec(traitAdded.dispatch(traitPair));
	}
	public function removeTrait(traitPair:TraitPair<Dynamic>):Void{
		traitPairs.remove(traitPair);
		for (cache in _traitTypeCache) {
			cache.getTraitsList.remove(traitPair.trait);
			cache.matched.remove(traitPair);
			cache.invalid.remove(traitPair);
			cache.methodCachesSafe = false;
		}
		LazyInst.exec(traitRemoved.dispatch(traitPair));
	}
}

private class TraitTypeCache<TraitType>
{
	public var methodCachesSafe:Bool;
	public var getTrait:TraitType;
	public var getTraits:Iterable<TraitType>;
	public var getTraitsList:UniqueList<TraitType>;

	public var matched:UniqueList<TraitPair<TraitType>>;
	public var invalid:UniqueList<TraitPair<TraitType>>;
	
	public function new() {
		matched = new UniqueList<TraitPair<TraitType>>();
		invalid = new UniqueList<TraitPair<TraitType>>();
		getTraitsList = new UniqueList<TraitType>();
		getTraits = getTraitsList;
	}
}