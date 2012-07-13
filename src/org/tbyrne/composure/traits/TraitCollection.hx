package org.tbyrne.composure.traits;

import haxe.Log;
import org.tbyrne.logging.LogMsg;

import org.tbyrne.collections.IndexedList;
import org.tbyrne.composure.core.ComposeItem;

import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

import time.types.ds.ObjectHash;

/**
 * The TraitCollection holds a collection of traits and has the
 * ability to compare them to a collection of injectors. This is 
 * used internally in Composure.
 * 
 * @author Tom Byrne
 */
class TraitCollection
{
	
	public var traitAdded(getTraitAdded, null):Signaler<Dynamic>;
	private function getTraitAdded():Signaler < Dynamic> {
		if (_traitAdded == null)_traitAdded = new DirectSignaler(this);
		return _traitAdded;
	}
	public var traitRemoved(getTraitRemoved, null):Signaler<Dynamic>;
	private function getTraitRemoved():Signaler<Dynamic>{
		if (_traitRemoved == null)_traitRemoved = new DirectSignaler(this);
		return _traitRemoved;
	}

	private var _traitRemoved:Signaler<Dynamic>;
	private var _traitAdded:Signaler<Dynamic>;
	private var _traitTypeCache:Hash < TraitTypeCache<Dynamic> > ;
	
	public var traits(default, null):IndexedList<Dynamic>;


	public function new()
	{
		_traitTypeCache = new Hash< TraitTypeCache<Dynamic>>();
		traits = new IndexedList<Dynamic>();
	}

	public function getTrait<TraitType>(TraitType:Class<TraitType>):TraitType{
		
		if(TraitType==null){
			Log.trace("TraitCollection.getTrait must be supplied an ITrait class to match");
			return null;
		}else{
			var cache:TraitTypeCache<TraitType> = validateCache(TraitType);
			if(cache!=null){
				return cache.getTrait;
			}else {
				return null;
			}
		}
	}
	public function getTraits<TraitType>(TraitType:Class<TraitType> = null):Array<TraitType> {
		var cache:TraitTypeCache<TraitType> = validateCache(TraitType);
		if(cache!=null){
			return cache.getTraits;
		}else {
			return null;
		}
	}

	public function validateCache<TraitType>(matchType:Class<TraitType>):TraitTypeCache<TraitType> {
		#if debug
		if(matchType==null)Log.trace(new LogMsg("TraitCollection.validateCache must be called with a matchType",[LogType.devError]));
		#end
		
		var typeName:String = Type.getClassName(matchType);
		
		var cache:TraitTypeCache<TraitType>;
		untyped{
			cache = _traitTypeCache.get(typeName);
		}
		var invalid;
		
		if(cache!=null){
			invalid = cache.invalid;
		}else{
			cache = new TraitTypeCache<TraitType>();
			_traitTypeCache.set(typeName, cache);
			invalid = traits;
		}
		if(!cache.methodCachesSafe){
			for(trait in invalid.list){
				if(Std.is(trait, matchType)){
					untyped cache.matched.add(trait);
				}
			}
			cache.invalid.clear();
			cache.methodCachesSafe = true;
			cache.getTraits = cache.matched.list;
			cache.getTrait = cache.getTraits[0];
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
		var invalid;
		
		if(cache!=null){
			for(trait in cache.matched.list){
				realParams[1] = trait;
				Reflect.callMethod(thisObj, func, realParams);
			}
			invalid = cache.invalid;
		}else{
			if(matchingType){
				cache = new TraitTypeCache();
				_traitTypeCache.set(typeName, cache);
			}
			invalid = traits;
		}
		if(matchingType){
			if(cache!=null && cache.methodCachesSafe==false){
				for(trait in invalid.list){
					if(Std.is(trait, matchType)){
						realParams[1] = trait;
						if (matchingType) untyped cache.matched.add(trait);
						if (collectReturns != null){
							collectReturns.push(Reflect.callMethod(thisObj, func, realParams));
						}else {
							Reflect.callMethod(thisObj, func, realParams);
						}
					}
				}
				cache.invalid.clear();
				cache.methodCachesSafe = true;
				cache.getTraits = cache.matched.list;
				cache.getTrait = cache.getTraits[0];
			}
		}else{
			for(trait in invalid.list){
				realParams[1] = trait;
				if (collectReturns != null){
					collectReturns.push(Reflect.callMethod(thisObj, func, realParams));
				}else {
					Reflect.callMethod(thisObj, func, realParams);
				}
			}
		}
	}
	public function addTrait(trait:Dynamic):Void {
		traits.add(trait);
		//var type:Class<Dynamic>;
		for (cache in _traitTypeCache) {
			//var cache = _traitTypeCache.get(type);
			cache.invalid.add(trait);
			cache.methodCachesSafe = false;
		}
		if (_traitAdded != null)_traitAdded.dispatch(trait);
	}
	public function removeTrait(trait:Dynamic):Void{
		traits.remove(trait);
		//var type:Class<Dynamic>;
		for (cache in _traitTypeCache) {
			//var cache = _traitTypeCache.get(type);
			cache.matched.remove(trait);
			cache.invalid.remove(trait);
			cache.methodCachesSafe = false;
		}
		if(_traitRemoved!=null)_traitRemoved.dispatch(trait);
	}
}

private class TraitTypeCache<TraitType>
{
	public var methodCachesSafe:Bool;
	public var getTrait:TraitType;
	public var getTraits:Array<TraitType>;

	public var matched:IndexedList<TraitType>;
	public var invalid:IndexedList<Dynamic>;
	
	public function new() {
		matched = new IndexedList<TraitType>();
		invalid = new IndexedList<Dynamic>();
	}
}