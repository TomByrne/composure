package composure.utilTraits;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#else
import haxe.Log;
import org.tbyrne.collections.UniqueList;
import composure.injectors.Injector;
import composure.core.ComposeGroup;
import composure.core.ComposeItem;
import composure.traits.AbstractTrait;
import org.tbyrne.logging.LogMsg;
import cmtc.ds.hash.ObjectHash;
#end

/**
 * The Furnisher class is used to add traits to an item in response
 * to a certain type of trait being added to the item.<br/>
 * <br/>
 * This is very useful when creating interchangable libraries. For example,
 * when wanting to add a platform specific display trait to a items in the
 * presence of another trait:
 * <pre><code>
 * var furnisher:Furnisher = new Furnisher(RectangleInfo, [TType(HtmlRectangleDisplay)]);
 * stage.addTrait(furnisher);
 * </code></pre>
 * In this example, any item which has a RectangleInfo trait added to it (representing
 * a rectangle's position and size) will also get a HtmlRectangleDisplay trait added to
 * it. The HtmlRectangleDisplay object can then access the RectangleInfo's size and 
 * position properties using injection metadata. In this way, the display method for
 * all rectangles could be quickly and easily be swapped out for another display trait.
 * 
 * @author Tom Byrne
 */

@:keep
class Furnisher
#if !macro
extends AbstractTrait
#end
{
	/* wraps an expression in TFact(function(tag:Dynamic):Dynamic{ return ...  expr  ...  })
	 * It will only add the return statement on the last line of your expression (if there isn't already one)
	 */
	@:macro public static function fact(expr:Expr):Expr {
		var pos = Context.currentPos();
		switch(expr.expr) {
			case EReturn(e):
				//ignore
			case EBlock(exprs):
				var lastExpr:Expr = exprs[exprs.length - 1];
				switch(lastExpr.expr) {
					case EReturn(e):
						// ignore
					default:
						exprs[exprs.length - 1] = { expr:EReturn( lastExpr ), pos:pos };
						expr.expr = EBlock(exprs);
				}
			default:
				expr = { expr:EReturn( expr ), pos:pos };
		}
		var args = [ { name : "tag", type : TPath( { name : "Dynamic", pack : [], params : [], sub : null } ), opt : false, value : null } ];
		return { expr : ECall({ expr : EConst(CIdent("TFact")), pos : pos },[{ expr : EFunction(null,{ args : args, expr : expr, params : [], ret : TPath({ name : "Dynamic", pack : [], params : [], sub : null }) }), pos : pos }]), pos : pos }
	}
	
	#if !macro
	
	public var concernedTraitType(default, set_concernedTraitType):Dynamic;
	private function set_concernedTraitType(value:Dynamic):Dynamic {
		if (_injectorAdded) {
			removeInjector(_injector);
			_injectorAdded = false;
		}
		_injector.interestedTraitType = value;
		concernedTraitType = value;
		if (concernedTraitType != null) {
			addInjector(_injector);
			_injectorAdded = true;
		}
		return value;
	}
	public var searchSiblings(default, set_searchSiblings):Bool;
	private function set_searchSiblings(value:Bool):Bool{
		if (_injectorAdded) {
			removeInjector(_injector);
		}
		_injector.siblings = value;
		searchSiblings = value;
		if(_injectorAdded){
			addInjector(_injector);
		}
		return value;
	}
	public var searchDescendants(default, set_searchDescendants):Bool;
	private function set_searchDescendants(value:Bool):Bool{
		if (_injectorAdded) {
			removeInjector(_injector);
		}
		_injector.descendants = value;
		searchDescendants = value;
		if(_injectorAdded){
			addInjector(_injector);
		}
		return value;
	}
	public var searchAscendants(default, set_searchAscendants):Bool;
	private function set_searchAscendants(value:Bool):Bool{
		if (_injectorAdded) {
			removeInjector(_injector);
		}
		_injector.ascendants = value;
		searchAscendants = value;
		if(_injectorAdded){
			addInjector(_injector);
		}
		return value;
	}
	public var checkEnumParams(get_checkEnumParams, set_checkEnumParams):Array<Int>;
	private function get_checkEnumParams():Array<Int>{
		return _injector.checkEnumParams;
	}
	private function set_checkEnumParams(value:Array<Int>):Array<Int> {
		if (_injectorAdded) {
			removeInjector(_injector);
		}
		var ret = (_injector.checkEnumParams = value);
		if (_injectorAdded) {
			addInjector(_injector);
		}
		return ret;
	}
	
	public var checkProps(get_checkProps, set_checkProps):Hash<Dynamic>;
	private function get_checkProps():Hash<Dynamic>{
		return _injector.checkProps;
	}
	private function set_checkProps(value:Hash<Dynamic>):Hash<Dynamic> {
		if (_injectorAdded) {
			removeInjector(_injector);
		}
		var ret = (_injector.checkProps = value);
		if (_injectorAdded) {
			addInjector(_injector);
		}
		return ret;
	}
	public function setCheckProps(obj:Dynamic):Void {
		var hash:Hash<Dynamic> = new Hash();
		var fields = Reflect.fields(obj);
		for (i in fields) {
			hash.set(i, Reflect.getProperty(obj, i));
		}
		checkProps = hash;
	}
	
	private var _addType:AddType;
	private var _injector:Injector;
	private var _injectorAdded:Bool;
	private var _addTraits:UniqueList<AddTrait>;
	private var _foundTraits:UniqueList<Dynamic>;
	private var _addedTraits:ObjectHash<Dynamic,Array<Dynamic>>;
	private var _traitToItems:ObjectHash<Dynamic,ComposeItem>;
	private var _originalItems:ObjectHash<Dynamic,ComposeItem>;
	private var _originalParents:ObjectHash<Dynamic,ComposeGroup>;
	
	private var _ignoreTraitChanges:Bool;
	

	public function new(?concernedTraitType:Dynamic, ?addTraits:Array<AddTrait>, ?addType:AddType, searchSiblings:Bool=true, searchDescendants:Bool=true, searchAscendants:Bool=false, ?checkEnumParams:Array<Int>) 
	{
		super();
		
		_injector = new Injector(null, onConcernedTraitAdded, onConcernedTraitRemoved, searchSiblings, searchDescendants, searchAscendants);
		_injector.passThroughItem = true;
		
		if (addType != null)_addType = addType;
		else _addType = AddType.traitItem;
		
		_addedTraits = new ObjectHash < Dynamic, Array<Dynamic> > ();
		
		_addTraits = new UniqueList<AddTrait>(addTraits);
		
		this.searchSiblings = searchSiblings;
		this.searchDescendants = searchDescendants;
		this.searchAscendants = searchAscendants;
		this.checkEnumParams = checkEnumParams;
		this.concernedTraitType = concernedTraitType;
		
	}
	
	private function onConcernedTraitAdded(trait:Dynamic, origItem:ComposeItem):Void {
		if (_ignoreTraitChanges) return;
		_ignoreTraitChanges = true;
		
		
		if (_foundTraits == null) {
			_foundTraits = new UniqueList<Dynamic>();
			_originalItems = new ObjectHash<Dynamic,ComposeItem>();
		}
		_foundTraits.add(trait);
		_originalItems.set(trait, origItem);
		
		var item:ComposeItem = registerItem(trait, origItem);
		var traitsAdded:Array<Dynamic> = [];
		for (addTrait in _addTraits) {
			var newTrait = getTrait(trait, origItem, addTrait);
			if (newTrait != null) {
				item.addTrait(newTrait);
				traitsAdded.push(newTrait);
			}
		}
		_addedTraits.set(trait, traitsAdded);
		_ignoreTraitChanges = false;
	}
	private function onConcernedTraitRemoved(trait:Dynamic, currItem:ComposeItem):Void {
		if (_ignoreTraitChanges) return;
			_ignoreTraitChanges = true;
		
		_foundTraits.remove(trait);
		
		var origItem = _originalItems.get(trait);
		_originalItems.delete(trait);
		
		var item:ComposeItem = getItem(trait);
		var traitsAdded:Array<Dynamic> = _addedTraits.get(trait);
		for (otherTrait in traitsAdded) {
			item.removeTrait(otherTrait);
		}
		_addedTraits.delete(trait);
		
		unregisterItem(trait, item, origItem);
		
		_ignoreTraitChanges = false;
	}
	public function addFact(factory:Dynamic->Dynamic, ?unlessType:Class<Dynamic>):Void {
		if (unlessType != null) {
			add(TFact(factory, [UnlessHas(unlessType)]));
		}else{
			add(TFact(factory));
		}
	}
	public function addInst(inst:Dynamic, ?unlessType:Class<Dynamic>):Void {
		if (unlessType != null) {
			add(TInst(inst, [UnlessHas(unlessType)]));
		}else{
			add(TInst(inst));
		}
	}
	public function addType(type:Class<Dynamic>, ?unlessType:Class<Dynamic>):Void {
		if (unlessType != null) {
			add(TType(type, [UnlessHas(unlessType)]));
		}else{
			add(TType(type));
		}
	}
	
	public function add(addTrait:AddTrait):Void {
		_addTraits.add(addTrait);
		
		if(_foundTraits!=null){
			for (foundTrait in _foundTraits) {
				var item = getItem(foundTrait);
				var trait = getTrait(foundTrait, item, addTrait);
				if (trait != null) {
					item.addTrait(trait);
					var traitsAdded:Array<Dynamic> = _addedTraits.get(foundTrait);
					traitsAdded.push(trait);
				}
			}
		}
	}
	
	private function getTrait(foundTrait:Dynamic, item:ComposeItem, addTrait:AddTrait):Dynamic {
		switch(addTrait) {
			case TType(t, rules):
				if (testRules(foundTrait, item, rules)) {
					return Type.createInstance(t,[]);
				}
			case TFact(f, rules):
				if (testRules(foundTrait, item, rules)) {
					return f(foundTrait);
				}
			case TInst(t, rules):
				if (testRules(foundTrait, item, rules)) {
					return t;
				}
		}
		return null;
	}
	private function testRules(foundTrait:Dynamic, item:ComposeItem, rules:Array<AddRule>):Bool {
		if (rules == null) {
			return true;
		}else {
			for (rule in rules) {
				switch(rule) {
					case IfHas(t):
						if (item.getTrait(t) == null) return false;
					case UnlessHas(t):
						if (item.getTrait(t) != null) return false;
				}
			}
			return true;
		}
	}
	
	private function getItem(trait:Dynamic):ComposeItem {
		return _traitToItems.get(trait);
	}
	private function registerItem(trait:Dynamic, origItem:ComposeItem):ComposeItem {
		if (_traitToItems == null) {
			_traitToItems = new ObjectHash<Dynamic,ComposeItem>();
		}
		var item:ComposeItem;
		var adoptTrait:Bool = false;
		
		switch(_addType) {
			case AddType.selfItem(adoptMatchedTrait):
				item = this.item;
				adoptTrait = adoptMatchedTrait;
			case AddType.traitItem:
				item = origItem;
			case AddType.adoptItem(newParent, adoptMatchedTrait):
				item = origItem;
				adoptTrait = adoptMatchedTrait;
				if (_originalParents == null) {
					_originalParents = new ObjectHash<Dynamic,ComposeGroup>();
				}
				_originalParents.set(trait, origItem.parentItem);
				if (origItem.parentItem != newParent) {
					origItem.parentItem.removeChild(origItem);
					newParent.addChild(origItem);
				}
			case AddType.item(specItem, adoptMatchedTrait):
				item = specItem;
				adoptTrait = adoptMatchedTrait;
			default:
				item = new ComposeGroup();
				switch(_addType) {
					case AddType.selfSibling(adoptMatchedTrait):
						this.item.parentItem.addChild(item);
						adoptTrait = adoptMatchedTrait;
					case AddType.traitSibling(adoptMatchedTrait):
						origItem.parentItem.addChild(item);
						adoptTrait = adoptMatchedTrait;
					case AddType.selfChild(adoptMatchedTrait):
						this.group.addChild(item);
						adoptTrait = adoptMatchedTrait;
					case AddType.traitChild(adoptMatchedTrait):
						adoptTrait = adoptMatchedTrait;
						if (Std.is(origItem, ComposeGroup)) {
							var origGroup:ComposeGroup;
							untyped origGroup = origItem;
							origGroup.addChild(item);
						}
						#if debug
						else Log.trace(new LogMsg("AddType traitChild must be used on a ComposeGroup"));
						#end
					case AddType.itemChild(group, adoptMatchedTrait):
						group.addChild(item);
						adoptTrait = adoptMatchedTrait;
					case AddType.itemSibling(sibling, adoptMatchedTrait):
						sibling.parentItem.addChild(item);
						adoptTrait = adoptMatchedTrait;
					default:
						Log.trace(new LogMsg("Unsupported AddType",[LogType.devError]));
				}
		}
		_traitToItems.set(trait, item);
		
		if (adoptTrait && item != origItem) {
			origItem.removeTrait(trait);
			item.addTrait(trait);
		}
		return item;
	}
	private function unregisterItem(trait:Dynamic, currItem:ComposeItem, origItem:ComposeItem):Void {
		var adoptTrait:Bool;
		switch(_addType) {
			case AddType.traitSibling(adoptMatchedTrait), AddType.selfSibling(adoptMatchedTrait), AddType.traitChild(adoptMatchedTrait), AddType.selfChild(adoptMatchedTrait):
				currItem.parentItem.removeChild(currItem);
				adoptTrait = adoptMatchedTrait;
			case AddType.itemChild(group, adoptMatchedTrait):
				currItem.parentItem.removeChild(currItem);
				adoptTrait = adoptMatchedTrait;
			case AddType.itemSibling(group, adoptMatchedTrait):
				currItem.parentItem.removeChild(currItem);
				adoptTrait = adoptMatchedTrait;
			case AddType.adoptItem(newParent, adoptMatchedTrait):
				var oldParent:ComposeGroup = _originalParents.get(trait);
				if (oldParent != currItem.parentItem) {
					item.parentItem.removeChild(currItem);
					oldParent.addChild(currItem);
				}
				adoptTrait = adoptMatchedTrait;
			case AddType.selfItem(adoptMatchedTrait):
				adoptTrait = adoptMatchedTrait;
			case AddType.item(specItem, adoptMatchedTrait):
				adoptTrait = adoptMatchedTrait;
			case AddType.traitItem:
				adoptTrait = false;
		}
		_traitToItems.delete(trait);
		
		if (adoptTrait && origItem != currItem) {
			currItem.removeTrait(trait);
			origItem.addTrait(trait);
		}
	}
	#end
}

#if !macro
enum AddTrait {
	TType(t:Class<Dynamic>, ?rules:Array<AddRule>);
	TFact(f:Dynamic->Dynamic, ?rules:Array<AddRule>);
	TInst(t:Dynamic, ?rules:Array<AddRule>);
}
enum AddRule {
	IfHas(t:Class<Dynamic>);
	UnlessHas(t:Class<Dynamic>);
}

enum AddType {
	adoptItem(newParent:ComposeGroup, ?adoptMatchedTrait:Bool);
	
	traitItem;
	traitSibling(?adoptMatchedTrait:Bool);
	traitChild(?adoptMatchedTrait:Bool);
	
	selfItem(?adoptMatchedTrait:Bool);
	selfSibling(?adoptMatchedTrait:Bool);
	selfChild(?adoptMatchedTrait:Bool);
	
	item(item:ComposeItem, ?adoptMatchedTrait:Bool);
	itemChild(group:ComposeGroup, ?adoptMatchedTrait:Bool);
	itemSibling(item:ComposeItem, ?adoptMatchedTrait:Bool);
}
#end