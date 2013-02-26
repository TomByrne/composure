package composure.utilTraits;
import composure.core.ComposeItem;

/**
 * ...
 * @author Tom Byrne
 */

class LazyTraitMap<MatchType> 
{
	@:isVar public var matchType(default, null):Class<MatchType>;
	
	private var _typeCreator:TypeCreator<MatchType>;
	
	public function new(matchType:Class<MatchType>, typeCreator:TypeCreator<MatchType>) 
	{
		this.matchType = matchType;
		
		_typeCreator = typeCreator;
	}
	public function requestInstance(context:ComposeItem):MatchType {
		var ret:MatchType;
		var add:Bool = true;
		switch(_typeCreator) {
			case FClass(type, args):
				ret = Type.createInstance(type, args!=null?args:[]);
			case FFact(factory):
				ret = factory();
			case FInst(trait, addToContext):
				ret = trait;
				add = addToContext;
		}
		if(add)context.addTrait(ret);
		return ret;
	}
	public function returnInstance(context:ComposeItem, trait:MatchType):Void {
		var rem:Bool = false;
		switch(_typeCreator) {
			case FInst(trait, addToContext):
				rem = addToContext;
			default:
				//ignore
		}
		if(rem)context.removeTrait(trait);
	}
}
enum TypeCreator<MatchType> {
	FClass(type:Class<MatchType>, ?args:Array<Dynamic>);
	FFact(factory:Void->MatchType);
	FInst(trait:Dynamic, ?addToContext:Bool);
}