package composure.traitCheckers;
import composure.injectors.AbstractInjector;
import composure.traits.ITrait;
import haxe.Log;
import composure.core.ComposeGroup;
import composure.core.ComposeItem;
import org.tbyrne.logging.LogMsg;


@:keep
class GenerationChecker 
{

	/**
	 * The create method can be used to limit the scope of a certain Injector
	 * to a certain amount of generations. It generates a function which can be assigned
	 * to either the stopDescendingAt or stopAscendingAt properties of the Injector class.<br/>
	 * <br/>
	 * For example, if you wanted to get all position traits from child items (but not
	 * grandchild items) you could do something like this:
	 * <pre><code>
	 * var injector:Injector = new Injector(IPositionTrait, childPosAdded, childPosRemoved, false, true, false);
	 * injector.stopDescendingAt = GenerationChecker.create(1,true,ItemType.injectorItem);
	 * addInjector(injector);
	 * </code></pre>
	 * 
	 * @param maxGenerations The maximum amount of generations that the injector should
	 * have scope over. Defaults to '1', meaning the parent or child generation (depending on
	 * descending).
	 * 
	 * @param descending Whether the check should go up the hierarchy or down.
	 * 
	 * @param relatedItem Which ComposeItem/ComposeGroup should the generations be relative to.
	 * Defaults to the item which the trait is added.
	 */
	public static function create(maxGenerations:Int=1, descending:Bool=true, relatedItem:ItemType=null):ComposeItem->Dynamic->AbstractInjector->Bool {
		return function(item:ComposeItem, trait:Dynamic, from:AbstractInjector):Bool {
			var compare:ComposeItem;
			if(relatedItem!=null){
				switch(relatedItem) {
					case specific(other): compare = other;
					case root: compare = item.root;
					default: compare = from.ownerTrait.item;
				}
			}else {
				compare = from.ownerTrait.item;
			}
			if (descending) {
				if(Std.is(compare,ComposeGroup) && maxGenerations>0){
					return searchForDesc(maxGenerations, cast(compare, ComposeGroup), item);
				}else {
					return compare==item; // who knows right
				}
			}else {
				var parent:ComposeGroup = null;
				while (maxGenerations > 0) {
					parent = compare.parentItem;
					if (parent == null) return false;
					maxGenerations--;
				}
				return parent == item;
			}
		}
	}
	private static function searchForDesc(remainingGenerations:Int, startGroup:ComposeGroup, findItem:ComposeItem):Bool {
		var newGen:Int = remainingGenerations - 1;
		for (child in startGroup.children) {
			if (child == findItem) return true;
			if (remainingGenerations != 0) {
				if (Std.is(child, ComposeGroup)) {
					if (searchForDesc(newGen, cast(child, ComposeGroup), findItem)) {
						return true;
					}
				}
			}
		}
		return false;
	}
	
}

enum ItemType {
	specific(ItemType:ComposeItem);
	injectorItem;
	root;
}