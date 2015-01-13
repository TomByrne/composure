(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function inherit() {}; inherit.prototype = from; var proto = new inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { }
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.remove = function(a,obj) {
	var i = 0;
	var l = a.length;
	while(i < l) {
		if(a[i] == obj) {
			a.splice(i,1);
			return true;
		}
		i++;
	}
	return false;
}
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
}
var Lambda = function() { }
Lambda.__name__ = ["Lambda"];
Lambda.exists = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) return true;
	}
	return false;
}
Lambda.filter = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) l.add(x);
	}
	return l;
}
var LazyInst = function() { }
LazyInst.__name__ = ["LazyInst"];
var List = function() {
	this.length = 0;
};
List.__name__ = ["List"];
List.prototype = {
	iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,__class__: List
}
var IMap = function() { }
IMap.__name__ = ["IMap"];
var Reflect = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
	}
	return v;
}
Reflect.getProperty = function(o,field) {
	var tmp;
	return o == null?null:o.__properties__ && (tmp = o.__properties__["get_" + field])?o[tmp]():o[field];
}
Reflect.setProperty = function(o,field,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + field])) o[tmp](value); else o[field] = value;
}
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
}
Reflect.compareMethods = function(f1,f2) {
	if(f1 == f2) return true;
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) return false;
	return f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
}
var Std = function() { }
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
var ValueType = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { }
Type.__name__ = ["Type"];
Type.getEnum = function(o) {
	if(o == null) return null;
	return o.__enum__;
}
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
}
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
}
Type.createInstance = function(cl,args) {
	switch(args.length) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw "Too many arguments";
	}
	return null;
}
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = v.__class__;
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
}
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e ) {
		return false;
	}
	return true;
}
Type.enumParameters = function(e) {
	return e.slice(2);
}
Type.enumIndex = function(e) {
	return e[1];
}
var composure = {}
composure.core = {}
composure.core.ComposeItem = function(initTraits) {
	this._traitCollection = new composure.traits.TraitCollection();
	this._siblingMarrier = new composure.injectors.InjectorMarrier(this._traitCollection);
	this._parentMarrier = new composure.injectors.InjectorMarrier(this._traitCollection);
	this._traitToCast = new haxe.ds.ObjectMap();
	this._traitToPair = new haxe.ds.ObjectMap();
	if(initTraits != null) this.addTraits(initTraits);
};
composure.core.ComposeItem.__name__ = ["composure","core","ComposeItem"];
composure.core.ComposeItem.getRealTrait = function(trait) {
	var getProxyTrait = Reflect.field(trait,"getProxiedTrait");
	if(getProxyTrait != null) {
		var proxy = trait.getProxiedTrait();
		if(js.Boot.__instanceof(proxy,composure.traits.ITrait)) return js.Boot.__cast(proxy , composure.traits.ITrait);
	}
	if(js.Boot.__instanceof(trait,composure.traits.ITrait)) return js.Boot.__cast(trait , composure.traits.ITrait);
	return null;
}
composure.core.ComposeItem.prototype = {
	removeParentInjector: function(injector) {
		this._parentMarrier.removeInjector(injector);
	}
	,addParentInjector: function(injector) {
		this._parentMarrier.addInjector(injector);
	}
	,onRootRemove: function() {
		if(this._uniInjectors != null) {
			var $it0 = this._uniInjectors.iterator();
			while( $it0.hasNext() ) {
				var injector = $it0.next();
				this._root.removeUniversalInjector(injector);
			}
		}
	}
	,onRootAdd: function() {
		if(this._uniInjectors != null) {
			var $it0 = this._uniInjectors.iterator();
			while( $it0.hasNext() ) {
				var injector = $it0.next();
				this._root.addUniversalInjector(injector);
			}
		}
	}
	,onParentRemove: function() {
		var $it0 = this._traitCollection.traitPairs.iterator();
		while( $it0.hasNext() ) {
			var traitPair = $it0.next();
			this._parentItem.removeChildTrait(traitPair);
		}
		if(this._ascInjectors != null) {
			var $it1 = this._ascInjectors.iterator();
			while( $it1.hasNext() ) {
				var injector = $it1.next();
				this._parentItem.removeAscendingInjector(injector);
			}
		}
	}
	,onParentAdd: function() {
		var $it0 = this._traitCollection.traitPairs.iterator();
		while( $it0.hasNext() ) {
			var traitPair = $it0.next();
			this._parentItem.addChildTrait(traitPair);
		}
		if(this._ascInjectors != null) {
			var $it1 = this._ascInjectors.iterator();
			while( $it1.hasNext() ) {
				var injector = $it1.next();
				this._parentItem.addAscendingInjector(injector);
			}
		}
	}
	,removeTraitInjector: function(injector) {
		if(injector.siblings) this._siblingMarrier.removeInjector(injector);
		if(injector.ascendants) {
			this._ascInjectors.remove(injector);
			if(this._parentItem != null) this._parentItem.removeAscendingInjector(injector);
		}
		if(injector.universal) {
			this._uniInjectors.remove(injector);
			if(this._root != null) this._root.removeUniversalInjector(injector);
		}
	}
	,addTraitInjector: function(injector) {
		if(injector.siblings) this._siblingMarrier.addInjector(injector);
		if(injector.ascendants) {
			if(this._ascInjectors == null) this._ascInjectors = new org.tbyrne.collections.UniqueList();
			this._ascInjectors.add(injector);
			if(this._parentItem != null) this._parentItem.addAscendingInjector(injector);
		}
		if(injector.universal) {
			if(this._uniInjectors == null) this._uniInjectors = new org.tbyrne.collections.UniqueList();
			this._uniInjectors.add(injector);
			if(this._root != null) this._root.addUniversalInjector(injector);
		}
	}
	,_removeTrait: function(trait) {
		var traitPair = this._traitToPair.get(trait);
		this._traitToPair.remove(trait);
		var castTrait = this._traitToCast.get(trait);
		if(castTrait != null) {
			var castInjectors = castTrait.getInjectors();
			var $it0 = $iterator(castInjectors)();
			while( $it0.hasNext() ) {
				var injector = $it0.next();
				this.removeTraitInjector(injector);
			}
			this._traitToCast.remove(trait);
		}
		this._traitCollection.removeTrait(traitPair);
		if(this._parentItem != null) this._parentItem.removeChildTrait(traitPair);
		if(castTrait != null) castTrait.set_item(null);
	}
	,removeAllTraits: function() {
		while(this._traitCollection.traitPairs.get_length() > 0) this._removeTrait(this._traitCollection.traitPairs.first());
	}
	,removeTraits: function(traits) {
		var _g = 0;
		while(_g < traits.length) {
			var trait = traits[_g];
			++_g;
			this._removeTrait(trait);
		}
	}
	,removeTrait: function(trait) {
		this._removeTrait(trait);
	}
	,_addTrait: function(trait) {
		var traitPair = { trait : trait, item : this};
		this._traitToPair.set(trait,traitPair);
		var castTrait = composure.core.ComposeItem.getRealTrait(trait);
		if(castTrait != null) {
			castTrait.set_item(this);
			this._traitToCast.set(trait,castTrait);
		}
		this._traitCollection.addTrait(traitPair);
		if(this._parentItem != null) this._parentItem.addChildTrait(traitPair);
		if(castTrait != null) {
			var castInjectors = castTrait.getInjectors();
			var $it0 = $iterator(castInjectors)();
			while( $it0.hasNext() ) {
				var injector = $it0.next();
				this.addTraitInjector(injector);
			}
		}
	}
	,addTraits: function(traits) {
		var _g = 0;
		while(_g < traits.length) {
			var trait = traits[_g];
			++_g;
			this._addTrait(trait);
		}
	}
	,addTrait: function(trait) {
		this._addTrait(trait);
	}
	,callForTraits: function(func,TraitType) {
		this._traitCollection.callForTraits(func,TraitType,this);
	}
	,getTraits: function(TraitType) {
		return this._traitCollection.getTraits(TraitType);
	}
	,getTrait: function(traitType) {
		return this._traitCollection.getTrait(traitType);
	}
	,setRoot: function(root) {
		if(this._root != null) this.onRootRemove();
		this._root = root;
		if(this._root != null) this.onRootAdd();
	}
	,get_traitRemoved: function() {
		return this._traitCollection.get_traitRemoved();
	}
	,get_traitAdded: function() {
		return this._traitCollection.get_traitAdded();
	}
	,get_root: function() {
		return this._root;
	}
	,set_parentItem: function(value) {
		if(this._parentItem != value) {
			if(this._parentItem != null) this.onParentRemove();
			this._parentItem = value;
			if(this._parentItem != null) this.onParentAdd();
		}
		return value;
	}
	,get_parentItem: function() {
		return this._parentItem;
	}
	,__class__: composure.core.ComposeItem
	,__properties__: {set_parentItem:"set_parentItem",get_parentItem:"get_parentItem",get_root:"get_root",get_traitAdded:"get_traitAdded",get_traitRemoved:"get_traitRemoved"}
}
composure.core.ComposeGroup = function(initTraits) {
	this._descendantTraits = new composure.traits.TraitCollection();
	this._children = new org.tbyrne.collections.UniqueList();
	this._descInjectors = new org.tbyrne.collections.UniqueList();
	composure.core.ComposeItem.call(this);
	this._childAscendingMarrier = new composure.injectors.InjectorMarrier(this._traitCollection);
	if(initTraits != null) this.addTraits(initTraits);
};
composure.core.ComposeGroup.__name__ = ["composure","core","ComposeGroup"];
composure.core.ComposeGroup.__super__ = composure.core.ComposeItem;
composure.core.ComposeGroup.prototype = $extend(composure.core.ComposeItem.prototype,{
	removeDescParentInjector: function(injector) {
		this._parentDescInjectors.remove(injector);
		var $it0 = this._children.iterator();
		while( $it0.hasNext() ) {
			var child = $it0.next();
			child.removeParentInjector(injector);
		}
	}
	,addDescParentInjector: function(injector) {
		if(this._parentDescInjectors == null) this._parentDescInjectors = new org.tbyrne.collections.UniqueList();
		this._parentDescInjectors.add(injector);
		var $it0 = this._children.iterator();
		while( $it0.hasNext() ) {
			var child = $it0.next();
			child.addParentInjector(injector);
		}
	}
	,checkForNewlyUnignoredInjectors: function() {
		var _g = this;
		if(this._ignoredParentDescInjectors != null) {
			var shouldDesc = Lambda.filter(this._ignoredParentDescInjectors,function(inj) {
				return inj.shouldDescend(_g);
			});
			var $it0 = shouldDesc.iterator();
			while( $it0.hasNext() ) {
				var inj = $it0.next();
				this.addDescParentInjector(inj);
				this._ignoredParentDescInjectors.remove(inj);
			}
		}
		if(this._ignoredChildAscInjectors != null) {
			var shouldAsc = Lambda.filter(this._ignoredChildAscInjectors,function(inj) {
				return inj.shouldAscend(_g);
			});
			var $it1 = shouldAsc.iterator();
			while( $it1.hasNext() ) {
				var inj = $it1.next();
				this._addAscendingInjector(inj);
				this._ignoredChildAscInjectors.remove(inj);
			}
		}
	}
	,checkForNewlyIgnoredInjectors: function() {
		var _g = this;
		if(this._parentDescInjectors != null) {
			var shouldNotDesc = Lambda.filter(this._parentDescInjectors,function(inj) {
				return !inj.shouldDescend(_g);
			});
			var $it0 = shouldNotDesc.iterator();
			while( $it0.hasNext() ) {
				var inj = $it0.next();
				this.removeDescParentInjector(inj);
				if(this._ignoredParentDescInjectors == null) this._ignoredParentDescInjectors = new org.tbyrne.collections.UniqueList();
				this._ignoredParentDescInjectors.add(inj);
			}
		}
		if(this._childAscInjectors != null) {
			var shouldNotAsc = Lambda.filter(this._childAscInjectors,function(inj) {
				return !inj.shouldAscend(_g);
			});
			var $it1 = shouldNotAsc.iterator();
			while( $it1.hasNext() ) {
				var inj = $it1.next();
				this._removeAscendingInjector(inj);
				if(this._ignoredChildAscInjectors == null) this._ignoredChildAscInjectors = new org.tbyrne.collections.UniqueList();
				this._ignoredChildAscInjectors.add(inj);
			}
		}
	}
	,removeParentInjector: function(injector) {
		composure.core.ComposeItem.prototype.removeParentInjector.call(this,injector);
		if(this._parentDescInjectors != null && this._parentDescInjectors.containsItem(injector)) this.removeDescParentInjector(injector); else if(this._ignoredParentDescInjectors != null) this._ignoredParentDescInjectors.remove(injector);
	}
	,addParentInjector: function(injector) {
		composure.core.ComposeItem.prototype.addParentInjector.call(this,injector);
		if(injector.shouldDescend(this)) this.addDescParentInjector(injector); else {
			if(this._ignoredParentDescInjectors == null) this._ignoredParentDescInjectors = new org.tbyrne.collections.UniqueList();
			this._ignoredParentDescInjectors.add(injector);
		}
	}
	,_removeAscendingInjector: function(injector) {
		this._childAscInjectors.remove(injector);
		if(this._parentItem != null) this._parentItem.removeAscendingInjector(injector);
	}
	,removeAscendingInjector: function(injector) {
		this._childAscendingMarrier.removeInjector(injector);
		if(this._childAscInjectors != null && this._childAscInjectors.containsItem(injector)) this._removeAscendingInjector(injector); else this._ignoredChildAscInjectors.remove(injector);
	}
	,_addAscendingInjector: function(injector) {
		if(this._childAscInjectors == null) this._childAscInjectors = new org.tbyrne.collections.UniqueList();
		this._childAscInjectors.add(injector);
		if(this._parentItem != null) this._parentItem.addAscendingInjector(injector);
	}
	,addAscendingInjector: function(injector) {
		this._childAscendingMarrier.addInjector(injector);
		if(injector.shouldAscend(this)) this._addAscendingInjector(injector); else {
			if(this._ignoredChildAscInjectors == null) this._ignoredChildAscInjectors = new org.tbyrne.collections.UniqueList();
			this._ignoredChildAscInjectors.add(injector);
		}
	}
	,onParentRemove: function() {
		composure.core.ComposeItem.prototype.onParentRemove.call(this);
		var $it0 = this._descendantTraits.traitPairs.iterator();
		while( $it0.hasNext() ) {
			var traitPair = $it0.next();
			this._parentItem.removeChildTrait(traitPair);
		}
		if(this._childAscInjectors != null) {
			var $it1 = this._childAscInjectors.iterator();
			while( $it1.hasNext() ) {
				var injector = $it1.next();
				this._parentItem.removeAscendingInjector(injector);
			}
		}
	}
	,onParentAdd: function() {
		composure.core.ComposeItem.prototype.onParentAdd.call(this);
		var $it0 = this._descendantTraits.traitPairs.iterator();
		while( $it0.hasNext() ) {
			var traitPair = $it0.next();
			this._parentItem.addChildTrait(traitPair);
		}
		if(this._childAscInjectors != null) {
			var $it1 = this._childAscInjectors.iterator();
			while( $it1.hasNext() ) {
				var injector = $it1.next();
				this._parentItem.addAscendingInjector(injector);
			}
		}
	}
	,callForDescTraits: function(func,TraitType) {
		this._descendantTraits.callForTraits(func,TraitType,this);
	}
	,getDescTraits: function(TraitType) {
		return this._descendantTraits.getTraits(TraitType);
	}
	,getDescTrait: function(TraitType) {
		return this._descendantTraits.getTrait(TraitType);
	}
	,removeTraitInjector: function(injector) {
		composure.core.ComposeItem.prototype.removeTraitInjector.call(this,injector);
		if(this._descInjectors.containsItem(injector)) {
			this._descInjectors.remove(injector);
			var $it0 = this._children.iterator();
			while( $it0.hasNext() ) {
				var child = $it0.next();
				child.removeParentInjector(injector);
			}
		}
	}
	,addTraitInjector: function(injector) {
		composure.core.ComposeItem.prototype.addTraitInjector.call(this,injector);
		if(injector.descendants) {
			this._descInjectors.add(injector);
			var $it0 = this._children.iterator();
			while( $it0.hasNext() ) {
				var child = $it0.next();
				child.addParentInjector(injector);
			}
		}
	}
	,removeAllTraits: function() {
		composure.core.ComposeItem.prototype.removeAllTraits.call(this);
		this.checkForNewlyUnignoredInjectors();
	}
	,removeTraits: function(traits) {
		composure.core.ComposeItem.prototype.removeTraits.call(this,traits);
		this.checkForNewlyUnignoredInjectors();
	}
	,removeTrait: function(trait) {
		composure.core.ComposeItem.prototype.removeTrait.call(this,trait);
		this.checkForNewlyUnignoredInjectors();
	}
	,addTraits: function(traits) {
		composure.core.ComposeItem.prototype.addTraits.call(this,traits);
		this.checkForNewlyIgnoredInjectors();
	}
	,addTrait: function(trait) {
		composure.core.ComposeItem.prototype.addTrait.call(this,trait);
		this.checkForNewlyIgnoredInjectors();
	}
	,removeChildTrait: function(traitPair) {
		this._descendantTraits.removeTrait(traitPair);
		if(this._parentItem != null) this._parentItem.removeChildTrait(traitPair);
	}
	,addChildTrait: function(traitPair) {
		this._descendantTraits.addTrait(traitPair);
		if(this._parentItem != null) this._parentItem.addChildTrait(traitPair);
	}
	,removeAllItem: function() {
		while(this._children.get_length() > 0) this.removeChild(this._children.first());
	}
	,removeChild: function(item) {
		this._children.remove(item);
		item.set_parentItem(null);
		var $it0 = this._descInjectors.iterator();
		while( $it0.hasNext() ) {
			var traitInjector = $it0.next();
			item.removeParentInjector(traitInjector);
		}
		if(this._parentDescInjectors != null) {
			var $it1 = this._parentDescInjectors.iterator();
			while( $it1.hasNext() ) {
				var traitInjector = $it1.next();
				item.removeParentInjector(traitInjector);
			}
		}
		item.setRoot(null);
	}
	,addChild: function(item) {
		this._children.add(item);
		item.set_parentItem(this);
		var $it0 = this._descInjectors.iterator();
		while( $it0.hasNext() ) {
			var traitInjector = $it0.next();
			item.addParentInjector(traitInjector);
		}
		if(this._parentDescInjectors != null) {
			var $it1 = this._parentDescInjectors.iterator();
			while( $it1.hasNext() ) {
				var traitInjector = $it1.next();
				item.addParentInjector(traitInjector);
			}
		}
		item.setRoot(this._root);
	}
	,setRoot: function(game) {
		composure.core.ComposeItem.prototype.setRoot.call(this,game);
		var $it0 = this._children.iterator();
		while( $it0.hasNext() ) {
			var child = $it0.next();
			child.setRoot(game);
		}
	}
	,get_children: function() {
		return this._children;
	}
	,__class__: composure.core.ComposeGroup
	,__properties__: $extend(composure.core.ComposeItem.prototype.__properties__,{get_children:"get_children"})
});
composure.core.ComposeRoot = function(initTraits) {
	composure.core.ComposeGroup.call(this,initTraits);
	this._universalMarrier = new composure.injectors.InjectorMarrier(this._descendantTraits);
	this.setRoot(this);
};
composure.core.ComposeRoot.__name__ = ["composure","core","ComposeRoot"];
composure.core.ComposeRoot.__super__ = composure.core.ComposeGroup;
composure.core.ComposeRoot.prototype = $extend(composure.core.ComposeGroup.prototype,{
	removeUniversalInjector: function(injector) {
		this._universalMarrier.removeInjector(injector);
	}
	,addUniversalInjector: function(injector) {
		this._universalMarrier.addInjector(injector);
	}
	,getAllTraits: function() {
		return this._descendantTraits;
	}
	,__class__: composure.core.ComposeRoot
});
composure.injectors = {}
composure.injectors.IInjector = function() { }
composure.injectors.IInjector.__name__ = ["composure","injectors","IInjector"];
composure.injectors.IInjector.prototype = {
	__class__: composure.injectors.IInjector
}
composure.injectors.AbstractInjector = function(interestedTraitType,addHandler,removeHandler,siblings,descendants,ascendants,universal,passThroughItem,passThroughInjector) {
	if(passThroughInjector == null) passThroughInjector = false;
	if(passThroughItem == null) passThroughItem = false;
	if(universal == null) universal = false;
	if(ascendants == null) ascendants = false;
	if(descendants == null) descendants = false;
	if(siblings == null) siblings = true;
	this.addHandler = addHandler;
	this.removeHandler = removeHandler;
	this.maxMatches = -1;
	this.siblings = siblings;
	this.descendants = descendants;
	this.ascendants = ascendants;
	this.universal = universal;
	this.set_interestedTraitType(interestedTraitType);
	this._addedTraits = new org.tbyrne.collections.UniqueList();
	this.passThroughInjector = passThroughInjector;
	this.passThroughItem = passThroughItem;
};
composure.injectors.AbstractInjector.__name__ = ["composure","injectors","AbstractInjector"];
composure.injectors.AbstractInjector.__interfaces__ = [composure.injectors.IInjector];
composure.injectors.AbstractInjector.prototype = {
	isInterestedIn: function(item,trait) {
		if(this.maxMatches != -1 && this._addedTraits.get_length() >= this.maxMatches) return false;
		if(this._enumValMode) {
			var traitEnum = Type.getEnum(trait);
			var intEnum = Type.getEnum(this.interestedTraitType);
			if(traitEnum != intEnum) return false;
			if(Type.enumIndex(trait) != Type.enumIndex(this.interestedTraitType)) return false;
			if(this.checkEnumParams == null) return this.matchTrait == null || this.matchTrait(item,trait,this); else {
				var traitParams = Type.enumParameters(trait);
				var intParams = Type.enumParameters(this.interestedTraitType);
				var _g = 0, _g1 = this.checkEnumParams;
				while(_g < _g1.length) {
					var index = _g1[_g];
					++_g;
					var intVal = intParams[index];
					var traitVal = traitParams[index];
					var _g2 = Type["typeof"](intVal);
					switch( (_g2)[1] ) {
					case 7:
						if(!Type.enumEq(intVal,traitVal)) return false;
						break;
					default:
						if(intVal != traitVal) return false;
					}
				}
				return this.matchTrait == null || this.matchTrait(item,trait,this);
			}
		} else {
			if(js.Boot.__instanceof(trait,this.interestedTraitType) && (this.matchTrait == null || this.matchTrait(item,trait,this))) {
				if(this.checkProps != null) {
					var $it0 = this.checkProps.keys();
					while( $it0.hasNext() ) {
						var i = $it0.next();
						if(Reflect.getProperty(trait,i) != this.checkProps.get(i)) return false;
					}
				}
				return true;
			}
			return false;
		}
	}
	,shouldAscend: function(item) {
		if(this.stopAscendingAt != null) return !this.stopAscendingAt(item,null,this); else return true;
	}
	,shouldDescend: function(item) {
		if(this.stopDescendingAt != null) return !this.stopDescendingAt(item,null,this); else return true;
	}
	,itemMatchesAny: function(item,traitTypes) {
		var _g = 0;
		while(_g < traitTypes.length) {
			var traitType = traitTypes[_g];
			++_g;
			if(item.getTrait(traitType) != null) return true;
		}
		return false;
	}
	,itemMatchesAll: function(item,traitTypes) {
		var _g = 0;
		while(_g < traitTypes.length) {
			var traitType = traitTypes[_g];
			++_g;
			if(item.getTrait(traitType) == null) return false;
		}
		return true;
	}
	,injectorRemoved: function(traitPair) {
		if(this._addedTraits.remove(traitPair) && this.removeHandler != null) {
			var item = traitPair.item;
			var trait = traitPair.trait;
			if(this.passThroughInjector) {
				if(this.passThroughItem) this.removeHandler(this,trait,item); else this.removeHandler(this,trait);
			} else if(this.passThroughItem) this.removeHandler(trait,item); else this.removeHandler(trait);
		}
	}
	,injectorAdded: function(traitPair) {
		if(this._addedTraits.add(traitPair) && this.addHandler != null) {
			var item = traitPair.item;
			var trait = traitPair.trait;
			if(this.passThroughInjector) {
				if(this.passThroughItem) this.addHandler(this,trait,item); else this.addHandler(this,trait);
			} else if(this.passThroughItem) this.addHandler(trait,item); else this.addHandler(trait);
		}
	}
	,set_interestedTraitType: function(value) {
		this.interestedTraitType = value;
		if(value != null) this._enumValMode = Type.getEnum(value) != null;
		return value;
	}
	,__class__: composure.injectors.AbstractInjector
	,__properties__: {set_interestedTraitType:"set_interestedTraitType"}
}
composure.injectors.Injector = function(traitType,addHandler,removeHandler,siblings,descendants,ascendants,universal,passThroughItem,passThroughInjector) {
	if(passThroughInjector == null) passThroughInjector = false;
	if(passThroughItem == null) passThroughItem = false;
	if(universal == null) universal = false;
	if(ascendants == null) ascendants = false;
	if(descendants == null) descendants = false;
	if(siblings == null) siblings = true;
	composure.injectors.AbstractInjector.call(this,traitType,addHandler,removeHandler,siblings,descendants,ascendants,universal,passThroughItem,passThroughInjector);
};
composure.injectors.Injector.__name__ = ["composure","injectors","Injector"];
composure.injectors.Injector.__super__ = composure.injectors.AbstractInjector;
composure.injectors.Injector.prototype = $extend(composure.injectors.AbstractInjector.prototype,{
	__class__: composure.injectors.Injector
});
composure.injectors.InjectorMarrier = function(traits) {
	this._traitInjectors = new org.tbyrne.collections.UniqueList();
	this._injectorLookup = new haxe.ds.ObjectMap();
	this._traitLookup = new haxe.ds.ObjectMap();
	this.set_traits(traits);
};
composure.injectors.InjectorMarrier.__name__ = ["composure","injectors","InjectorMarrier"];
composure.injectors.InjectorMarrier.prototype = {
	compareTrait: function(traitPair,traitInjector) {
		if((traitPair.trait != traitInjector.ownerTrait || traitInjector.acceptOwnerTrait) && traitInjector.isInterestedIn(traitPair.item,traitPair.trait)) {
			var injectorList = this._injectorLookup.h[traitInjector.__id__];
			if(injectorList == null) {
				injectorList = new org.tbyrne.collections.UniqueList();
				this._injectorLookup.set(traitInjector,injectorList);
			}
			injectorList.add(traitPair);
			var traitList = this._traitLookup.get(traitPair.trait);
			if(traitList == null) {
				traitList = new org.tbyrne.collections.UniqueList();
				this._traitLookup.set(traitPair.trait,traitList);
			}
			traitList.add(traitInjector);
			traitInjector.injectorAdded(traitPair);
		}
	}
	,onTraitRemoved: function(traitPair) {
		var injectors = this._traitLookup.get(traitPair.trait);
		if(injectors != null) {
			var $it0 = injectors.iterator();
			while( $it0.hasNext() ) {
				var traitInjector = $it0.next();
				traitInjector.injectorRemoved(traitPair);
				var injectorLookup = this._injectorLookup.h[traitInjector.__id__];
				injectorLookup.remove(traitPair.trait);
			}
			injectors.clear();
			this._traitLookup.remove(traitPair.trait);
		}
	}
	,onTraitAdded: function(traitPair) {
		var $it0 = this._traitInjectors.iterator();
		while( $it0.hasNext() ) {
			var traitInjector = $it0.next();
			this.compareTrait(traitPair,traitInjector);
		}
	}
	,removeInjector: function(traitInjector) {
		if(this._traitInjectors.remove(traitInjector)) {
			var traitPairs = this._injectorLookup.h[traitInjector.__id__];
			if(traitPairs != null) {
				var $it0 = traitPairs.iterator();
				while( $it0.hasNext() ) {
					var traitPair = $it0.next();
					traitInjector.injectorRemoved(traitPair);
					var traitLookup = this._traitLookup.get(traitPair.trait);
					traitLookup.remove(traitInjector);
				}
				traitPairs.clear();
				this._injectorLookup.remove(traitInjector);
			}
		}
	}
	,addInjector: function(traitInjector) {
		if(this._traitInjectors.add(traitInjector)) {
			var $it0 = this._traits.traitPairs.iterator();
			while( $it0.hasNext() ) {
				var traitPair = $it0.next();
				this.compareTrait(traitPair,traitInjector);
			}
		}
	}
	,get_traitInjectors: function() {
		return this._traitInjectors;
	}
	,set_traits: function(value) {
		if(this._traits != value) {
			if(this._traits != null) {
				this._traits.get_traitAdded().remove($bind(this,this.onTraitAdded));
				this._traits.get_traitRemoved().remove($bind(this,this.onTraitRemoved));
			}
			this._traits = value;
			if(this._traits != null) {
				this._traits.get_traitAdded().add($bind(this,this.onTraitAdded));
				this._traits.get_traitRemoved().add($bind(this,this.onTraitRemoved));
			}
		}
		return value;
	}
	,get_traits: function() {
		return this._traits;
	}
	,__class__: composure.injectors.InjectorMarrier
	,__properties__: {set_traits:"set_traits",get_traits:"get_traits",get_traitInjectors:"get_traitInjectors"}
}
composure.injectors.PropInjector = function(interestedTraitType,subject,prop,siblings,descendants,ascendants,universal,writeOnly) {
	if(writeOnly == null) writeOnly = false;
	if(universal == null) universal = false;
	if(ascendants == null) ascendants = false;
	if(descendants == null) descendants = false;
	if(siblings == null) siblings = true;
	this.subject = subject;
	this.prop = prop;
	this.writeOnly = writeOnly;
	composure.injectors.AbstractInjector.call(this,interestedTraitType,$bind(this,this.addProp),$bind(this,this.removeProp),siblings,descendants,ascendants,universal);
};
composure.injectors.PropInjector.__name__ = ["composure","injectors","PropInjector"];
composure.injectors.PropInjector.__super__ = composure.injectors.AbstractInjector;
composure.injectors.PropInjector.prototype = $extend(composure.injectors.AbstractInjector.prototype,{
	removeProp: function(trait) {
		if(this.isSet && trait == this.setTrait) {
			if(Reflect.getProperty(this.subject,this.prop) != this.setTrait) {
				this.isSet = true;
				return;
			} else {
				this.isSet = false;
				Reflect.setProperty(this.subject,this.prop,null);
			}
			this.setTrait = null;
		}
	}
	,addProp: function(trait) {
		if(this.isSet) return;
		if(!this.writeOnly) {
			if(Reflect.getProperty(this.subject,this.prop) != null) {
				this.isSet = true;
				return;
			}
		}
		this.isSet = true;
		this.setTrait = trait;
		Reflect.setProperty(this.subject,this.prop,trait);
	}
	,__class__: composure.injectors.PropInjector
});
composure.macro = {}
composure.macro.InjectorMacro = function() { }
composure.macro.InjectorMacro.__name__ = ["composure","macro","InjectorMacro"];
composure.macro._InjectorMacro = {}
composure.macro._InjectorMacro.InjectorAccess = function() {
	this.siblings = true;
	this.descendants = false;
	this.ascendants = false;
	this.universal = false;
};
composure.macro._InjectorMacro.InjectorAccess.__name__ = ["composure","macro","_InjectorMacro","InjectorAccess"];
composure.macro._InjectorMacro.InjectorAccess.prototype = {
	__class__: composure.macro._InjectorMacro.InjectorAccess
}
composure.traitCheckers = {}
composure.traitCheckers.GenerationChecker = function() { }
composure.traitCheckers.GenerationChecker.__name__ = ["composure","traitCheckers","GenerationChecker"];
composure.traitCheckers.GenerationChecker.create = function(maxGenerations,descending,relatedItem) {
	if(descending == null) descending = true;
	if(maxGenerations == null) maxGenerations = 1;
	return function(item,trait,from) {
		var compare;
		if(relatedItem != null) {
			var $e = (relatedItem);
			switch( $e[1] ) {
			case 0:
				var other = $e[2];
				compare = other;
				break;
			case 2:
				compare = item.get_root();
				break;
			default:
				compare = from.ownerTrait.item;
			}
		} else compare = from.ownerTrait.item;
		if(descending) {
			if(js.Boot.__instanceof(compare,composure.core.ComposeGroup) && maxGenerations > 0) return composure.traitCheckers.GenerationChecker.searchForDesc(maxGenerations,js.Boot.__cast(compare , composure.core.ComposeGroup),item); else return compare == item;
		} else {
			var parent = null;
			while(maxGenerations > 0) {
				parent = compare.get_parentItem();
				if(parent == null) return false;
				maxGenerations--;
			}
			return parent == item;
		}
	};
}
composure.traitCheckers.GenerationChecker.searchForDesc = function(remainingGenerations,startGroup,findItem) {
	var newGen = remainingGenerations - 1;
	var $it0 = $iterator(startGroup.get_children())();
	while( $it0.hasNext() ) {
		var child = $it0.next();
		if(child == findItem) return true;
		if(remainingGenerations != 0) {
			if(js.Boot.__instanceof(child,composure.core.ComposeGroup)) {
				if(composure.traitCheckers.GenerationChecker.searchForDesc(newGen,js.Boot.__cast(child , composure.core.ComposeGroup),findItem)) return true;
			}
		}
	}
	return false;
}
composure.traitCheckers.ItemType = { __ename__ : ["composure","traitCheckers","ItemType"], __constructs__ : ["specific","injectorItem","root"] }
composure.traitCheckers.ItemType.specific = function(ItemType) { var $x = ["specific",0,ItemType]; $x.__enum__ = composure.traitCheckers.ItemType; $x.toString = $estr; return $x; }
composure.traitCheckers.ItemType.injectorItem = ["injectorItem",1];
composure.traitCheckers.ItemType.injectorItem.toString = $estr;
composure.traitCheckers.ItemType.injectorItem.__enum__ = composure.traitCheckers.ItemType;
composure.traitCheckers.ItemType.root = ["root",2];
composure.traitCheckers.ItemType.root.toString = $estr;
composure.traitCheckers.ItemType.root.__enum__ = composure.traitCheckers.ItemType;
composure.traitCheckers.MatchProps = function() { }
composure.traitCheckers.MatchProps.__name__ = ["composure","traitCheckers","MatchProps"];
composure.traitCheckers.MatchProps.create = function(matchProps) {
	return function(item,trait,from) {
		var $it0 = matchProps.keys();
		while( $it0.hasNext() ) {
			var i = $it0.next();
			if(Reflect.field(trait,i) != matchProps.get(i)) return false;
		}
		return true;
	};
}
composure.traitCheckers.TraitTypeChecker = function() { }
composure.traitCheckers.TraitTypeChecker.__name__ = ["composure","traitCheckers","TraitTypeChecker"];
composure.traitCheckers.TraitTypeChecker.createMulti = function(types,useOrCheck,invertResponse,unlessIsTraits,dontMatchFrom) {
	if(dontMatchFrom == null) dontMatchFrom = true;
	if(invertResponse == null) invertResponse = false;
	if(useOrCheck == null) useOrCheck = false;
	if(useOrCheck) return function(item,trait,from) {
		var _g = 0;
		while(_g < types.length) {
			var type = types[_g];
			++_g;
			var otherTrait = item.getTrait(type);
			if(otherTrait != null && (unlessIsTraits == null || !composure.traitCheckers.TraitTypeChecker.contains(unlessIsTraits,otherTrait)) && (dontMatchFrom == false || otherTrait != trait)) return !invertResponse;
		}
		return invertResponse;
	}; else return function(item,trait,from) {
		var _g = 0;
		while(_g < types.length) {
			var type = types[_g];
			++_g;
			var otherTrait = item.getTrait(type);
			if(otherTrait == null || unlessIsTraits != null && composure.traitCheckers.TraitTypeChecker.contains(unlessIsTraits,otherTrait) || dontMatchFrom == true && otherTrait == trait) return invertResponse;
		}
		return !invertResponse;
	};
}
composure.traitCheckers.TraitTypeChecker.create = function(type,invertResponse,unlessIsTrait,dontMatchFrom) {
	if(dontMatchFrom == null) dontMatchFrom = true;
	if(invertResponse == null) invertResponse = false;
	return function(item,trait,from) {
		var otherTrait = item.getTrait(type);
		if(otherTrait != null && (unlessIsTrait == null || unlessIsTrait != otherTrait) && (dontMatchFrom == false || otherTrait != trait)) return !invertResponse;
		return invertResponse;
	};
}
composure.traitCheckers.TraitTypeChecker.contains = function(traits,trait) {
	var _g = 0;
	while(_g < traits.length) {
		var otherTrait = traits[_g];
		++_g;
		if(otherTrait == trait) return true;
	}
	return false;
}
composure.traits = {}
composure.traits.ITrait = function() { }
composure.traits.ITrait.__name__ = ["composure","traits","ITrait"];
composure.traits.ITrait.prototype = {
	__class__: composure.traits.ITrait
}
composure.traits.AbstractTrait = function(ownerTrait) {
	this._groupOnly = false;
	if(ownerTrait != null) this._ownerTrait = ownerTrait; else this._ownerTrait = this;
};
composure.traits.AbstractTrait.__name__ = ["composure","traits","AbstractTrait"];
composure.traits.AbstractTrait.__interfaces__ = [composure.traits.ITrait];
composure.traits.AbstractTrait.prototype = {
	removeInjector: function(injector) {
		if(this._injectors != null && this._injectors.remove(injector)) {
			injector.ownerTraitTyped = null;
			injector.ownerTrait = null;
		}
	}
	,addInjector: function(injector) {
		if(this._injectors == null) this._injectors = new org.tbyrne.collections.UniqueList();
		if(this._injectors.add(injector)) {
			injector.ownerTraitTyped = this;
			injector.ownerTrait = this._ownerTrait;
		}
	}
	,removeChildItems: function(children) {
		var _g = 0;
		while(_g < children.length) {
			var child = children[_g];
			++_g;
			this.removeChildItem(child);
		}
	}
	,removeChildItem: function(child) {
		if(this._childItems != null && this._childItems.remove(child)) {
			if(this.group != null) this.group.removeChild(child);
		}
	}
	,addChildItem: function(child) {
		if(this._childItems == null) this._childItems = new org.tbyrne.collections.UniqueList();
		if(this._childItems.add(child)) {
			if(this.group != null) this.group.addChild(child);
		}
	}
	,removeSiblingTraits: function(traits) {
		var _g = 0;
		while(_g < traits.length) {
			var trait = traits[_g];
			++_g;
			this.removeSiblingTrait(trait);
		}
	}
	,removeSiblingTrait: function(trait) {
		if(this._siblingTraits != null && this._siblingTraits.remove(trait)) {
			if(this.item != null) this.item.removeTrait(trait);
		}
	}
	,addSiblingTrait: function(trait) {
		if(this._siblingTraits == null) this._siblingTraits = new org.tbyrne.collections.UniqueList();
		if(this._siblingTraits.add(trait)) {
			if(this.item != null) this.item.addTrait(trait);
		}
	}
	,getInjectors: function() {
		if(this._injectors == null) this._injectors = new org.tbyrne.collections.UniqueList();
		return this._injectors;
	}
	,onItemAdd: function() {
	}
	,onItemRemove: function() {
	}
	,set_item: function(value) {
		if(this.item != value) {
			if(this.item != null) {
				if(this._siblingTraits != null) {
					var $it0 = this._siblingTraits.iterator();
					while( $it0.hasNext() ) {
						var trait = $it0.next();
						this.item.removeTrait(trait);
					}
				}
				if(this.group != null && this._childItems != null) {
					var $it1 = this._childItems.iterator();
					while( $it1.hasNext() ) {
						var trait = $it1.next();
						this.group.removeChild(trait);
					}
				}
				this.onItemRemove();
			}
			this.item = value;
			this.group = null;
			if(this.item != null) {
				if(js.Boot.__instanceof(value,composure.core.ComposeGroup)) {
					this.group = js.Boot.__cast(value , composure.core.ComposeGroup);
					if(this._childItems != null) {
						var $it2 = this._childItems.iterator();
						while( $it2.hasNext() ) {
							var child = $it2.next();
							this.group.addChild(child);
						}
					}
				}
				this.onItemAdd();
				if(this._siblingTraits != null) {
					var $it3 = this._siblingTraits.iterator();
					while( $it3.hasNext() ) {
						var trait = $it3.next();
						this.item.addTrait(trait);
					}
				}
			}
		}
		return value;
	}
	,__class__: composure.traits.AbstractTrait
	,__properties__: {set_item:"set_item"}
}
composure.traits.TraitCollection = function() {
	this._traitTypeCache = new haxe.ds.StringMap();
	this.traitPairs = new org.tbyrne.collections.UniqueList();
};
composure.traits.TraitCollection.__name__ = ["composure","traits","TraitCollection"];
composure.traits.TraitCollection.prototype = {
	get_traitRemoved: function() {
		if(this._traitRemoved == null) this._traitRemoved = new msignal.Signal1();
		return this._traitRemoved;
	}
	,get_traitAdded: function() {
		if(this._traitAdded == null) this._traitAdded = new msignal.Signal1();
		return this._traitAdded;
	}
	,removeTrait: function(traitPair) {
		this.traitPairs.remove(traitPair);
		var $it0 = ((function(_e) {
			return function() {
				return _e.iterator();
			};
		})(this._traitTypeCache))();
		while( $it0.hasNext() ) {
			var cache = $it0.next();
			cache.getTraitsList.remove(traitPair.trait);
			cache.matched.remove(traitPair);
			cache.invalid.remove(traitPair);
			cache.methodCachesSafe = false;
		}
		if(this._traitRemoved != null) this._traitRemoved.dispatch(traitPair);
	}
	,addTrait: function(traitPair) {
		this.traitPairs.add(traitPair);
		var $it0 = ((function(_e) {
			return function() {
				return _e.iterator();
			};
		})(this._traitTypeCache))();
		while( $it0.hasNext() ) {
			var cache = $it0.next();
			cache.invalid.add(traitPair);
			cache.methodCachesSafe = false;
		}
		if(this._traitAdded != null) this._traitAdded.dispatch(traitPair);
	}
	,callForTraits: function(func,matchType,thisObj,params,collectReturns) {
		var matchingType = matchType != null;
		var cache;
		var typeName;
		if(matchingType) {
			typeName = Type.getClassName(matchType);
			cache = this._traitTypeCache.get(typeName);
		} else {
			cache = null;
			typeName = null;
		}
		var realParams = [thisObj,null];
		if(params != null) realParams = realParams.concat(params);
		var invalid;
		if(cache != null) {
			var $it0 = cache.matched.iterator();
			while( $it0.hasNext() ) {
				var traitPair = $it0.next();
				realParams[1] = traitPair.trait;
				func.apply(thisObj,realParams);
			}
			invalid = cache.invalid;
		} else {
			if(matchingType) {
				cache = new composure.traits._TraitCollection.TraitTypeCache();
				this._traitTypeCache.set(typeName,cache);
			}
			invalid = this.traitPairs;
		}
		if(matchingType) {
			if(cache != null && cache.methodCachesSafe == false) {
				var $it1 = invalid.iterator();
				while( $it1.hasNext() ) {
					var traitPair = $it1.next();
					if(js.Boot.__instanceof(traitPair.trait,matchType)) {
						realParams[1] = traitPair.trait;
						if(matchingType) {
							cache.matched.add(traitPair);
							cache.getTraitsList.add(traitPair.trait);
						}
						if(collectReturns != null) collectReturns.push(func.apply(thisObj,realParams)); else func.apply(thisObj,realParams);
					}
				}
				cache.invalid.clear();
				cache.methodCachesSafe = true;
				cache.getTrait = cache.getTraitsList.first();
			}
		} else {
			var $it2 = invalid.iterator();
			while( $it2.hasNext() ) {
				var trait = $it2.next();
				realParams[1] = trait;
				if(collectReturns != null) collectReturns.push(func.apply(thisObj,realParams)); else func.apply(thisObj,realParams);
			}
		}
	}
	,validateCache: function(matchType) {
		var typeName;
		if(js.Boot.__instanceof(matchType,Enum)) typeName = Type.getEnumName(matchType); else typeName = Type.getClassName(matchType);
		var cache;
		cache = this._traitTypeCache.get(typeName);
		var invalid;
		if(cache != null) invalid = cache.invalid; else {
			cache = new composure.traits._TraitCollection.TraitTypeCache();
			this._traitTypeCache.set(typeName,cache);
			invalid = this.traitPairs;
		}
		if(!cache.methodCachesSafe) {
			var $it0 = invalid.iterator();
			while( $it0.hasNext() ) {
				var traitPair = $it0.next();
				if(js.Boot.__instanceof(traitPair.trait,matchType)) {
					cache.matched.add(traitPair);
					cache.getTraitsList.add(traitPair.trait);
				}
			}
			cache.invalid.clear();
			cache.methodCachesSafe = true;
			cache.getTrait = cache.getTraitsList.first();
		}
		return cache;
	}
	,getTraits: function(traitType) {
		var cache = this.validateCache(traitType);
		if(cache != null) return cache.getTraits; else return null;
	}
	,getTrait: function(traitType) {
		if(traitType == null) {
			haxe.Log.trace("TraitCollection.getTrait must be supplied an ITrait class to match",{ fileName : "TraitCollection.hx", lineNumber : 50, className : "composure.traits.TraitCollection", methodName : "getTrait"});
			return null;
		} else {
			var cache = this.validateCache(traitType);
			if(cache != null) return cache.getTrait; else return null;
		}
	}
	,get_testSignal: function() {
		if(this._testSignal == null) this._testSignal = new msignal.Signal1();
		return this._testSignal;
	}
	,__class__: composure.traits.TraitCollection
	,__properties__: {get_traitAdded:"get_traitAdded",get_traitRemoved:"get_traitRemoved",get_testSignal:"get_testSignal"}
}
composure.traits._TraitCollection = {}
composure.traits._TraitCollection.TraitTypeCache = function() {
	this.matched = new org.tbyrne.collections.UniqueList();
	this.invalid = new org.tbyrne.collections.UniqueList();
	this.getTraitsList = new org.tbyrne.collections.UniqueList();
	this.getTraits = this.getTraitsList;
};
composure.traits._TraitCollection.TraitTypeCache.__name__ = ["composure","traits","_TraitCollection","TraitTypeCache"];
composure.traits._TraitCollection.TraitTypeCache.prototype = {
	__class__: composure.traits._TraitCollection.TraitTypeCache
}
composure.utilTraits = {}
composure.utilTraits.Furnisher = function(concernedTraitType,addTraits,addType,searchSiblings,searchDescendants,searchAscendants,checkEnumParams) {
	if(searchAscendants == null) searchAscendants = false;
	if(searchDescendants == null) searchDescendants = true;
	if(searchSiblings == null) searchSiblings = true;
	composure.traits.AbstractTrait.call(this);
	this._injector = new composure.injectors.Injector(null,$bind(this,this.onConcernedTraitAdded),$bind(this,this.onConcernedTraitRemoved),searchSiblings,searchDescendants,searchAscendants);
	this._injector.passThroughItem = true;
	if(addType != null) this.set_addItemType(addType); else this.set_addItemType(composure.utilTraits.AddType.traitItem);
	this._addedTraits = new haxe.ds.ObjectMap();
	this._addTraits = new org.tbyrne.collections.UniqueList(addTraits);
	this.set_searchSiblings(searchSiblings);
	this.set_searchDescendants(searchDescendants);
	this.set_searchAscendants(searchAscendants);
	this.set_checkEnumParams(checkEnumParams);
	this.set_concernedTraitType(concernedTraitType);
};
composure.utilTraits.Furnisher.__name__ = ["composure","utilTraits","Furnisher"];
composure.utilTraits.Furnisher.__super__ = composure.traits.AbstractTrait;
composure.utilTraits.Furnisher.prototype = $extend(composure.traits.AbstractTrait.prototype,{
	unregisterItem: function(trait,currItem,origItem) {
		var adoptTrait;
		var _g = this;
		var $e = (_g.addItemType);
		switch( $e[1] ) {
		case 2:
			var adoptMatchedTrait = $e[2];
			currItem.get_parentItem().removeChild(currItem);
			adoptTrait = adoptMatchedTrait;
			break;
		case 5:
			var adoptMatchedTrait = $e[2];
			currItem.get_parentItem().removeChild(currItem);
			adoptTrait = adoptMatchedTrait;
			break;
		case 3:
			var adoptMatchedTrait = $e[2];
			currItem.get_parentItem().removeChild(currItem);
			adoptTrait = adoptMatchedTrait;
			break;
		case 6:
			var adoptMatchedTrait = $e[2];
			currItem.get_parentItem().removeChild(currItem);
			adoptTrait = adoptMatchedTrait;
			break;
		case 8:
			var adoptMatchedTrait = $e[3], _g_faddItemType_eitemChild_0 = $e[2];
			currItem.get_parentItem().removeChild(currItem);
			adoptTrait = adoptMatchedTrait;
			break;
		case 9:
			var adoptMatchedTrait = $e[3], _g_faddItemType_eitemSibling_0 = $e[2];
			currItem.get_parentItem().removeChild(currItem);
			adoptTrait = adoptMatchedTrait;
			break;
		case 0:
			var adoptMatchedTrait = $e[3], _g_faddItemType_eadoptItem_0 = $e[2];
			var oldParent = this._originalParents.get(trait);
			if(oldParent != currItem.get_parentItem()) {
				this.item.get_parentItem().removeChild(currItem);
				oldParent.addChild(currItem);
			}
			adoptTrait = adoptMatchedTrait;
			break;
		case 4:
			var adoptMatchedTrait = $e[2];
			adoptTrait = adoptMatchedTrait;
			break;
		case 7:
			var adoptMatchedTrait = $e[3], _g_faddItemType_eitem_0 = $e[2];
			adoptTrait = adoptMatchedTrait;
			break;
		case 1:
			adoptTrait = false;
			break;
		}
		this._traitToItems.remove(trait);
		if(adoptTrait && origItem != currItem) {
			currItem.removeTrait(trait);
			origItem.addTrait(trait);
		}
	}
	,registerItem: function(trait,origItem) {
		if(this._traitToItems == null) this._traitToItems = new haxe.ds.ObjectMap();
		var item;
		var adoptTrait = false;
		var _g = this;
		var $e = (_g.addItemType);
		switch( $e[1] ) {
		case 4:
			var adoptMatchedTrait = $e[2];
			item = this.item;
			adoptTrait = adoptMatchedTrait;
			break;
		case 1:
			item = origItem;
			break;
		case 0:
			var adoptMatchedTrait = $e[3], newParent = $e[2];
			item = origItem;
			adoptTrait = adoptMatchedTrait;
			if(this._originalParents == null) this._originalParents = new haxe.ds.ObjectMap();
			this._originalParents.set(trait,origItem.get_parentItem());
			if(origItem.get_parentItem() != newParent) {
				origItem.get_parentItem().removeChild(origItem);
				newParent.addChild(origItem);
			}
			break;
		case 7:
			var adoptMatchedTrait = $e[3], specItem = $e[2];
			item = specItem;
			adoptTrait = adoptMatchedTrait;
			break;
		default:
			item = new composure.core.ComposeGroup();
			var _g1 = this;
			var $e = (_g1.addItemType);
			switch( $e[1] ) {
			case 5:
				var adoptMatchedTrait = $e[2];
				this.item.get_parentItem().addChild(item);
				adoptTrait = adoptMatchedTrait;
				break;
			case 2:
				var adoptMatchedTrait = $e[2];
				origItem.get_parentItem().addChild(item);
				adoptTrait = adoptMatchedTrait;
				break;
			case 6:
				var adoptMatchedTrait = $e[2];
				this.group.addChild(item);
				adoptTrait = adoptMatchedTrait;
				break;
			case 3:
				var adoptMatchedTrait = $e[2];
				adoptTrait = adoptMatchedTrait;
				if(js.Boot.__instanceof(origItem,composure.core.ComposeGroup)) {
					var origGroup;
					origGroup = origItem;
					origGroup.addChild(item);
				}
				break;
			case 8:
				var adoptMatchedTrait = $e[3], group = $e[2];
				group.addChild(item);
				adoptTrait = adoptMatchedTrait;
				break;
			case 9:
				var adoptMatchedTrait = $e[3], sibling = $e[2];
				sibling.get_parentItem().addChild(item);
				adoptTrait = adoptMatchedTrait;
				break;
			default:
				haxe.Log.trace(new org.tbyrne.logging.LogMsg("Unsupported AddType",[org.tbyrne.logging.LogType.devError]),{ fileName : "Furnisher.hx", lineNumber : 375, className : "composure.utilTraits.Furnisher", methodName : "registerItem"});
			}
		}
		this._traitToItems.set(trait,item);
		if(adoptTrait && item != origItem) {
			origItem.removeTrait(trait);
			item.addTrait(trait);
		}
		return item;
	}
	,getItem: function(trait) {
		return this._traitToItems.get(trait);
	}
	,testRules: function(foundTrait,item,rules) {
		if(rules == null) return true; else {
			var _g = 0;
			while(_g < rules.length) {
				var rule = rules[_g];
				++_g;
				var $e = (rule);
				switch( $e[1] ) {
				case 0:
					var t = $e[2];
					if(item.getTrait(t) == null) return false;
					break;
				case 1:
					var t = $e[2];
					if(item.getTrait(t) != null) return false;
					break;
				}
			}
			return true;
		}
	}
	,getTrait: function(foundTrait,item,addTrait) {
		var $e = (addTrait);
		switch( $e[1] ) {
		case 0:
			var rules = $e[3], t = $e[2];
			if(this.testRules(foundTrait,item,rules)) return Type.createInstance(t,[]);
			break;
		case 1:
			var rules = $e[3], f = $e[2];
			if(this.testRules(foundTrait,item,rules)) return f(foundTrait);
			break;
		case 2:
			var rules = $e[3], t = $e[2];
			if(this.testRules(foundTrait,item,rules)) return t;
			break;
		}
		return null;
	}
	,add: function(addTrait) {
		this._addTraits.add(addTrait);
		if(this._foundTraits != null) {
			var $it0 = this._foundTraits.iterator();
			while( $it0.hasNext() ) {
				var foundTrait = $it0.next();
				var item = this.getItem(foundTrait);
				var trait = this.getTrait(foundTrait,item,addTrait);
				if(trait != null) {
					item.addTrait(trait);
					var traitsAdded = this._addedTraits.h[foundTrait.__id__];
					traitsAdded.push(trait);
				}
			}
		}
	}
	,addType: function(type,unlessType) {
		if(unlessType != null) this.add(composure.utilTraits.AddTrait.TType(type,[composure.utilTraits.AddRule.UnlessHas(unlessType)])); else this.add(composure.utilTraits.AddTrait.TType(type));
	}
	,addInst: function(inst,unlessType) {
		if(unlessType != null) this.add(composure.utilTraits.AddTrait.TInst(inst,[composure.utilTraits.AddRule.UnlessHas(unlessType)])); else this.add(composure.utilTraits.AddTrait.TInst(inst));
	}
	,addFact: function(factory,unlessType) {
		if(unlessType != null) this.add(composure.utilTraits.AddTrait.TFact(factory,[composure.utilTraits.AddRule.UnlessHas(unlessType)])); else this.add(composure.utilTraits.AddTrait.TFact(factory));
	}
	,onConcernedTraitRemoved: function(trait,currItem) {
		if(this._ignoreTraitChanges) return;
		this._ignoreTraitChanges = true;
		this._foundTraits.remove(trait);
		var origItem = this._originalItems.get(trait);
		this._originalItems.remove(trait);
		var item = this.getItem(trait);
		var traitsAdded = this._addedTraits.get(trait);
		var _g = 0;
		while(_g < traitsAdded.length) {
			var otherTrait = traitsAdded[_g];
			++_g;
			item.removeTrait(otherTrait);
		}
		this._addedTraits.remove(trait);
		this.unregisterItem(trait,item,origItem);
		this._ignoreTraitChanges = false;
	}
	,onConcernedTraitAdded: function(trait,origItem) {
		if(this._ignoreTraitChanges) return;
		this._ignoreTraitChanges = true;
		if(this._foundTraits == null) {
			this._foundTraits = new org.tbyrne.collections.UniqueList();
			this._originalItems = new haxe.ds.ObjectMap();
		}
		this._foundTraits.add(trait);
		this._originalItems.set(trait,origItem);
		var item = this.registerItem(trait,origItem);
		var traitsAdded = [];
		var $it0 = this._addTraits.iterator();
		while( $it0.hasNext() ) {
			var addTrait = $it0.next();
			var newTrait = this.getTrait(trait,origItem,addTrait);
			if(newTrait != null) {
				item.addTrait(newTrait);
				traitsAdded.push(newTrait);
			}
		}
		this._addedTraits.set(trait,traitsAdded);
		this._ignoreTraitChanges = false;
	}
	,set_addItemType: function(value) {
		this.addItemType = value;
		if(this.item != null) throw "Cannot change 'addItemType' while added";
		return value;
	}
	,setCheckProps: function(obj) {
		var hash = new haxe.ds.StringMap();
		var fields = Reflect.fields(obj);
		var _g = 0;
		while(_g < fields.length) {
			var i = fields[_g];
			++_g;
			var value = Reflect.getProperty(obj,i);
			hash.set(i,value);
		}
		this.set_checkProps(hash);
	}
	,set_checkProps: function(value) {
		if(this._injectorAdded) this.removeInjector(this._injector);
		var ret = this._injector.checkProps = value;
		if(this._injectorAdded) this.addInjector(this._injector);
		return ret;
	}
	,get_checkProps: function() {
		return this._injector.checkProps;
	}
	,set_checkEnumParams: function(value) {
		if(this._injectorAdded) this.removeInjector(this._injector);
		var ret = this._injector.checkEnumParams = value;
		if(this._injectorAdded) this.addInjector(this._injector);
		return ret;
	}
	,get_checkEnumParams: function() {
		return this._injector.checkEnumParams;
	}
	,set_searchAscendants: function(value) {
		if(this._injectorAdded) this.removeInjector(this._injector);
		this._injector.ascendants = value;
		this.searchAscendants = value;
		if(this._injectorAdded) this.addInjector(this._injector);
		return value;
	}
	,set_searchDescendants: function(value) {
		if(this._injectorAdded) this.removeInjector(this._injector);
		this._injector.descendants = value;
		this.searchDescendants = value;
		if(this._injectorAdded) this.addInjector(this._injector);
		return value;
	}
	,set_searchSiblings: function(value) {
		if(this._injectorAdded) this.removeInjector(this._injector);
		this._injector.siblings = value;
		this.searchSiblings = value;
		if(this._injectorAdded) this.addInjector(this._injector);
		return value;
	}
	,set_concernedTraitType: function(value) {
		if(this._injectorAdded) {
			this.removeInjector(this._injector);
			this._injectorAdded = false;
		}
		this._injector.set_interestedTraitType(value);
		this.concernedTraitType = value;
		if(this.concernedTraitType != null) {
			this.addInjector(this._injector);
			this._injectorAdded = true;
		}
		return value;
	}
	,__class__: composure.utilTraits.Furnisher
	,__properties__: $extend(composure.traits.AbstractTrait.prototype.__properties__,{set_concernedTraitType:"set_concernedTraitType",set_searchSiblings:"set_searchSiblings",set_searchDescendants:"set_searchDescendants",set_searchAscendants:"set_searchAscendants",set_checkEnumParams:"set_checkEnumParams",get_checkEnumParams:"get_checkEnumParams",set_checkProps:"set_checkProps",get_checkProps:"get_checkProps",set_addItemType:"set_addItemType"})
});
composure.utilTraits.AddTrait = { __ename__ : ["composure","utilTraits","AddTrait"], __constructs__ : ["TType","TFact","TInst"] }
composure.utilTraits.AddTrait.TType = function(t,rules) { var $x = ["TType",0,t,rules]; $x.__enum__ = composure.utilTraits.AddTrait; $x.toString = $estr; return $x; }
composure.utilTraits.AddTrait.TFact = function(f,rules) { var $x = ["TFact",1,f,rules]; $x.__enum__ = composure.utilTraits.AddTrait; $x.toString = $estr; return $x; }
composure.utilTraits.AddTrait.TInst = function(t,rules) { var $x = ["TInst",2,t,rules]; $x.__enum__ = composure.utilTraits.AddTrait; $x.toString = $estr; return $x; }
composure.utilTraits.AddRule = { __ename__ : ["composure","utilTraits","AddRule"], __constructs__ : ["IfHas","UnlessHas"] }
composure.utilTraits.AddRule.IfHas = function(t) { var $x = ["IfHas",0,t]; $x.__enum__ = composure.utilTraits.AddRule; $x.toString = $estr; return $x; }
composure.utilTraits.AddRule.UnlessHas = function(t) { var $x = ["UnlessHas",1,t]; $x.__enum__ = composure.utilTraits.AddRule; $x.toString = $estr; return $x; }
composure.utilTraits.AddType = { __ename__ : ["composure","utilTraits","AddType"], __constructs__ : ["adoptItem","traitItem","traitSibling","traitChild","selfItem","selfSibling","selfChild","item","itemChild","itemSibling"] }
composure.utilTraits.AddType.adoptItem = function(newParent,adoptMatchedTrait) { var $x = ["adoptItem",0,newParent,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.traitItem = ["traitItem",1];
composure.utilTraits.AddType.traitItem.toString = $estr;
composure.utilTraits.AddType.traitItem.__enum__ = composure.utilTraits.AddType;
composure.utilTraits.AddType.traitSibling = function(adoptMatchedTrait) { var $x = ["traitSibling",2,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.traitChild = function(adoptMatchedTrait) { var $x = ["traitChild",3,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.selfItem = function(adoptMatchedTrait) { var $x = ["selfItem",4,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.selfSibling = function(adoptMatchedTrait) { var $x = ["selfSibling",5,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.selfChild = function(adoptMatchedTrait) { var $x = ["selfChild",6,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.item = function(item,adoptMatchedTrait) { var $x = ["item",7,item,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.itemChild = function(group,adoptMatchedTrait) { var $x = ["itemChild",8,group,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.AddType.itemSibling = function(item,adoptMatchedTrait) { var $x = ["itemSibling",9,item,adoptMatchedTrait]; $x.__enum__ = composure.utilTraits.AddType; $x.toString = $estr; return $x; }
composure.utilTraits.LazyTraitMap = function(matchType,typeCreator) {
	this.matchType = matchType;
	this._typeCreator = typeCreator;
};
composure.utilTraits.LazyTraitMap.__name__ = ["composure","utilTraits","LazyTraitMap"];
composure.utilTraits.LazyTraitMap.prototype = {
	returnInstance: function(context,trait) {
		var rem = false;
		var _g = this;
		var $e = (_g._typeCreator);
		switch( $e[1] ) {
		case 2:
			var addToContext = $e[3], trait1 = $e[2];
			rem = addToContext;
			break;
		default:
		}
		if(rem) context.removeTrait(trait);
	}
	,requestInstance: function(context) {
		var ret;
		var add = true;
		var _g = this;
		var $e = (_g._typeCreator);
		switch( $e[1] ) {
		case 0:
			var args = $e[3], type = $e[2];
			ret = Type.createInstance(type,args != null?args:[]);
			break;
		case 1:
			var factory = $e[2];
			ret = factory();
			break;
		case 2:
			var addToContext = $e[3], trait = $e[2];
			ret = trait;
			add = addToContext;
			break;
		}
		if(add) context.addTrait(ret);
		return ret;
	}
	,__class__: composure.utilTraits.LazyTraitMap
}
composure.utilTraits.TypeCreator = { __ename__ : ["composure","utilTraits","TypeCreator"], __constructs__ : ["FClass","FFact","FInst"] }
composure.utilTraits.TypeCreator.FClass = function(type,args) { var $x = ["FClass",0,type,args]; $x.__enum__ = composure.utilTraits.TypeCreator; $x.toString = $estr; return $x; }
composure.utilTraits.TypeCreator.FFact = function(factory) { var $x = ["FFact",1,factory]; $x.__enum__ = composure.utilTraits.TypeCreator; $x.toString = $estr; return $x; }
composure.utilTraits.TypeCreator.FInst = function(trait,addToContext) { var $x = ["FInst",2,trait,addToContext]; $x.__enum__ = composure.utilTraits.TypeCreator; $x.toString = $estr; return $x; }
composure.utilTraits.TraitTypeLimiter = function(traitType,policy,maxCount,siblings,descendants,ascendants) {
	if(ascendants == null) ascendants = false;
	if(descendants == null) descendants = false;
	if(siblings == null) siblings = true;
	if(maxCount == null) maxCount = 1;
	composure.traits.AbstractTrait.call(this);
	if(policy == null) policy = composure.utilTraits.LimitPolicy.FirstInLastOut;
	this._added = new haxe.ds.ObjectMap();
	this._removed = new haxe.ds.ObjectMap();
	this.injector = new composure.injectors.Injector(traitType,$bind(this,this.onTraitAdded),$bind(this,this.onTraitRemoved));
	this.injector.passThroughItem = true;
	this.set_maxCount(maxCount);
	this.policy = policy;
	this.setConcern(traitType,siblings,descendants,ascendants);
};
composure.utilTraits.TraitTypeLimiter.__name__ = ["composure","utilTraits","TraitTypeLimiter"];
composure.utilTraits.TraitTypeLimiter.__super__ = composure.traits.AbstractTrait;
composure.utilTraits.TraitTypeLimiter.prototype = $extend(composure.traits.AbstractTrait.prototype,{
	attemptTransmit: function(toTrait,fromTrait) {
		if(js.Boot.__instanceof(toTrait,composure.utilTraits.ITransmittableTrait)) {
			var trans = js.Boot.__cast(toTrait , composure.utilTraits.ITransmittableTrait);
			trans.transmitFrom(fromTrait);
		}
	}
	,reAddTrait: function(item,added,removed) {
		var trait;
		var _g = this;
		switch( (_g.policy)[1] ) {
		case 0:
			trait = removed.shift();
			added.unshift(trait);
			break;
		case 1:
			trait = removed.pop();
			added.push(trait);
			break;
		}
		item.addTrait(trait);
	}
	,onTraitRemoved: function(trait,item) {
		if(this._ignoreChanges) return;
		this._ignoreChanges = true;
		var added = this._added.h[item.__id__];
		if((function($this) {
			var $r;
			var x = trait;
			$r = HxOverrides.remove(added,x);
			return $r;
		}(this))) {
			var removed = this._removed.h[item.__id__];
			if(removed != null && removed.length > 0) this.reAddTrait(item,added,removed);
		}
		this._ignoreChanges = false;
	}
	,onTraitAdded: function(trait,item) {
		if(this._ignoreChanges) return;
		this._ignoreChanges = true;
		var added = this._added.h[item.__id__];
		if(added == null) {
			added = [];
			this._added.set(item,added);
		}
		if(added.length == this.maxCount) {
			var removed = this._removed.h[item.__id__];
			if(removed == null) {
				removed = [];
				this._removed.set(item,removed);
			}
			var _g = this;
			switch( (_g.policy)[1] ) {
			case 0:
				var firstTrait = added.shift();
				removed.unshift(firstTrait);
				item.removeTrait(firstTrait);
				added.push(trait);
				this.attemptTransmit(trait,firstTrait);
				break;
			case 1:
				removed.push(trait);
				item.removeTrait(trait);
				var addedTrait = added[added.length - 1];
				this.attemptTransmit(addedTrait,trait);
				break;
			}
		} else added.push(trait);
		this._ignoreChanges = false;
	}
	,checkTraits: function() {
		this._ignoreChanges = true;
		var keys = this._added.keys();
		while( keys.hasNext() ) {
			var item = keys.next();
			var added = this._added.h[item.__id__];
			if(added.length > this.maxCount) {
				var removed = this._removed.h[item.__id__];
				if(removed != null) while(removed.length > 0 && added.length > this.maxCount) this.reAddTrait(item,added,removed);
			}
		}
		this._ignoreChanges = false;
	}
	,reAddAll: function() {
		this._ignoreChanges = true;
		var keys = this._removed.keys();
		while( keys.hasNext() ) {
			var item = keys.next();
			var removed = this._removed.h[item.__id__];
			if(removed != null && removed.length > 0) {
				var added = this._added.h[item.__id__];
				while(removed.length > 0) this.reAddTrait(item,added,removed);
			}
		}
		this._added = new haxe.ds.ObjectMap();
		this._removed = new haxe.ds.ObjectMap();
		this._ignoreChanges = false;
	}
	,setConcern: function(traitType,siblings,descendants,ascendants) {
		if(ascendants == null) ascendants = false;
		if(descendants == null) descendants = false;
		if(siblings == null) siblings = true;
		if(this.added) {
			this.reAddAll();
			this.added = false;
			this.removeInjector(this.injector);
		}
		this.injector.set_interestedTraitType(traitType);
		this.injector.siblings = siblings;
		this.injector.descendants = descendants;
		this.injector.ascendants = ascendants;
		if(traitType != null) {
			this.added = true;
			this.addInjector(this.injector);
		}
	}
	,set_maxCount: function(value) {
		if(this.maxCount != value) {
			this.maxCount = value;
			this.checkTraits();
		}
		return value;
	}
	,__class__: composure.utilTraits.TraitTypeLimiter
	,__properties__: $extend(composure.traits.AbstractTrait.prototype.__properties__,{set_maxCount:"set_maxCount"})
});
composure.utilTraits.LimitPolicy = { __ename__ : ["composure","utilTraits","LimitPolicy"], __constructs__ : ["FirstInFirstOut","FirstInLastOut"] }
composure.utilTraits.LimitPolicy.FirstInFirstOut = ["FirstInFirstOut",0];
composure.utilTraits.LimitPolicy.FirstInFirstOut.toString = $estr;
composure.utilTraits.LimitPolicy.FirstInFirstOut.__enum__ = composure.utilTraits.LimitPolicy;
composure.utilTraits.LimitPolicy.FirstInLastOut = ["FirstInLastOut",1];
composure.utilTraits.LimitPolicy.FirstInLastOut.toString = $estr;
composure.utilTraits.LimitPolicy.FirstInLastOut.__enum__ = composure.utilTraits.LimitPolicy;
composure.utilTraits.ITransmittableTrait = function() { }
composure.utilTraits.ITransmittableTrait.__name__ = ["composure","utilTraits","ITransmittableTrait"];
composure.utilTraits.ITransmittableTrait.prototype = {
	__class__: composure.utilTraits.ITransmittableTrait
}
var composureTest = {}
composureTest.ClassIncluder = function() { }
composureTest.ClassIncluder.__name__ = ["composureTest","ClassIncluder"];
composureTest.ClassIncluder.main = function() {
}
var haxe = {}
haxe.Log = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.ds = {}
haxe.ds.ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
haxe.ds.ObjectMap.__name__ = ["haxe","ds","ObjectMap"];
haxe.ds.ObjectMap.__interfaces__ = [IMap];
haxe.ds.ObjectMap.prototype = {
	keys: function() {
		var a = [];
		for( var key in this.h.__keys__ ) {
		if(this.h.hasOwnProperty(key)) a.push(this.h.__keys__[key]);
		}
		return HxOverrides.iter(a);
	}
	,remove: function(key) {
		var id = key.__id__;
		if(!this.h.hasOwnProperty(id)) return false;
		delete(this.h[id]);
		delete(this.h.__keys__[id]);
		return true;
	}
	,get: function(key) {
		return this.h[key.__id__];
	}
	,set: function(key,value) {
		var id = key.__id__ != null?key.__id__:key.__id__ = ++haxe.ds.ObjectMap.count;
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,__class__: haxe.ds.ObjectMap
}
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = ["haxe","ds","StringMap"];
haxe.ds.StringMap.__interfaces__ = [IMap];
haxe.ds.StringMap.prototype = {
	iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,set: function(key,value) {
		this.h["$" + key] = value;
	}
	,__class__: haxe.ds.StringMap
}
var js = {}
js.Boot = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__string_rec(v,"");
	if(i != null && i.customParams != null) {
		var _g = 0, _g1 = i.customParams;
		while(_g < _g1.length) {
			var v1 = _g1[_g];
			++_g;
			msg += "," + js.Boot.__string_rec(v1,"");
		}
	}
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) d.innerHTML += js.Boot.__unhtml(msg) + "<br/>"; else if(typeof(console) != "undefined" && console.log != null) console.log(msg);
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) {
					if(cl == Array) return o.__enum__ == null;
					return true;
				}
				if(js.Boot.__interfLoop(o.__class__,cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
}
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
}
var msignal = {}
msignal.Signal = function(valueClasses) {
	if(valueClasses == null) valueClasses = [];
	this.valueClasses = valueClasses;
	this.slots = msignal.SlotList.NIL;
	this.priorityBased = false;
};
msignal.Signal.__name__ = ["msignal","Signal"];
msignal.Signal.prototype = {
	get_numListeners: function() {
		return this.slots.get_length();
	}
	,createSlot: function(listener,once,priority) {
		if(priority == null) priority = 0;
		if(once == null) once = false;
		return null;
	}
	,registrationPossible: function(listener,once) {
		if(!this.slots.nonEmpty) return true;
		var existingSlot = this.slots.find(listener);
		if(existingSlot == null) return true;
		if(existingSlot.once != once) throw "You cannot addOnce() then add() the same listener without removing the relationship first.";
		return false;
	}
	,registerListener: function(listener,once,priority) {
		if(priority == null) priority = 0;
		if(once == null) once = false;
		if(this.registrationPossible(listener,once)) {
			var newSlot = this.createSlot(listener,once,priority);
			if(!this.priorityBased && priority != 0) this.priorityBased = true;
			if(!this.priorityBased && priority == 0) this.slots = this.slots.prepend(newSlot); else this.slots = this.slots.insertWithPriority(newSlot);
			return newSlot;
		}
		return this.slots.find(listener);
	}
	,removeAll: function() {
		this.slots = msignal.SlotList.NIL;
	}
	,remove: function(listener) {
		var slot = this.slots.find(listener);
		if(slot == null) return null;
		this.slots = this.slots.filterNot(listener);
		return slot;
	}
	,addOnceWithPriority: function(listener,priority) {
		if(priority == null) priority = 0;
		return this.registerListener(listener,true,priority);
	}
	,addWithPriority: function(listener,priority) {
		if(priority == null) priority = 0;
		return this.registerListener(listener,false,priority);
	}
	,addOnce: function(listener) {
		return this.registerListener(listener,true);
	}
	,add: function(listener) {
		return this.registerListener(listener);
	}
	,__class__: msignal.Signal
	,__properties__: {get_numListeners:"get_numListeners"}
}
msignal.Signal0 = function() {
	msignal.Signal.call(this);
};
msignal.Signal0.__name__ = ["msignal","Signal0"];
msignal.Signal0.__super__ = msignal.Signal;
msignal.Signal0.prototype = $extend(msignal.Signal.prototype,{
	createSlot: function(listener,once,priority) {
		if(priority == null) priority = 0;
		if(once == null) once = false;
		return new msignal.Slot0(this,listener,once,priority);
	}
	,dispatch: function() {
		var slotsToProcess = this.slots;
		while(slotsToProcess.nonEmpty) {
			slotsToProcess.head.execute();
			slotsToProcess = slotsToProcess.tail;
		}
	}
	,__class__: msignal.Signal0
});
msignal.Signal1 = function(type) {
	msignal.Signal.call(this,[type]);
};
msignal.Signal1.__name__ = ["msignal","Signal1"];
msignal.Signal1.__super__ = msignal.Signal;
msignal.Signal1.prototype = $extend(msignal.Signal.prototype,{
	createSlot: function(listener,once,priority) {
		if(priority == null) priority = 0;
		if(once == null) once = false;
		return new msignal.Slot1(this,listener,once,priority);
	}
	,dispatch: function(value) {
		var slotsToProcess = this.slots;
		while(slotsToProcess.nonEmpty) {
			slotsToProcess.head.execute(value);
			slotsToProcess = slotsToProcess.tail;
		}
	}
	,__class__: msignal.Signal1
});
msignal.Signal2 = function(type1,type2) {
	msignal.Signal.call(this,[type1,type2]);
};
msignal.Signal2.__name__ = ["msignal","Signal2"];
msignal.Signal2.__super__ = msignal.Signal;
msignal.Signal2.prototype = $extend(msignal.Signal.prototype,{
	createSlot: function(listener,once,priority) {
		if(priority == null) priority = 0;
		if(once == null) once = false;
		return new msignal.Slot2(this,listener,once,priority);
	}
	,dispatch: function(value1,value2) {
		var slotsToProcess = this.slots;
		while(slotsToProcess.nonEmpty) {
			slotsToProcess.head.execute(value1,value2);
			slotsToProcess = slotsToProcess.tail;
		}
	}
	,__class__: msignal.Signal2
});
msignal.Slot = function(signal,listener,once,priority) {
	if(priority == null) priority = 0;
	if(once == null) once = false;
	this.signal = signal;
	this.set_listener(listener);
	this.once = once;
	this.priority = priority;
	this.enabled = true;
};
msignal.Slot.__name__ = ["msignal","Slot"];
msignal.Slot.prototype = {
	set_listener: function(value) {
		if(value == null) throw "listener cannot be null";
		return this.listener = value;
	}
	,remove: function() {
		this.signal.remove(this.listener);
	}
	,__class__: msignal.Slot
	,__properties__: {set_listener:"set_listener"}
}
msignal.Slot0 = function(signal,listener,once,priority) {
	if(priority == null) priority = 0;
	if(once == null) once = false;
	msignal.Slot.call(this,signal,listener,once,priority);
};
msignal.Slot0.__name__ = ["msignal","Slot0"];
msignal.Slot0.__super__ = msignal.Slot;
msignal.Slot0.prototype = $extend(msignal.Slot.prototype,{
	execute: function() {
		if(!this.enabled) return;
		if(this.once) this.remove();
		this.listener();
	}
	,__class__: msignal.Slot0
});
msignal.Slot1 = function(signal,listener,once,priority) {
	if(priority == null) priority = 0;
	if(once == null) once = false;
	msignal.Slot.call(this,signal,listener,once,priority);
};
msignal.Slot1.__name__ = ["msignal","Slot1"];
msignal.Slot1.__super__ = msignal.Slot;
msignal.Slot1.prototype = $extend(msignal.Slot.prototype,{
	execute: function(value1) {
		if(!this.enabled) return;
		if(this.once) this.remove();
		if(this.param != null) value1 = this.param;
		this.listener(value1);
	}
	,__class__: msignal.Slot1
});
msignal.Slot2 = function(signal,listener,once,priority) {
	if(priority == null) priority = 0;
	if(once == null) once = false;
	msignal.Slot.call(this,signal,listener,once,priority);
};
msignal.Slot2.__name__ = ["msignal","Slot2"];
msignal.Slot2.__super__ = msignal.Slot;
msignal.Slot2.prototype = $extend(msignal.Slot.prototype,{
	execute: function(value1,value2) {
		if(!this.enabled) return;
		if(this.once) this.remove();
		if(this.param1 != null) value1 = this.param1;
		if(this.param2 != null) value2 = this.param2;
		this.listener(value1,value2);
	}
	,__class__: msignal.Slot2
});
msignal.SlotList = function(head,tail) {
	this.nonEmpty = false;
	if(head == null && tail == null) {
		if(msignal.SlotList.NIL != null) throw "Parameters head and tail are null. Use the NIL element instead.";
		this.nonEmpty = false;
	} else if(head == null) throw "Parameter head cannot be null."; else {
		this.head = head;
		this.tail = tail == null?msignal.SlotList.NIL:tail;
		this.nonEmpty = true;
	}
};
msignal.SlotList.__name__ = ["msignal","SlotList"];
msignal.SlotList.prototype = {
	find: function(listener) {
		if(!this.nonEmpty) return null;
		var p = this;
		while(p.nonEmpty) {
			if(Reflect.compareMethods(p.head.listener,listener)) return p.head;
			p = p.tail;
		}
		return null;
	}
	,contains: function(listener) {
		if(!this.nonEmpty) return false;
		var p = this;
		while(p.nonEmpty) {
			if(Reflect.compareMethods(p.head.listener,listener)) return true;
			p = p.tail;
		}
		return false;
	}
	,filterNot: function(listener) {
		if(!this.nonEmpty || listener == null) return this;
		if(Reflect.compareMethods(this.head.listener,listener)) return this.tail;
		var wholeClone = new msignal.SlotList(this.head);
		var subClone = wholeClone;
		var current = this.tail;
		while(current.nonEmpty) {
			if(Reflect.compareMethods(current.head.listener,listener)) {
				subClone.tail = current.tail;
				return wholeClone;
			}
			subClone = subClone.tail = new msignal.SlotList(current.head);
			current = current.tail;
		}
		return this;
	}
	,insertWithPriority: function(slot) {
		if(!this.nonEmpty) return new msignal.SlotList(slot);
		var priority = slot.priority;
		if(priority >= this.head.priority) return this.prepend(slot);
		var wholeClone = new msignal.SlotList(this.head);
		var subClone = wholeClone;
		var current = this.tail;
		while(current.nonEmpty) {
			if(priority >= current.head.priority) {
				subClone.tail = current.prepend(slot);
				return wholeClone;
			}
			subClone = subClone.tail = new msignal.SlotList(current.head);
			current = current.tail;
		}
		subClone.tail = new msignal.SlotList(slot);
		return wholeClone;
	}
	,append: function(slot) {
		if(slot == null) return this;
		if(!this.nonEmpty) return new msignal.SlotList(slot);
		if(this.tail == msignal.SlotList.NIL) return new msignal.SlotList(slot).prepend(this.head);
		var wholeClone = new msignal.SlotList(this.head);
		var subClone = wholeClone;
		var current = this.tail;
		while(current.nonEmpty) {
			subClone = subClone.tail = new msignal.SlotList(current.head);
			current = current.tail;
		}
		subClone.tail = new msignal.SlotList(slot);
		return wholeClone;
	}
	,prepend: function(slot) {
		return new msignal.SlotList(slot,this);
	}
	,get_length: function() {
		if(!this.nonEmpty) return 0;
		if(this.tail == msignal.SlotList.NIL) return 1;
		var result = 0;
		var p = this;
		while(p.nonEmpty) {
			++result;
			p = p.tail;
		}
		return result;
	}
	,__class__: msignal.SlotList
	,__properties__: {get_length:"get_length"}
}
var org = {}
org.tbyrne = {}
org.tbyrne.collections = {}
org.tbyrne.collections.UniqueList = function(list) {
	this._length = 0;
	this.list = new Array();
	if(list != null) {
		var $it0 = $iterator(list)();
		while( $it0.hasNext() ) {
			var item = $it0.next();
			this.add(item);
		}
	}
};
org.tbyrne.collections.UniqueList.__name__ = ["org","tbyrne","collections","UniqueList"];
org.tbyrne.collections.UniqueList.prototype = {
	clear: function() {
		this.list = new Array();
		this._length = 0;
	}
	,remove: function(value) {
		if(HxOverrides.remove(this.list,value)) {
			--this._length;
			return true;
		} else return false;
	}
	,containsItem: function(value) {
		return Lambda.exists(this.list,function(item) {
			return value == item;
		});
	}
	,add: function(value) {
		if(!this.containsItem(value)) {
			++this._length;
			this.list.push(value);
			return true;
		}
		return false;
	}
	,first: function() {
		return this.list[0];
	}
	,get_length: function() {
		return this._length;
	}
	,iterator: function() {
		return HxOverrides.iter(this.list);
	}
	,__class__: org.tbyrne.collections.UniqueList
	,__properties__: {get_length:"get_length"}
}
org.tbyrne.logging = {}
org.tbyrne.logging.LogMsg = function(message,types,title,id) {
	this.message = message;
	this.types = types;
	this.title = title;
	this.id = id;
};
org.tbyrne.logging.LogMsg.__name__ = ["org","tbyrne","logging","LogMsg"];
org.tbyrne.logging.LogMsg.prototype = {
	toString: function() {
		var ret = "";
		if(this.types != null && this.types.length > 0) ret += "[" + this.types.join(", ") + "] ";
		if(this.title != null && this.title.length > 0) ret += this.title + ": ";
		if(this.message != null && this.message.length > 0) ret += this.message;
		return ret;
	}
	,__class__: org.tbyrne.logging.LogMsg
}
org.tbyrne.logging.LogType = function() { }
org.tbyrne.logging.LogType.__name__ = ["org","tbyrne","logging","LogType"];
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; };
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; };
if(Array.prototype.indexOf) HxOverrides.remove = function(a,o) {
	var i = a.indexOf(o);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.prototype.__class__ = Array;
Array.__name__ = ["Array"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
msignal.SlotList.NIL = new msignal.SlotList(null,null);
org.tbyrne.logging.LogType.devInfo = "devInfo";
org.tbyrne.logging.LogType.devWarning = "devWarning";
org.tbyrne.logging.LogType.devError = "devError";
org.tbyrne.logging.LogType.userInfo = "userInfo";
org.tbyrne.logging.LogType.userWarning = "userWarning";
org.tbyrne.logging.LogType.userError = "userError";
org.tbyrne.logging.LogType.performanceWarning = "performanceWarning";
org.tbyrne.logging.LogType.deprecationWarning = "deprecationWarning";
org.tbyrne.logging.LogType.externalError = "externalError";
LazyInst._metaName = "lazyInst";
composure.traits.TraitCollection.__meta__ = { fields : { traitRemoved : { lazyInst : null}, traitAdded : { lazyInst : null}}};
haxe.ds.ObjectMap.count = 0;
composureTest.ClassIncluder.main();
})();
