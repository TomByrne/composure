var $_, $hxClasses = $hxClasses || {}, $estr = function() { return js.Boot.__string_rec(this,''); }
function $extend(from, fields) {
	function inherit() {}; inherit.prototype = from; var proto = new inherit();
	for (var name in fields) proto[name] = fields[name];
	return proto;
}
var Hash = $hxClasses["Hash"] = function() {
	this.h = { };
};
Hash.__name__ = ["Hash"];
Hash.prototype = {
	h: null
	,set: function(key,value) {
		this.h["$" + key] = value;
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,remove: function(key) {
		key = "$" + key;
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return a.iterator();
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,toString: function() {
		var s = new StringBuf();
		s.b[s.b.length] = "{";
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			s.b[s.b.length] = i == null?"null":i;
			s.b[s.b.length] = " => ";
			s.add(Std.string(this.get(i)));
			if(it.hasNext()) s.b[s.b.length] = ", ";
		}
		s.b[s.b.length] = "}";
		return s.b.join("");
	}
	,__class__: Hash
}
var IntHash = $hxClasses["IntHash"] = function() {
	this.h = { };
};
IntHash.__name__ = ["IntHash"];
IntHash.prototype = {
	h: null
	,set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty(key);
	}
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return a.iterator();
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i];
		}};
	}
	,toString: function() {
		var s = new StringBuf();
		s.b[s.b.length] = "{";
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			s.b[s.b.length] = i == null?"null":i;
			s.b[s.b.length] = " => ";
			s.add(Std.string(this.get(i)));
			if(it.hasNext()) s.b[s.b.length] = ", ";
		}
		s.b[s.b.length] = "}";
		return s.b.join("");
	}
	,__class__: IntHash
}
var IntIter = $hxClasses["IntIter"] = function(min,max) {
	this.min = min;
	this.max = max;
};
IntIter.__name__ = ["IntIter"];
IntIter.prototype = {
	min: null
	,max: null
	,hasNext: function() {
		return this.min < this.max;
	}
	,next: function() {
		return this.min++;
	}
	,__class__: IntIter
}
var List = $hxClasses["List"] = function() {
	this.length = 0;
};
List.__name__ = ["List"];
List.prototype = {
	h: null
	,q: null
	,length: null
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,first: function() {
		return this.h == null?null:this.h[0];
	}
	,last: function() {
		return this.q == null?null:this.q[0];
	}
	,pop: function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		if(this.h == null) this.q = null;
		this.length--;
		return x;
	}
	,isEmpty: function() {
		return this.h == null;
	}
	,clear: function() {
		this.h = null;
		this.q = null;
		this.length = 0;
	}
	,remove: function(v) {
		var prev = null;
		var l = this.h;
		while(l != null) {
			if(l[0] == v) {
				if(prev == null) this.h = l[1]; else prev[1] = l[1];
				if(this.q == l) this.q = prev;
				this.length--;
				return true;
			}
			prev = l;
			l = l[1];
		}
		return false;
	}
	,iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,toString: function() {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		s.b[s.b.length] = "{";
		while(l != null) {
			if(first) first = false; else s.b[s.b.length] = ", ";
			s.add(Std.string(l[0]));
			l = l[1];
		}
		s.b[s.b.length] = "}";
		return s.b.join("");
	}
	,join: function(sep) {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		while(l != null) {
			if(first) first = false; else s.b[s.b.length] = sep == null?"null":sep;
			s.add(l[0]);
			l = l[1];
		}
		return s.b.join("");
	}
	,filter: function(f) {
		var l2 = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			if(f(v)) l2.add(v);
		}
		return l2;
	}
	,map: function(f) {
		var b = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			b.add(f(v));
		}
		return b;
	}
	,__class__: List
}
var Reflect = $hxClasses["Reflect"] = function() { }
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	return Object.prototype.hasOwnProperty.call(o,field);
}
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
	}
	return v;
}
Reflect.setField = function(o,field,value) {
	o[field] = value;
}
Reflect.getProperty = function(o,field) {
	var tmp;
	return o == null?null:o.__properties__ && (tmp = o.__properties__["get_" + field])?o[tmp]():o[field];
}
Reflect.setProperty = function(o,field,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + field])) o[tmp](value); else o[field] = value;
}
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
}
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && f.__name__ == null;
}
Reflect.compare = function(a,b) {
	return a == b?0:a > b?1:-1;
}
Reflect.compareMethods = function(f1,f2) {
	if(f1 == f2) return true;
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) return false;
	return f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
}
Reflect.isObject = function(v) {
	if(v == null) return false;
	var t = typeof(v);
	return t == "string" || t == "object" && !v.__enum__ || t == "function" && v.__name__ != null;
}
Reflect.deleteField = function(o,f) {
	if(!Reflect.hasField(o,f)) return false;
	delete(o[f]);
	return true;
}
Reflect.copy = function(o) {
	var o2 = { };
	var _g = 0, _g1 = Reflect.fields(o);
	while(_g < _g1.length) {
		var f = _g1[_g];
		++_g;
		o2[f] = Reflect.field(o,f);
	}
	return o2;
}
Reflect.makeVarArgs = function(f) {
	return function() {
		var a = Array.prototype.slice.call(arguments);
		return f(a);
	};
}
Reflect.prototype = {
	__class__: Reflect
}
var Std = $hxClasses["Std"] = function() { }
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	return x | 0;
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && x.charCodeAt(1) == 120) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
Std.prototype = {
	__class__: Std
}
var StringBuf = $hxClasses["StringBuf"] = function() {
	this.b = new Array();
};
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	add: function(x) {
		this.b[this.b.length] = x == null?"null":x;
	}
	,addSub: function(s,pos,len) {
		this.b[this.b.length] = s.substr(pos,len);
	}
	,addChar: function(c) {
		this.b[this.b.length] = String.fromCharCode(c);
	}
	,toString: function() {
		return this.b.join("");
	}
	,b: null
	,__class__: StringBuf
}
var StringTools = $hxClasses["StringTools"] = function() { }
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && s.substr(0,start.length) == start;
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return slen >= elen && s.substr(slen - elen,elen) == end;
}
StringTools.isSpace = function(s,pos) {
	var c = s.charCodeAt(pos);
	return c >= 9 && c <= 13 || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return s.substr(r,l - r); else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return s.substr(0,l - r); else return s;
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		s += c.substr(0,l - sl);
		sl = l;
	} else {
		s += c;
		sl += cl;
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		ns += c.substr(0,l - sl);
		sl = l;
	} else {
		ns += c;
		sl += cl;
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	return s;
}
StringTools.fastCodeAt = function(s,index) {
	return s.cca(index);
}
StringTools.isEOF = function(c) {
	return c != c;
}
StringTools.prototype = {
	__class__: StringTools
}
var ValueType = $hxClasses["ValueType"] = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
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
var Type = $hxClasses["Type"] = function() { }
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	if(o.__enum__ != null) return null;
	return o.__class__;
}
Type.getEnum = function(o) {
	if(o == null) return null;
	return o.__enum__;
}
Type.getSuperClass = function(c) {
	return c.__super__;
}
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
}
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
}
Type.resolveClass = function(name) {
	var cl = $hxClasses[name];
	if(cl == null || cl.__name__ == null) return null;
	return cl;
}
Type.resolveEnum = function(name) {
	var e = $hxClasses[name];
	if(e == null || e.__ename__ == null) return null;
	return e;
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
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
}
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw "Constructor " + constr + " need parameters";
		return f.apply(e,params);
	}
	if(params != null && params.length != 0) throw "Constructor " + constr + " does not need parameters";
	return f;
}
Type.createEnumIndex = function(e,index,params) {
	var c = e.__constructs__[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	return Type.createEnum(e,c,params);
}
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	a.remove("__class__");
	a.remove("__properties__");
	return a;
}
Type.getClassFields = function(c) {
	var a = Reflect.fields(c);
	a.remove("__name__");
	a.remove("__interfaces__");
	a.remove("__properties__");
	a.remove("__super__");
	a.remove("prototype");
	return a;
}
Type.getEnumConstructs = function(e) {
	var a = e.__constructs__;
	return a.copy();
}
Type["typeof"] = function(v) {
	switch(typeof(v)) {
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
		if(v.__name__ != null) return ValueType.TObject;
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
Type.enumConstructor = function(e) {
	return e[0];
}
Type.enumParameters = function(e) {
	return e.slice(2);
}
Type.enumIndex = function(e) {
	return e[1];
}
Type.allEnums = function(e) {
	var all = [];
	var cst = e.__constructs__;
	var _g = 0;
	while(_g < cst.length) {
		var c = cst[_g];
		++_g;
		var v = Reflect.field(e,c);
		if(!Reflect.isFunction(v)) all.push(v);
	}
	return all;
}
Type.prototype = {
	__class__: Type
}
var haxe = haxe || {}
haxe.Log = $hxClasses["haxe.Log"] = function() { }
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.Log.clear = function() {
	js.Boot.__clear_trace();
}
haxe.Log.prototype = {
	__class__: haxe.Log
}
haxe.Serializer = $hxClasses["haxe.Serializer"] = function() {
	this.buf = new StringBuf();
	this.cache = new Array();
	this.useCache = haxe.Serializer.USE_CACHE;
	this.useEnumIndex = haxe.Serializer.USE_ENUM_INDEX;
	this.shash = new Hash();
	this.scount = 0;
};
haxe.Serializer.__name__ = ["haxe","Serializer"];
haxe.Serializer.run = function(v) {
	var s = new haxe.Serializer();
	s.serialize(v);
	return s.toString();
}
haxe.Serializer.prototype = {
	buf: null
	,cache: null
	,shash: null
	,scount: null
	,useCache: null
	,useEnumIndex: null
	,toString: function() {
		return this.buf.b.join("");
	}
	,serializeString: function(s) {
		var x = this.shash.get(s);
		if(x != null) {
			this.buf.add("R");
			this.buf.add(x);
			return;
		}
		this.shash.set(s,this.scount++);
		this.buf.add("y");
		s = StringTools.urlEncode(s);
		this.buf.add(s.length);
		this.buf.add(":");
		this.buf.add(s);
	}
	,serializeRef: function(v) {
		var vt = typeof(v);
		var _g1 = 0, _g = this.cache.length;
		while(_g1 < _g) {
			var i = _g1++;
			var ci = this.cache[i];
			if(typeof(ci) == vt && ci == v) {
				this.buf.add("r");
				this.buf.add(i);
				return true;
			}
		}
		this.cache.push(v);
		return false;
	}
	,serializeFields: function(v) {
		var _g = 0, _g1 = Reflect.fields(v);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			this.serializeString(f);
			this.serialize(Reflect.field(v,f));
		}
		this.buf.add("g");
	}
	,serialize: function(v) {
		var $e = (Type["typeof"](v));
		switch( $e[1] ) {
		case 0:
			this.buf.add("n");
			break;
		case 1:
			if(v == 0) {
				this.buf.add("z");
				return;
			}
			this.buf.add("i");
			this.buf.add(v);
			break;
		case 2:
			if(Math.isNaN(v)) this.buf.add("k"); else if(!Math.isFinite(v)) this.buf.add(v < 0?"m":"p"); else {
				this.buf.add("d");
				this.buf.add(v);
			}
			break;
		case 3:
			this.buf.add(v?"t":"f");
			break;
		case 6:
			var c = $e[2];
			if(c == String) {
				this.serializeString(v);
				return;
			}
			if(this.useCache && this.serializeRef(v)) return;
			switch(c) {
			case Array:
				var ucount = 0;
				this.buf.add("a");
				var l = v["length"];
				var _g = 0;
				while(_g < l) {
					var i = _g++;
					if(v[i] == null) ucount++; else {
						if(ucount > 0) {
							if(ucount == 1) this.buf.add("n"); else {
								this.buf.add("u");
								this.buf.add(ucount);
							}
							ucount = 0;
						}
						this.serialize(v[i]);
					}
				}
				if(ucount > 0) {
					if(ucount == 1) this.buf.add("n"); else {
						this.buf.add("u");
						this.buf.add(ucount);
					}
				}
				this.buf.add("h");
				break;
			case List:
				this.buf.add("l");
				var v1 = v;
				var $it0 = v1.iterator();
				while( $it0.hasNext() ) {
					var i = $it0.next();
					this.serialize(i);
				}
				this.buf.add("h");
				break;
			case Date:
				var d = v;
				this.buf.add("v");
				this.buf.add(d.toString());
				break;
			case Hash:
				this.buf.add("b");
				var v1 = v;
				var $it1 = v1.keys();
				while( $it1.hasNext() ) {
					var k = $it1.next();
					this.serializeString(k);
					this.serialize(v1.get(k));
				}
				this.buf.add("h");
				break;
			case IntHash:
				this.buf.add("q");
				var v1 = v;
				var $it2 = v1.keys();
				while( $it2.hasNext() ) {
					var k = $it2.next();
					this.buf.add(":");
					this.buf.add(k);
					this.serialize(v1.get(k));
				}
				this.buf.add("h");
				break;
			case haxe.io.Bytes:
				var v1 = v;
				var i = 0;
				var max = v1.length - 2;
				var chars = "";
				var b64 = haxe.Serializer.BASE64;
				while(i < max) {
					var b1 = v1.b[i++];
					var b2 = v1.b[i++];
					var b3 = v1.b[i++];
					chars += b64.charAt(b1 >> 2) + b64.charAt((b1 << 4 | b2 >> 4) & 63) + b64.charAt((b2 << 2 | b3 >> 6) & 63) + b64.charAt(b3 & 63);
				}
				if(i == max) {
					var b1 = v1.b[i++];
					var b2 = v1.b[i++];
					chars += b64.charAt(b1 >> 2) + b64.charAt((b1 << 4 | b2 >> 4) & 63) + b64.charAt(b2 << 2 & 63);
				} else if(i == max + 1) {
					var b1 = v1.b[i++];
					chars += b64.charAt(b1 >> 2) + b64.charAt(b1 << 4 & 63);
				}
				this.buf.add("s");
				this.buf.add(chars.length);
				this.buf.add(":");
				this.buf.add(chars);
				break;
			default:
				this.cache.pop();
				if(v.hxSerialize != null) {
					this.buf.add("C");
					this.serializeString(Type.getClassName(c));
					this.cache.push(v);
					v.hxSerialize(this);
					this.buf.add("g");
				} else {
					this.buf.add("c");
					this.serializeString(Type.getClassName(c));
					this.cache.push(v);
					this.serializeFields(v);
				}
			}
			break;
		case 4:
			if(this.useCache && this.serializeRef(v)) return;
			this.buf.add("o");
			this.serializeFields(v);
			break;
		case 7:
			var e = $e[2];
			if(this.useCache && this.serializeRef(v)) return;
			this.cache.pop();
			this.buf.add(this.useEnumIndex?"j":"w");
			this.serializeString(Type.getEnumName(e));
			if(this.useEnumIndex) {
				this.buf.add(":");
				this.buf.add(v[1]);
			} else this.serializeString(v[0]);
			this.buf.add(":");
			var l = v["length"];
			this.buf.add(l - 2);
			var _g = 2;
			while(_g < l) {
				var i = _g++;
				this.serialize(v[i]);
			}
			this.cache.push(v);
			break;
		case 5:
			throw "Cannot serialize function";
			break;
		default:
			throw "Cannot serialize " + Std.string(v);
		}
	}
	,serializeException: function(e) {
		this.buf.add("x");
		this.serialize(e);
	}
	,__class__: haxe.Serializer
}
haxe.StackItem = $hxClasses["haxe.StackItem"] = { __ename__ : ["haxe","StackItem"], __constructs__ : ["CFunction","Module","FilePos","Method","Lambda"] }
haxe.StackItem.CFunction = ["CFunction",0];
haxe.StackItem.CFunction.toString = $estr;
haxe.StackItem.CFunction.__enum__ = haxe.StackItem;
haxe.StackItem.Module = function(m) { var $x = ["Module",1,m]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.FilePos = function(s,file,line) { var $x = ["FilePos",2,s,file,line]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Method = function(classname,method) { var $x = ["Method",3,classname,method]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.StackItem.Lambda = function(v) { var $x = ["Lambda",4,v]; $x.__enum__ = haxe.StackItem; $x.toString = $estr; return $x; }
haxe.Stack = $hxClasses["haxe.Stack"] = function() { }
haxe.Stack.__name__ = ["haxe","Stack"];
haxe.Stack.callStack = function() {
	return [];
}
haxe.Stack.exceptionStack = function() {
	return [];
}
haxe.Stack.toString = function(stack) {
	var b = new StringBuf();
	var _g = 0;
	while(_g < stack.length) {
		var s = stack[_g];
		++_g;
		b.b[b.b.length] = "\nCalled from ";
		haxe.Stack.itemToString(b,s);
	}
	return b.b.join("");
}
haxe.Stack.itemToString = function(b,s) {
	var $e = (s);
	switch( $e[1] ) {
	case 0:
		b.b[b.b.length] = "a C function";
		break;
	case 1:
		var m = $e[2];
		b.b[b.b.length] = "module ";
		b.b[b.b.length] = m == null?"null":m;
		break;
	case 2:
		var line = $e[4], file = $e[3], s1 = $e[2];
		if(s1 != null) {
			haxe.Stack.itemToString(b,s1);
			b.b[b.b.length] = " (";
		}
		b.b[b.b.length] = file == null?"null":file;
		b.b[b.b.length] = " line ";
		b.b[b.b.length] = line == null?"null":line;
		if(s1 != null) b.b[b.b.length] = ")";
		break;
	case 3:
		var meth = $e[3], cname = $e[2];
		b.b[b.b.length] = cname == null?"null":cname;
		b.b[b.b.length] = ".";
		b.b[b.b.length] = meth == null?"null":meth;
		break;
	case 4:
		var n = $e[2];
		b.b[b.b.length] = "local function #";
		b.b[b.b.length] = n == null?"null":n;
		break;
	}
}
haxe.Stack.makeStack = function(s) {
	return null;
}
haxe.Stack.prototype = {
	__class__: haxe.Stack
}
haxe.TypeTools = $hxClasses["haxe.TypeTools"] = function() { }
haxe.TypeTools.__name__ = ["haxe","TypeTools"];
haxe.TypeTools.getClassNames = function(value) {
	var result = new List();
	var valueClass = Std["is"](value,Class)?value:Type.getClass(value);
	while(null != valueClass) {
		result.add(Type.getClassName(valueClass));
		valueClass = Type.getSuperClass(valueClass);
	}
	return result;
}
haxe.TypeTools.prototype = {
	__class__: haxe.TypeTools
}
haxe.Unserializer = $hxClasses["haxe.Unserializer"] = function(buf) {
	this.buf = buf;
	this.length = buf.length;
	this.pos = 0;
	this.scache = new Array();
	this.cache = new Array();
	var r = haxe.Unserializer.DEFAULT_RESOLVER;
	if(r == null) {
		r = Type;
		haxe.Unserializer.DEFAULT_RESOLVER = r;
	}
	this.setResolver(r);
};
haxe.Unserializer.__name__ = ["haxe","Unserializer"];
haxe.Unserializer.initCodes = function() {
	var codes = new Array();
	var _g1 = 0, _g = haxe.Unserializer.BASE64.length;
	while(_g1 < _g) {
		var i = _g1++;
		codes[haxe.Unserializer.BASE64.cca(i)] = i;
	}
	return codes;
}
haxe.Unserializer.run = function(v) {
	return new haxe.Unserializer(v).unserialize();
}
haxe.Unserializer.prototype = {
	buf: null
	,pos: null
	,length: null
	,cache: null
	,scache: null
	,resolver: null
	,setResolver: function(r) {
		if(r == null) this.resolver = { resolveClass : function(_) {
			return null;
		}, resolveEnum : function(_) {
			return null;
		}}; else this.resolver = r;
	}
	,getResolver: function() {
		return this.resolver;
	}
	,get: function(p) {
		return this.buf.cca(p);
	}
	,readDigits: function() {
		var k = 0;
		var s = false;
		var fpos = this.pos;
		while(true) {
			var c = this.buf.cca(this.pos);
			if(c != c) break;
			if(c == 45) {
				if(this.pos != fpos) break;
				s = true;
				this.pos++;
				continue;
			}
			if(c < 48 || c > 57) break;
			k = k * 10 + (c - 48);
			this.pos++;
		}
		if(s) k *= -1;
		return k;
	}
	,unserializeObject: function(o) {
		while(true) {
			if(this.pos >= this.length) throw "Invalid object";
			if(this.buf.cca(this.pos) == 103) break;
			var k = this.unserialize();
			if(!Std["is"](k,String)) throw "Invalid object key";
			var v = this.unserialize();
			o[k] = v;
		}
		this.pos++;
	}
	,unserializeEnum: function(edecl,tag) {
		if(this.buf.cca(this.pos++) != 58) throw "Invalid enum format";
		var nargs = this.readDigits();
		if(nargs == 0) return Type.createEnum(edecl,tag);
		var args = new Array();
		while(nargs-- > 0) args.push(this.unserialize());
		return Type.createEnum(edecl,tag,args);
	}
	,unserialize: function() {
		switch(this.buf.cca(this.pos++)) {
		case 110:
			return null;
		case 116:
			return true;
		case 102:
			return false;
		case 122:
			return 0;
		case 105:
			return this.readDigits();
		case 100:
			var p1 = this.pos;
			while(true) {
				var c = this.buf.cca(this.pos);
				if(c >= 43 && c < 58 || c == 101 || c == 69) this.pos++; else break;
			}
			return Std.parseFloat(this.buf.substr(p1,this.pos - p1));
		case 121:
			var len = this.readDigits();
			if(this.buf.cca(this.pos++) != 58 || this.length - this.pos < len) throw "Invalid string length";
			var s = this.buf.substr(this.pos,len);
			this.pos += len;
			s = StringTools.urlDecode(s);
			this.scache.push(s);
			return s;
		case 107:
			return Math.NaN;
		case 109:
			return Math.NEGATIVE_INFINITY;
		case 112:
			return Math.POSITIVE_INFINITY;
		case 97:
			var buf = this.buf;
			var a = new Array();
			this.cache.push(a);
			while(true) {
				var c = this.buf.cca(this.pos);
				if(c == 104) {
					this.pos++;
					break;
				}
				if(c == 117) {
					this.pos++;
					var n = this.readDigits();
					a[a.length + n - 1] = null;
				} else a.push(this.unserialize());
			}
			return a;
		case 111:
			var o = { };
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 114:
			var n = this.readDigits();
			if(n < 0 || n >= this.cache.length) throw "Invalid reference";
			return this.cache[n];
		case 82:
			var n = this.readDigits();
			if(n < 0 || n >= this.scache.length) throw "Invalid string reference";
			return this.scache[n];
		case 120:
			throw this.unserialize();
			break;
		case 99:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw "Class not found " + name;
			var o = Type.createEmptyInstance(cl);
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 119:
			var name = this.unserialize();
			var edecl = this.resolver.resolveEnum(name);
			if(edecl == null) throw "Enum not found " + name;
			var e = this.unserializeEnum(edecl,this.unserialize());
			this.cache.push(e);
			return e;
		case 106:
			var name = this.unserialize();
			var edecl = this.resolver.resolveEnum(name);
			if(edecl == null) throw "Enum not found " + name;
			this.pos++;
			var index = this.readDigits();
			var tag = Type.getEnumConstructs(edecl)[index];
			if(tag == null) throw "Unknown enum index " + name + "@" + index;
			var e = this.unserializeEnum(edecl,tag);
			this.cache.push(e);
			return e;
		case 108:
			var l = new List();
			this.cache.push(l);
			var buf = this.buf;
			while(this.buf.cca(this.pos) != 104) l.add(this.unserialize());
			this.pos++;
			return l;
		case 98:
			var h = new Hash();
			this.cache.push(h);
			var buf = this.buf;
			while(this.buf.cca(this.pos) != 104) {
				var s = this.unserialize();
				h.set(s,this.unserialize());
			}
			this.pos++;
			return h;
		case 113:
			var h = new IntHash();
			this.cache.push(h);
			var buf = this.buf;
			var c = this.buf.cca(this.pos++);
			while(c == 58) {
				var i = this.readDigits();
				h.set(i,this.unserialize());
				c = this.buf.cca(this.pos++);
			}
			if(c != 104) throw "Invalid IntHash format";
			return h;
		case 118:
			var d = Date.fromString(this.buf.substr(this.pos,19));
			this.cache.push(d);
			this.pos += 19;
			return d;
		case 115:
			var len = this.readDigits();
			var buf = this.buf;
			if(this.buf.cca(this.pos++) != 58 || this.length - this.pos < len) throw "Invalid bytes length";
			var codes = haxe.Unserializer.CODES;
			if(codes == null) {
				codes = haxe.Unserializer.initCodes();
				haxe.Unserializer.CODES = codes;
			}
			var i = this.pos;
			var rest = len & 3;
			var size = (len >> 2) * 3 + (rest >= 2?rest - 1:0);
			var max = i + (len - rest);
			var bytes = haxe.io.Bytes.alloc(size);
			var bpos = 0;
			while(i < max) {
				var c1 = codes[buf.cca(i++)];
				var c2 = codes[buf.cca(i++)];
				bytes.b[bpos++] = (c1 << 2 | c2 >> 4) & 255;
				var c3 = codes[buf.cca(i++)];
				bytes.b[bpos++] = (c2 << 4 | c3 >> 2) & 255;
				var c4 = codes[buf.cca(i++)];
				bytes.b[bpos++] = (c3 << 6 | c4) & 255;
			}
			if(rest >= 2) {
				var c1 = codes[buf.cca(i++)];
				var c2 = codes[buf.cca(i++)];
				bytes.b[bpos++] = (c1 << 2 | c2 >> 4) & 255;
				if(rest == 3) {
					var c3 = codes[buf.cca(i++)];
					bytes.b[bpos++] = (c2 << 4 | c3 >> 2) & 255;
				}
			}
			this.pos += len;
			this.cache.push(bytes);
			return bytes;
		case 67:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw "Class not found " + name;
			var o = Type.createEmptyInstance(cl);
			this.cache.push(o);
			o.hxUnserialize(this);
			if(this.buf.cca(this.pos++) != 103) throw "Invalid custom data";
			return o;
		default:
		}
		this.pos--;
		throw "Invalid char " + this.buf.charAt(this.pos) + " at position " + this.pos;
	}
	,__class__: haxe.Unserializer
}
if(!haxe.exception) haxe.exception = {}
haxe.exception.Exception = $hxClasses["haxe.exception.Exception"] = function(message,innerException,numberOfStackTraceShifts) {
	this.message = null == message?"Unknown exception":message;
	this.innerException = innerException;
	this.generateStackTrace(numberOfStackTraceShifts);
	this.stackTrace = this.stackTraceArray;
};
haxe.exception.Exception.__name__ = ["haxe","exception","Exception"];
haxe.exception.Exception.prototype = {
	baseException: null
	,innerException: null
	,message: null
	,stackTrace: null
	,stackTraceArray: null
	,generateStackTrace: function(numberOfStackTraceShifts) {
		this.stackTraceArray = haxe.Stack.callStack().slice(numberOfStackTraceShifts + 1);
		var exceptionClass = Type.getClass(this);
		while(haxe.exception.Exception != exceptionClass) {
			this.stackTraceArray.shift();
			exceptionClass = Type.getSuperClass(exceptionClass);
		}
	}
	,getBaseException: function() {
		var result = this;
		while(null != result.innerException) result = result.innerException;
		return result;
	}
	,toString: function() {
		return this.message + haxe.Stack.toString(this.stackTraceArray);
	}
	,__class__: haxe.exception.Exception
	,__properties__: {get_baseException:"getBaseException"}
}
haxe.exception.ArgumentNullException = $hxClasses["haxe.exception.ArgumentNullException"] = function(argumentName,numberOfStackTraceShifts) {
	haxe.exception.Exception.call(this,"Argument " + argumentName + " must be non-null",null,numberOfStackTraceShifts);
};
haxe.exception.ArgumentNullException.__name__ = ["haxe","exception","ArgumentNullException"];
haxe.exception.ArgumentNullException.__super__ = haxe.exception.Exception;
haxe.exception.ArgumentNullException.prototype = $extend(haxe.exception.Exception.prototype,{
	__class__: haxe.exception.ArgumentNullException
});
if(!haxe.io) haxe.io = {}
haxe.io.Bytes = $hxClasses["haxe.io.Bytes"] = function(length,b) {
	this.length = length;
	this.b = b;
};
haxe.io.Bytes.__name__ = ["haxe","io","Bytes"];
haxe.io.Bytes.alloc = function(length) {
	var a = new Array();
	var _g = 0;
	while(_g < length) {
		var i = _g++;
		a.push(0);
	}
	return new haxe.io.Bytes(length,a);
}
haxe.io.Bytes.ofString = function(s) {
	var a = new Array();
	var _g1 = 0, _g = s.length;
	while(_g1 < _g) {
		var i = _g1++;
		var c = s.cca(i);
		if(c <= 127) a.push(c); else if(c <= 2047) {
			a.push(192 | c >> 6);
			a.push(128 | c & 63);
		} else if(c <= 65535) {
			a.push(224 | c >> 12);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		} else {
			a.push(240 | c >> 18);
			a.push(128 | c >> 12 & 63);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		}
	}
	return new haxe.io.Bytes(a.length,a);
}
haxe.io.Bytes.ofData = function(b) {
	return new haxe.io.Bytes(b.length,b);
}
haxe.io.Bytes.prototype = {
	length: null
	,b: null
	,get: function(pos) {
		return this.b[pos];
	}
	,set: function(pos,v) {
		this.b[pos] = v & 255;
	}
	,blit: function(pos,src,srcpos,len) {
		if(pos < 0 || srcpos < 0 || len < 0 || pos + len > this.length || srcpos + len > src.length) throw haxe.io.Error.OutsideBounds;
		var b1 = this.b;
		var b2 = src.b;
		if(b1 == b2 && pos > srcpos) {
			var i = len;
			while(i > 0) {
				i--;
				b1[i + pos] = b2[i + srcpos];
			}
			return;
		}
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			b1[i + pos] = b2[i + srcpos];
		}
	}
	,sub: function(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
		return new haxe.io.Bytes(len,this.b.slice(pos,pos + len));
	}
	,compare: function(other) {
		var b1 = this.b;
		var b2 = other.b;
		var len = this.length < other.length?this.length:other.length;
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			if(b1[i] != b2[i]) return b1[i] - b2[i];
		}
		return this.length - other.length;
	}
	,readString: function(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
		var s = "";
		var b = this.b;
		var fcc = String.fromCharCode;
		var i = pos;
		var max = pos + len;
		while(i < max) {
			var c = b[i++];
			if(c < 128) {
				if(c == 0) break;
				s += fcc(c);
			} else if(c < 224) s += fcc((c & 63) << 6 | b[i++] & 127); else if(c < 240) {
				var c2 = b[i++];
				s += fcc((c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127);
			} else {
				var c2 = b[i++];
				var c3 = b[i++];
				s += fcc((c & 15) << 18 | (c2 & 127) << 12 | c3 << 6 & 127 | b[i++] & 127);
			}
		}
		return s;
	}
	,toString: function() {
		return this.readString(0,this.length);
	}
	,toHex: function() {
		var s = new StringBuf();
		var chars = [];
		var str = "0123456789abcdef";
		var _g1 = 0, _g = str.length;
		while(_g1 < _g) {
			var i = _g1++;
			chars.push(str.charCodeAt(i));
		}
		var _g1 = 0, _g = this.length;
		while(_g1 < _g) {
			var i = _g1++;
			var c = this.b[i];
			s.b[s.b.length] = String.fromCharCode(chars[c >> 4]);
			s.b[s.b.length] = String.fromCharCode(chars[c & 15]);
		}
		return s.b.join("");
	}
	,getData: function() {
		return this.b;
	}
	,__class__: haxe.io.Bytes
}
haxe.io.Error = $hxClasses["haxe.io.Error"] = { __ename__ : ["haxe","io","Error"], __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] }
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; }
if(!haxe.macro) haxe.macro = {}
haxe.macro.Compiler = $hxClasses["haxe.macro.Compiler"] = function() { }
haxe.macro.Compiler.__name__ = ["haxe","macro","Compiler"];
haxe.macro.Compiler.prototype = {
	__class__: haxe.macro.Compiler
}
haxe.macro.Context = $hxClasses["haxe.macro.Context"] = function() { }
haxe.macro.Context.__name__ = ["haxe","macro","Context"];
haxe.macro.Context.prototype = {
	__class__: haxe.macro.Context
}
haxe.macro.Constant = $hxClasses["haxe.macro.Constant"] = { __ename__ : ["haxe","macro","Constant"], __constructs__ : ["CInt","CFloat","CString","CIdent","CType","CRegexp"] }
haxe.macro.Constant.CInt = function(v) { var $x = ["CInt",0,v]; $x.__enum__ = haxe.macro.Constant; $x.toString = $estr; return $x; }
haxe.macro.Constant.CFloat = function(f) { var $x = ["CFloat",1,f]; $x.__enum__ = haxe.macro.Constant; $x.toString = $estr; return $x; }
haxe.macro.Constant.CString = function(s) { var $x = ["CString",2,s]; $x.__enum__ = haxe.macro.Constant; $x.toString = $estr; return $x; }
haxe.macro.Constant.CIdent = function(s) { var $x = ["CIdent",3,s]; $x.__enum__ = haxe.macro.Constant; $x.toString = $estr; return $x; }
haxe.macro.Constant.CType = function(s) { var $x = ["CType",4,s]; $x.__enum__ = haxe.macro.Constant; $x.toString = $estr; return $x; }
haxe.macro.Constant.CRegexp = function(r,opt) { var $x = ["CRegexp",5,r,opt]; $x.__enum__ = haxe.macro.Constant; $x.toString = $estr; return $x; }
haxe.macro.Binop = $hxClasses["haxe.macro.Binop"] = { __ename__ : ["haxe","macro","Binop"], __constructs__ : ["OpAdd","OpMult","OpDiv","OpSub","OpAssign","OpEq","OpNotEq","OpGt","OpGte","OpLt","OpLte","OpAnd","OpOr","OpXor","OpBoolAnd","OpBoolOr","OpShl","OpShr","OpUShr","OpMod","OpAssignOp","OpInterval"] }
haxe.macro.Binop.OpAdd = ["OpAdd",0];
haxe.macro.Binop.OpAdd.toString = $estr;
haxe.macro.Binop.OpAdd.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpMult = ["OpMult",1];
haxe.macro.Binop.OpMult.toString = $estr;
haxe.macro.Binop.OpMult.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpDiv = ["OpDiv",2];
haxe.macro.Binop.OpDiv.toString = $estr;
haxe.macro.Binop.OpDiv.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpSub = ["OpSub",3];
haxe.macro.Binop.OpSub.toString = $estr;
haxe.macro.Binop.OpSub.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpAssign = ["OpAssign",4];
haxe.macro.Binop.OpAssign.toString = $estr;
haxe.macro.Binop.OpAssign.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpEq = ["OpEq",5];
haxe.macro.Binop.OpEq.toString = $estr;
haxe.macro.Binop.OpEq.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpNotEq = ["OpNotEq",6];
haxe.macro.Binop.OpNotEq.toString = $estr;
haxe.macro.Binop.OpNotEq.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpGt = ["OpGt",7];
haxe.macro.Binop.OpGt.toString = $estr;
haxe.macro.Binop.OpGt.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpGte = ["OpGte",8];
haxe.macro.Binop.OpGte.toString = $estr;
haxe.macro.Binop.OpGte.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpLt = ["OpLt",9];
haxe.macro.Binop.OpLt.toString = $estr;
haxe.macro.Binop.OpLt.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpLte = ["OpLte",10];
haxe.macro.Binop.OpLte.toString = $estr;
haxe.macro.Binop.OpLte.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpAnd = ["OpAnd",11];
haxe.macro.Binop.OpAnd.toString = $estr;
haxe.macro.Binop.OpAnd.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpOr = ["OpOr",12];
haxe.macro.Binop.OpOr.toString = $estr;
haxe.macro.Binop.OpOr.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpXor = ["OpXor",13];
haxe.macro.Binop.OpXor.toString = $estr;
haxe.macro.Binop.OpXor.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpBoolAnd = ["OpBoolAnd",14];
haxe.macro.Binop.OpBoolAnd.toString = $estr;
haxe.macro.Binop.OpBoolAnd.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpBoolOr = ["OpBoolOr",15];
haxe.macro.Binop.OpBoolOr.toString = $estr;
haxe.macro.Binop.OpBoolOr.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpShl = ["OpShl",16];
haxe.macro.Binop.OpShl.toString = $estr;
haxe.macro.Binop.OpShl.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpShr = ["OpShr",17];
haxe.macro.Binop.OpShr.toString = $estr;
haxe.macro.Binop.OpShr.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpUShr = ["OpUShr",18];
haxe.macro.Binop.OpUShr.toString = $estr;
haxe.macro.Binop.OpUShr.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpMod = ["OpMod",19];
haxe.macro.Binop.OpMod.toString = $estr;
haxe.macro.Binop.OpMod.__enum__ = haxe.macro.Binop;
haxe.macro.Binop.OpAssignOp = function(op) { var $x = ["OpAssignOp",20,op]; $x.__enum__ = haxe.macro.Binop; $x.toString = $estr; return $x; }
haxe.macro.Binop.OpInterval = ["OpInterval",21];
haxe.macro.Binop.OpInterval.toString = $estr;
haxe.macro.Binop.OpInterval.__enum__ = haxe.macro.Binop;
haxe.macro.Unop = $hxClasses["haxe.macro.Unop"] = { __ename__ : ["haxe","macro","Unop"], __constructs__ : ["OpIncrement","OpDecrement","OpNot","OpNeg","OpNegBits"] }
haxe.macro.Unop.OpIncrement = ["OpIncrement",0];
haxe.macro.Unop.OpIncrement.toString = $estr;
haxe.macro.Unop.OpIncrement.__enum__ = haxe.macro.Unop;
haxe.macro.Unop.OpDecrement = ["OpDecrement",1];
haxe.macro.Unop.OpDecrement.toString = $estr;
haxe.macro.Unop.OpDecrement.__enum__ = haxe.macro.Unop;
haxe.macro.Unop.OpNot = ["OpNot",2];
haxe.macro.Unop.OpNot.toString = $estr;
haxe.macro.Unop.OpNot.__enum__ = haxe.macro.Unop;
haxe.macro.Unop.OpNeg = ["OpNeg",3];
haxe.macro.Unop.OpNeg.toString = $estr;
haxe.macro.Unop.OpNeg.__enum__ = haxe.macro.Unop;
haxe.macro.Unop.OpNegBits = ["OpNegBits",4];
haxe.macro.Unop.OpNegBits.toString = $estr;
haxe.macro.Unop.OpNegBits.__enum__ = haxe.macro.Unop;
haxe.macro.ExprDef = $hxClasses["haxe.macro.ExprDef"] = { __ename__ : ["haxe","macro","ExprDef"], __constructs__ : ["EConst","EArray","EBinop","EField","EType","EParenthesis","EObjectDecl","EArrayDecl","ECall","ENew","EUnop","EVars","EFunction","EBlock","EFor","EIn","EIf","EWhile","ESwitch","ETry","EReturn","EBreak","EContinue","EUntyped","EThrow","ECast","EDisplay","EDisplayNew","ETernary","ECheckType"] }
haxe.macro.ExprDef.EConst = function(c) { var $x = ["EConst",0,c]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EArray = function(e1,e2) { var $x = ["EArray",1,e1,e2]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EBinop = function(op,e1,e2) { var $x = ["EBinop",2,op,e1,e2]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EField = function(e,field) { var $x = ["EField",3,e,field]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EType = function(e,field) { var $x = ["EType",4,e,field]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EParenthesis = function(e) { var $x = ["EParenthesis",5,e]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EObjectDecl = function(fields) { var $x = ["EObjectDecl",6,fields]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EArrayDecl = function(values) { var $x = ["EArrayDecl",7,values]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.ECall = function(e,params) { var $x = ["ECall",8,e,params]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.ENew = function(t,params) { var $x = ["ENew",9,t,params]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EUnop = function(op,postFix,e) { var $x = ["EUnop",10,op,postFix,e]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EVars = function(vars) { var $x = ["EVars",11,vars]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EFunction = function(name,f) { var $x = ["EFunction",12,name,f]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EBlock = function(exprs) { var $x = ["EBlock",13,exprs]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EFor = function(it,expr) { var $x = ["EFor",14,it,expr]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EIn = function(e1,e2) { var $x = ["EIn",15,e1,e2]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EIf = function(econd,eif,eelse) { var $x = ["EIf",16,econd,eif,eelse]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EWhile = function(econd,e,normalWhile) { var $x = ["EWhile",17,econd,e,normalWhile]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.ESwitch = function(e,cases,edef) { var $x = ["ESwitch",18,e,cases,edef]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.ETry = function(e,catches) { var $x = ["ETry",19,e,catches]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EReturn = function(e) { var $x = ["EReturn",20,e]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EBreak = ["EBreak",21];
haxe.macro.ExprDef.EBreak.toString = $estr;
haxe.macro.ExprDef.EBreak.__enum__ = haxe.macro.ExprDef;
haxe.macro.ExprDef.EContinue = ["EContinue",22];
haxe.macro.ExprDef.EContinue.toString = $estr;
haxe.macro.ExprDef.EContinue.__enum__ = haxe.macro.ExprDef;
haxe.macro.ExprDef.EUntyped = function(e) { var $x = ["EUntyped",23,e]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EThrow = function(e) { var $x = ["EThrow",24,e]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.ECast = function(e,t) { var $x = ["ECast",25,e,t]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EDisplay = function(e,isCall) { var $x = ["EDisplay",26,e,isCall]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.EDisplayNew = function(t) { var $x = ["EDisplayNew",27,t]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.ETernary = function(econd,eif,eelse) { var $x = ["ETernary",28,econd,eif,eelse]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ExprDef.ECheckType = function(e,t) { var $x = ["ECheckType",29,e,t]; $x.__enum__ = haxe.macro.ExprDef; $x.toString = $estr; return $x; }
haxe.macro.ComplexType = $hxClasses["haxe.macro.ComplexType"] = { __ename__ : ["haxe","macro","ComplexType"], __constructs__ : ["TPath","TFunction","TAnonymous","TParent","TExtend","TOptional"] }
haxe.macro.ComplexType.TPath = function(p) { var $x = ["TPath",0,p]; $x.__enum__ = haxe.macro.ComplexType; $x.toString = $estr; return $x; }
haxe.macro.ComplexType.TFunction = function(args,ret) { var $x = ["TFunction",1,args,ret]; $x.__enum__ = haxe.macro.ComplexType; $x.toString = $estr; return $x; }
haxe.macro.ComplexType.TAnonymous = function(fields) { var $x = ["TAnonymous",2,fields]; $x.__enum__ = haxe.macro.ComplexType; $x.toString = $estr; return $x; }
haxe.macro.ComplexType.TParent = function(t) { var $x = ["TParent",3,t]; $x.__enum__ = haxe.macro.ComplexType; $x.toString = $estr; return $x; }
haxe.macro.ComplexType.TExtend = function(p,fields) { var $x = ["TExtend",4,p,fields]; $x.__enum__ = haxe.macro.ComplexType; $x.toString = $estr; return $x; }
haxe.macro.ComplexType.TOptional = function(t) { var $x = ["TOptional",5,t]; $x.__enum__ = haxe.macro.ComplexType; $x.toString = $estr; return $x; }
haxe.macro.TypeParam = $hxClasses["haxe.macro.TypeParam"] = { __ename__ : ["haxe","macro","TypeParam"], __constructs__ : ["TPType","TPExpr"] }
haxe.macro.TypeParam.TPType = function(t) { var $x = ["TPType",0,t]; $x.__enum__ = haxe.macro.TypeParam; $x.toString = $estr; return $x; }
haxe.macro.TypeParam.TPExpr = function(e) { var $x = ["TPExpr",1,e]; $x.__enum__ = haxe.macro.TypeParam; $x.toString = $estr; return $x; }
haxe.macro.Access = $hxClasses["haxe.macro.Access"] = { __ename__ : ["haxe","macro","Access"], __constructs__ : ["APublic","APrivate","AStatic","AOverride","ADynamic","AInline"] }
haxe.macro.Access.APublic = ["APublic",0];
haxe.macro.Access.APublic.toString = $estr;
haxe.macro.Access.APublic.__enum__ = haxe.macro.Access;
haxe.macro.Access.APrivate = ["APrivate",1];
haxe.macro.Access.APrivate.toString = $estr;
haxe.macro.Access.APrivate.__enum__ = haxe.macro.Access;
haxe.macro.Access.AStatic = ["AStatic",2];
haxe.macro.Access.AStatic.toString = $estr;
haxe.macro.Access.AStatic.__enum__ = haxe.macro.Access;
haxe.macro.Access.AOverride = ["AOverride",3];
haxe.macro.Access.AOverride.toString = $estr;
haxe.macro.Access.AOverride.__enum__ = haxe.macro.Access;
haxe.macro.Access.ADynamic = ["ADynamic",4];
haxe.macro.Access.ADynamic.toString = $estr;
haxe.macro.Access.ADynamic.__enum__ = haxe.macro.Access;
haxe.macro.Access.AInline = ["AInline",5];
haxe.macro.Access.AInline.toString = $estr;
haxe.macro.Access.AInline.__enum__ = haxe.macro.Access;
haxe.macro.FieldType = $hxClasses["haxe.macro.FieldType"] = { __ename__ : ["haxe","macro","FieldType"], __constructs__ : ["FVar","FFun","FProp"] }
haxe.macro.FieldType.FVar = function(t,e) { var $x = ["FVar",0,t,e]; $x.__enum__ = haxe.macro.FieldType; $x.toString = $estr; return $x; }
haxe.macro.FieldType.FFun = function(f) { var $x = ["FFun",1,f]; $x.__enum__ = haxe.macro.FieldType; $x.toString = $estr; return $x; }
haxe.macro.FieldType.FProp = function(get,set,t,e) { var $x = ["FProp",2,get,set,t,e]; $x.__enum__ = haxe.macro.FieldType; $x.toString = $estr; return $x; }
haxe.macro.TypeDefKind = $hxClasses["haxe.macro.TypeDefKind"] = { __ename__ : ["haxe","macro","TypeDefKind"], __constructs__ : ["TDEnum","TDStructure","TDClass"] }
haxe.macro.TypeDefKind.TDEnum = ["TDEnum",0];
haxe.macro.TypeDefKind.TDEnum.toString = $estr;
haxe.macro.TypeDefKind.TDEnum.__enum__ = haxe.macro.TypeDefKind;
haxe.macro.TypeDefKind.TDStructure = ["TDStructure",1];
haxe.macro.TypeDefKind.TDStructure.toString = $estr;
haxe.macro.TypeDefKind.TDStructure.__enum__ = haxe.macro.TypeDefKind;
haxe.macro.TypeDefKind.TDClass = function(extend,implement,isInterface) { var $x = ["TDClass",2,extend,implement,isInterface]; $x.__enum__ = haxe.macro.TypeDefKind; $x.toString = $estr; return $x; }
haxe.macro.Error = $hxClasses["haxe.macro.Error"] = function(m,p) {
	this.message = m;
	this.pos = p;
};
haxe.macro.Error.__name__ = ["haxe","macro","Error"];
haxe.macro.Error.prototype = {
	message: null
	,pos: null
	,__class__: haxe.macro.Error
}
haxe.macro.Type = $hxClasses["haxe.macro.Type"] = { __ename__ : ["haxe","macro","Type"], __constructs__ : ["TMono","TEnum","TInst","TType","TFun","TAnonymous","TDynamic","TLazy"] }
haxe.macro.Type.TMono = function(t) { var $x = ["TMono",0,t]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.Type.TEnum = function(t,params) { var $x = ["TEnum",1,t,params]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.Type.TInst = function(t,params) { var $x = ["TInst",2,t,params]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.Type.TType = function(t,params) { var $x = ["TType",3,t,params]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.Type.TFun = function(args,ret) { var $x = ["TFun",4,args,ret]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.Type.TAnonymous = function(a) { var $x = ["TAnonymous",5,a]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.Type.TDynamic = function(t) { var $x = ["TDynamic",6,t]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.Type.TLazy = function(f) { var $x = ["TLazy",7,f]; $x.__enum__ = haxe.macro.Type; $x.toString = $estr; return $x; }
haxe.macro.ClassKind = $hxClasses["haxe.macro.ClassKind"] = { __ename__ : ["haxe","macro","ClassKind"], __constructs__ : ["KNormal","KTypeParameter","KExtension","KExpr","KGeneric","KGenericInstance","KMacroType"] }
haxe.macro.ClassKind.KNormal = ["KNormal",0];
haxe.macro.ClassKind.KNormal.toString = $estr;
haxe.macro.ClassKind.KNormal.__enum__ = haxe.macro.ClassKind;
haxe.macro.ClassKind.KTypeParameter = ["KTypeParameter",1];
haxe.macro.ClassKind.KTypeParameter.toString = $estr;
haxe.macro.ClassKind.KTypeParameter.__enum__ = haxe.macro.ClassKind;
haxe.macro.ClassKind.KExtension = function(cl,params) { var $x = ["KExtension",2,cl,params]; $x.__enum__ = haxe.macro.ClassKind; $x.toString = $estr; return $x; }
haxe.macro.ClassKind.KExpr = function(expr) { var $x = ["KExpr",3,expr]; $x.__enum__ = haxe.macro.ClassKind; $x.toString = $estr; return $x; }
haxe.macro.ClassKind.KGeneric = ["KGeneric",4];
haxe.macro.ClassKind.KGeneric.toString = $estr;
haxe.macro.ClassKind.KGeneric.__enum__ = haxe.macro.ClassKind;
haxe.macro.ClassKind.KGenericInstance = function(cl,params) { var $x = ["KGenericInstance",5,cl,params]; $x.__enum__ = haxe.macro.ClassKind; $x.toString = $estr; return $x; }
haxe.macro.ClassKind.KMacroType = ["KMacroType",6];
haxe.macro.ClassKind.KMacroType.toString = $estr;
haxe.macro.ClassKind.KMacroType.__enum__ = haxe.macro.ClassKind;
haxe.macro.FieldKind = $hxClasses["haxe.macro.FieldKind"] = { __ename__ : ["haxe","macro","FieldKind"], __constructs__ : ["FVar","FMethod"] }
haxe.macro.FieldKind.FVar = function(read,write) { var $x = ["FVar",0,read,write]; $x.__enum__ = haxe.macro.FieldKind; $x.toString = $estr; return $x; }
haxe.macro.FieldKind.FMethod = function(k) { var $x = ["FMethod",1,k]; $x.__enum__ = haxe.macro.FieldKind; $x.toString = $estr; return $x; }
haxe.macro.VarAccess = $hxClasses["haxe.macro.VarAccess"] = { __ename__ : ["haxe","macro","VarAccess"], __constructs__ : ["AccNormal","AccNo","AccNever","AccResolve","AccCall","AccInline","AccRequire"] }
haxe.macro.VarAccess.AccNormal = ["AccNormal",0];
haxe.macro.VarAccess.AccNormal.toString = $estr;
haxe.macro.VarAccess.AccNormal.__enum__ = haxe.macro.VarAccess;
haxe.macro.VarAccess.AccNo = ["AccNo",1];
haxe.macro.VarAccess.AccNo.toString = $estr;
haxe.macro.VarAccess.AccNo.__enum__ = haxe.macro.VarAccess;
haxe.macro.VarAccess.AccNever = ["AccNever",2];
haxe.macro.VarAccess.AccNever.toString = $estr;
haxe.macro.VarAccess.AccNever.__enum__ = haxe.macro.VarAccess;
haxe.macro.VarAccess.AccResolve = ["AccResolve",3];
haxe.macro.VarAccess.AccResolve.toString = $estr;
haxe.macro.VarAccess.AccResolve.__enum__ = haxe.macro.VarAccess;
haxe.macro.VarAccess.AccCall = function(m) { var $x = ["AccCall",4,m]; $x.__enum__ = haxe.macro.VarAccess; $x.toString = $estr; return $x; }
haxe.macro.VarAccess.AccInline = ["AccInline",5];
haxe.macro.VarAccess.AccInline.toString = $estr;
haxe.macro.VarAccess.AccInline.__enum__ = haxe.macro.VarAccess;
haxe.macro.VarAccess.AccRequire = function(r) { var $x = ["AccRequire",6,r]; $x.__enum__ = haxe.macro.VarAccess; $x.toString = $estr; return $x; }
haxe.macro.MethodKind = $hxClasses["haxe.macro.MethodKind"] = { __ename__ : ["haxe","macro","MethodKind"], __constructs__ : ["MethNormal","MethInline","MethDynamic","MethMacro"] }
haxe.macro.MethodKind.MethNormal = ["MethNormal",0];
haxe.macro.MethodKind.MethNormal.toString = $estr;
haxe.macro.MethodKind.MethNormal.__enum__ = haxe.macro.MethodKind;
haxe.macro.MethodKind.MethInline = ["MethInline",1];
haxe.macro.MethodKind.MethInline.toString = $estr;
haxe.macro.MethodKind.MethInline.__enum__ = haxe.macro.MethodKind;
haxe.macro.MethodKind.MethDynamic = ["MethDynamic",2];
haxe.macro.MethodKind.MethDynamic.toString = $estr;
haxe.macro.MethodKind.MethDynamic.__enum__ = haxe.macro.MethodKind;
haxe.macro.MethodKind.MethMacro = ["MethMacro",3];
haxe.macro.MethodKind.MethMacro.toString = $estr;
haxe.macro.MethodKind.MethMacro.__enum__ = haxe.macro.MethodKind;
var hsl = hsl || {}
if(!hsl.haxe) hsl.haxe = {}
hsl.haxe.Bond = $hxClasses["hsl.haxe.Bond"] = function() {
	this.halted = false;
};
hsl.haxe.Bond.__name__ = ["hsl","haxe","Bond"];
hsl.haxe.Bond.prototype = {
	halted: null
	,willDestroyOnUse: null
	,destroy: function() {
	}
	,destroyOnUse: function() {
		this.willDestroyOnUse = true;
		return this;
	}
	,halt: function() {
		this.halted = true;
	}
	,resume: function() {
		this.halted = false;
	}
	,__class__: hsl.haxe.Bond
}
hsl.haxe.Signaler = $hxClasses["hsl.haxe.Signaler"] = function() { }
hsl.haxe.Signaler.__name__ = ["hsl","haxe","Signaler"];
hsl.haxe.Signaler.prototype = {
	isListenedTo: null
	,subject: null
	,addBubblingTarget: null
	,addNotificationTarget: null
	,bind: null
	,bindAdvanced: null
	,bindVoid: null
	,dispatch: null
	,getIsListenedTo: null
	,removeBubblingTarget: null
	,removeNotificationTarget: null
	,unbind: null
	,unbindAdvanced: null
	,unbindVoid: null
	,__class__: hsl.haxe.Signaler
	,__properties__: {get_isListenedTo:"getIsListenedTo"}
}
hsl.haxe.DirectSignaler = $hxClasses["hsl.haxe.DirectSignaler"] = function(subject,rejectNullData) {
	if(null == subject) throw new haxe.exception.ArgumentNullException("subject",1);
	this.subject = subject;
	this.rejectNullData = rejectNullData;
	this.sentinel = new hsl.haxe._DirectSignaler.SentinelBond();
};
hsl.haxe.DirectSignaler.__name__ = ["hsl","haxe","DirectSignaler"];
hsl.haxe.DirectSignaler.__interfaces__ = [hsl.haxe.Signaler];
hsl.haxe.DirectSignaler.prototype = {
	bubblingTargets: null
	,isListenedTo: null
	,notificationTargets: null
	,rejectNullData: null
	,sentinel: null
	,subject: null
	,subjectClassNames: null
	,addBubblingTarget: function(value) {
		if(null == this.bubblingTargets) this.bubblingTargets = new List();
		this.bubblingTargets.add(value);
	}
	,addNotificationTarget: function(value) {
		if(null == this.notificationTargets) this.notificationTargets = new List();
		this.notificationTargets.add(value);
	}
	,bind: function(listener) {
		if(null == listener) throw new haxe.exception.ArgumentNullException("listener",1);
		return this.sentinel.add(new hsl.haxe._DirectSignaler.RegularBond(listener));
	}
	,bindAdvanced: function(listener) {
		if(null == listener) throw new haxe.exception.ArgumentNullException("listener",1);
		return this.sentinel.add(new hsl.haxe._DirectSignaler.AdvancedBond(listener));
	}
	,bindVoid: function(listener) {
		if(null == listener) throw new haxe.exception.ArgumentNullException("listener",1);
		return this.sentinel.add(new hsl.haxe._DirectSignaler.NiladicBond(listener));
	}
	,bubble: function(data,origin) {
		if(null != this.bubblingTargets) {
			var $it0 = this.bubblingTargets.iterator();
			while( $it0.hasNext() ) {
				var bubblingTarget = $it0.next();
				bubblingTarget.dispatch(data,origin,{ fileName : "DirectSignaler.hx", lineNumber : 109, className : "hsl.haxe.DirectSignaler", methodName : "bubble"});
			}
		}
		if(null != this.notificationTargets) {
			var $it1 = this.notificationTargets.iterator();
			while( $it1.hasNext() ) {
				var notificationTarget = $it1.next();
				notificationTarget.dispatch(null,origin,{ fileName : "DirectSignaler.hx", lineNumber : 114, className : "hsl.haxe.DirectSignaler", methodName : "bubble"});
			}
		}
	}
	,dispatch: function(data,origin,positionInformation) {
		if("dispatchNative" != positionInformation.methodName && "bubble" != positionInformation.methodName) this.verifyCaller(positionInformation);
		if(this.rejectNullData && null == data) throw new haxe.exception.Exception("Some data that was passed is null, but this signaler has been set to reject null data.",null,1);
		origin = null == origin?this.subject:origin;
		if(3 == this.sentinel.callListener(data,this.subject,origin,3)) {
			if(null != this.bubblingTargets) {
				var $it0 = this.bubblingTargets.iterator();
				while( $it0.hasNext() ) {
					var bubblingTarget = $it0.next();
					bubblingTarget.dispatch(data,origin,{ fileName : "DirectSignaler.hx", lineNumber : 109, className : "hsl.haxe.DirectSignaler", methodName : "bubble"});
				}
			}
			if(null != this.notificationTargets) {
				var $it1 = this.notificationTargets.iterator();
				while( $it1.hasNext() ) {
					var notificationTarget = $it1.next();
					notificationTarget.dispatch(null,origin,{ fileName : "DirectSignaler.hx", lineNumber : 114, className : "hsl.haxe.DirectSignaler", methodName : "bubble"});
				}
			}
		}
	}
	,getIsListenedTo: function() {
		return this.sentinel.getIsConnected();
	}
	,getOrigin: function(origin) {
		return null == origin?this.subject:origin;
	}
	,verifyCaller: function(positionInformation) {
		if(null == this.subjectClassNames) this.subjectClassNames = haxe.TypeTools.getClassNames(this.subject);
		var $it0 = this.subjectClassNames.iterator();
		while( $it0.hasNext() ) {
			var subjectClassName = $it0.next();
			if(subjectClassName == positionInformation.className) return;
		}
		throw new haxe.exception.Exception("This method may only be called by the subject of the signaler.",null,2);
	}
	,removeBubblingTarget: function(value) {
		if(null != this.bubblingTargets) this.bubblingTargets.remove(value);
	}
	,removeNotificationTarget: function(value) {
		if(null != this.notificationTargets) this.notificationTargets.remove(value);
	}
	,unbind: function(listener) {
		this.sentinel.remove(new hsl.haxe._DirectSignaler.RegularBond(listener));
	}
	,unbindAdvanced: function(listener) {
		this.sentinel.remove(new hsl.haxe._DirectSignaler.AdvancedBond(listener));
	}
	,unbindVoid: function(listener) {
		this.sentinel.remove(new hsl.haxe._DirectSignaler.NiladicBond(listener));
	}
	,__class__: hsl.haxe.DirectSignaler
	,__properties__: {get_isListenedTo:"getIsListenedTo"}
}
if(!hsl.haxe._DirectSignaler) hsl.haxe._DirectSignaler = {}
hsl.haxe._DirectSignaler.LinkedBond = $hxClasses["hsl.haxe._DirectSignaler.LinkedBond"] = function() {
	hsl.haxe.Bond.call(this);
	this.destroyed = false;
};
hsl.haxe._DirectSignaler.LinkedBond.__name__ = ["hsl","haxe","_DirectSignaler","LinkedBond"];
hsl.haxe._DirectSignaler.LinkedBond.__super__ = hsl.haxe.Bond;
hsl.haxe._DirectSignaler.LinkedBond.prototype = $extend(hsl.haxe.Bond.prototype,{
	destroyed: null
	,next: null
	,previous: null
	,callListener: function(data,currentTarget,origin,propagationStatus) {
		return 0;
	}
	,determineEquals: function(value) {
		return false;
	}
	,destroy: function() {
		if(false == this.destroyed) {
			this.previous.next = this.next;
			this.next.previous = this.previous;
			this.destroyed = true;
		}
	}
	,unlink: function() {
		if(false == this.destroyed) {
			this.previous.next = this.next;
			this.next.previous = this.previous;
			this.destroyed = true;
		}
	}
	,__class__: hsl.haxe._DirectSignaler.LinkedBond
});
hsl.haxe._DirectSignaler.SentinelBond = $hxClasses["hsl.haxe._DirectSignaler.SentinelBond"] = function() {
	hsl.haxe._DirectSignaler.LinkedBond.call(this);
	this.next = this.previous = this;
};
hsl.haxe._DirectSignaler.SentinelBond.__name__ = ["hsl","haxe","_DirectSignaler","SentinelBond"];
hsl.haxe._DirectSignaler.SentinelBond.__super__ = hsl.haxe._DirectSignaler.LinkedBond;
hsl.haxe._DirectSignaler.SentinelBond.prototype = $extend(hsl.haxe._DirectSignaler.LinkedBond.prototype,{
	isConnected: null
	,add: function(value) {
		value.next = this;
		value.previous = this.previous;
		return this.previous = this.previous.next = value;
	}
	,callListener: function(data,currentTarget,origin,propagationStatus) {
		var node = this.next;
		while(node != this && 1 != propagationStatus) {
			propagationStatus = node.callListener(data,currentTarget,origin,propagationStatus);
			node = node.next;
		}
		return propagationStatus;
	}
	,getIsConnected: function() {
		return this.next != this;
	}
	,remove: function(value) {
		var node = this.next;
		while(node != this) {
			if(node.determineEquals(value)) {
				if(false == node.destroyed) {
					node.previous.next = node.next;
					node.next.previous = node.previous;
					node.destroyed = true;
				}
				break;
			}
			node = node.next;
		}
	}
	,__class__: hsl.haxe._DirectSignaler.SentinelBond
	,__properties__: {get_isConnected:"getIsConnected"}
});
hsl.haxe._DirectSignaler.RegularBond = $hxClasses["hsl.haxe._DirectSignaler.RegularBond"] = function(listener) {
	hsl.haxe._DirectSignaler.LinkedBond.call(this);
	this.listener = listener;
};
hsl.haxe._DirectSignaler.RegularBond.__name__ = ["hsl","haxe","_DirectSignaler","RegularBond"];
hsl.haxe._DirectSignaler.RegularBond.__super__ = hsl.haxe._DirectSignaler.LinkedBond;
hsl.haxe._DirectSignaler.RegularBond.prototype = $extend(hsl.haxe._DirectSignaler.LinkedBond.prototype,{
	listener: null
	,callListener: function(data,currentTarget,origin,propagationStatus) {
		if(false == this.halted) {
			this.listener(data);
			if(this.willDestroyOnUse) if(false == this.destroyed) {
				this.previous.next = this.next;
				this.next.previous = this.previous;
				this.destroyed = true;
			}
		}
		return propagationStatus;
	}
	,determineEquals: function(value) {
		return Std["is"](value,hsl.haxe._DirectSignaler.RegularBond) && Reflect.compareMethods(value.listener,this.listener);
	}
	,__class__: hsl.haxe._DirectSignaler.RegularBond
});
hsl.haxe._DirectSignaler.NiladicBond = $hxClasses["hsl.haxe._DirectSignaler.NiladicBond"] = function(listener) {
	hsl.haxe._DirectSignaler.LinkedBond.call(this);
	this.listener = listener;
};
hsl.haxe._DirectSignaler.NiladicBond.__name__ = ["hsl","haxe","_DirectSignaler","NiladicBond"];
hsl.haxe._DirectSignaler.NiladicBond.__super__ = hsl.haxe._DirectSignaler.LinkedBond;
hsl.haxe._DirectSignaler.NiladicBond.prototype = $extend(hsl.haxe._DirectSignaler.LinkedBond.prototype,{
	listener: null
	,callListener: function(data,currentTarget,origin,propagationStatus) {
		if(false == this.halted) {
			this.listener();
			if(this.willDestroyOnUse) if(false == this.destroyed) {
				this.previous.next = this.next;
				this.next.previous = this.previous;
				this.destroyed = true;
			}
		}
		return propagationStatus;
	}
	,determineEquals: function(value) {
		return Std["is"](value,hsl.haxe._DirectSignaler.NiladicBond) && Reflect.compareMethods(value.listener,this.listener);
	}
	,__class__: hsl.haxe._DirectSignaler.NiladicBond
});
hsl.haxe._DirectSignaler.AdvancedBond = $hxClasses["hsl.haxe._DirectSignaler.AdvancedBond"] = function(listener) {
	hsl.haxe._DirectSignaler.LinkedBond.call(this);
	this.listener = listener;
};
hsl.haxe._DirectSignaler.AdvancedBond.__name__ = ["hsl","haxe","_DirectSignaler","AdvancedBond"];
hsl.haxe._DirectSignaler.AdvancedBond.__super__ = hsl.haxe._DirectSignaler.LinkedBond;
hsl.haxe._DirectSignaler.AdvancedBond.prototype = $extend(hsl.haxe._DirectSignaler.LinkedBond.prototype,{
	listener: null
	,callListener: function(data,currentTarget,origin,propagationStatus) {
		if(this.halted == false) {
			var signal = new hsl.haxe.Signal(data,this,currentTarget,origin);
			this.listener(signal);
			if(this.willDestroyOnUse) if(false == this.destroyed) {
				this.previous.next = this.next;
				this.next.previous = this.previous;
				this.destroyed = true;
			}
			if(signal.immediatePropagationStopped) return 1; else if(signal.propagationStopped) return 2;
		}
		return propagationStatus;
	}
	,determineEquals: function(value) {
		return Std["is"](value,hsl.haxe._DirectSignaler.AdvancedBond) && Reflect.compareMethods(value.listener,this.listener);
	}
	,__class__: hsl.haxe._DirectSignaler.AdvancedBond
});
hsl.haxe._DirectSignaler.PropagationStatus = $hxClasses["hsl.haxe._DirectSignaler.PropagationStatus"] = function() { }
hsl.haxe._DirectSignaler.PropagationStatus.__name__ = ["hsl","haxe","_DirectSignaler","PropagationStatus"];
hsl.haxe._DirectSignaler.PropagationStatus.prototype = {
	__class__: hsl.haxe._DirectSignaler.PropagationStatus
}
hsl.haxe.Signal = $hxClasses["hsl.haxe.Signal"] = function(data,currentBond,currentTarget,origin) {
	this.data = data;
	this.currentBond = currentBond;
	this.currentTarget = currentTarget;
	this.origin = origin;
	this.immediatePropagationStopped = false;
	this.propagationStopped = false;
};
hsl.haxe.Signal.__name__ = ["hsl","haxe","Signal"];
hsl.haxe.Signal.prototype = {
	currentBond: null
	,currentTarget: null
	,data: null
	,data1: null
	,immediatePropagationStopped: null
	,origin: null
	,propagationStopped: null
	,getData: function() {
		return this.data;
	}
	,stopImmediatePropagation: function() {
		this.immediatePropagationStopped = true;
	}
	,stopPropagation: function() {
		this.propagationStopped = true;
	}
	,__class__: hsl.haxe.Signal
	,__properties__: {get_data1:"getData"}
}
var js = js || {}
js.Boot = $hxClasses["js.Boot"] = function() { }
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__string_rec(v,"");
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML += js.Boot.__unhtml(msg) + "<br/>"; else if(typeof(console) != "undefined" && console.log != null) console.log(msg);
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ != null || o.__ename__ != null)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__ != null) {
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
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	} catch( e ) {
		if(cl == null) return false;
	}
	switch(cl) {
	case Int:
		return Math.ceil(o%2147483648.0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return o === true || o === false;
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o == null) return false;
		return o.__enum__ == cl || cl == Class && o.__name__ != null || cl == Enum && o.__ename__ != null;
	}
}
js.Boot.__init = function() {
	js.Lib.isIE = typeof document!='undefined' && document.all != null && typeof window!='undefined' && window.opera == null;
	js.Lib.isOpera = typeof window!='undefined' && window.opera != null;
	Array.prototype.copy = Array.prototype.slice;
	Array.prototype.insert = function(i,x) {
		this.splice(i,0,x);
	};
	Array.prototype.remove = Array.prototype.indexOf?function(obj) {
		var idx = this.indexOf(obj);
		if(idx == -1) return false;
		this.splice(idx,1);
		return true;
	}:function(obj) {
		var i = 0;
		var l = this.length;
		while(i < l) {
			if(this[i] == obj) {
				this.splice(i,1);
				return true;
			}
			i++;
		}
		return false;
	};
	Array.prototype.iterator = function() {
		return { cur : 0, arr : this, hasNext : function() {
			return this.cur < this.arr.length;
		}, next : function() {
			return this.arr[this.cur++];
		}};
	};
	if(String.prototype.cca == null) String.prototype.cca = String.prototype.charCodeAt;
	String.prototype.charCodeAt = function(i) {
		var x = this.cca(i);
		if(x != x) return undefined;
		return x;
	};
	var oldsub = String.prototype.substr;
	String.prototype.substr = function(pos,len) {
		if(pos != null && pos != 0 && len != null && len < 0) return "";
		if(len == null) len = this.length;
		if(pos < 0) {
			pos = this.length + pos;
			if(pos < 0) pos = 0;
		} else if(len < 0) len = this.length + len - pos;
		return oldsub.apply(this,[pos,len]);
	};
	Function.prototype["$bind"] = function(o) {
		var f = function() {
			return f.method.apply(f.scope,arguments);
		};
		f.scope = o;
		f.method = this;
		return f;
	};
}
js.Boot.prototype = {
	__class__: js.Boot
}
js.Lib = $hxClasses["js.Lib"] = function() { }
js.Lib.__name__ = ["js","Lib"];
js.Lib.isIE = null;
js.Lib.isOpera = null;
js.Lib.document = null;
js.Lib.window = null;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib.eval = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
js.Lib.prototype = {
	__class__: js.Lib
}
var org = org || {}
if(!org.tbyrne) org.tbyrne = {}
if(!org.tbyrne.collections) org.tbyrne.collections = {}
org.tbyrne.collections.IndexedList = $hxClasses["org.tbyrne.collections.IndexedList"] = function(list) {
	this.setlist(list);
};
org.tbyrne.collections.IndexedList.__name__ = ["org","tbyrne","collections","IndexedList"];
org.tbyrne.collections.IndexedList.prototype = {
	_indices: null
	,list: null
	,getlist: function() {
		if(this.list == null) {
			this._indices = new time.types.ds.ObjectHash();
			this.setlist(new Array());
		}
		return this.list;
	}
	,setlist: function(value) {
		if(value != null) {
			this._indices = new time.types.ds.ObjectHash();
			var i = 0;
			while(i < value.length) {
				var item = value[i];
				if(this._indices.exists(item)) value.splice(i,1); else {
					this._indices.set(item,i);
					++i;
				}
			}
		} else this._indices = null;
		this.list = value;
		return value;
	}
	,add: function(value) {
		this.getlist();
		if(!this._indices.exists(value)) {
			this._indices.set(value,this.getlist().length);
			this.getlist().push(value);
			return true;
		} else return false;
	}
	,remove: function(value) {
		if(this.getlist() != null && this._indices.exists(value)) {
			var index = this._indices.get(value);
			this._indices.remove(value);
			this.getlist().splice(index,1);
			while(index < this.getlist().length) {
				this._indices.set(this.getlist()[index],index);
				++index;
			}
			return true;
		} else return false;
	}
	,containsItem: function(value) {
		return this.getlist() != null && this._indices.get(value) != null;
	}
	,clear: function() {
		if(this.getlist() != null) {
			this.setlist(null);
			this._indices = null;
		}
	}
	,__class__: org.tbyrne.collections.IndexedList
	,__properties__: {set_list:"setlist",get_list:"getlist"}
}
if(!org.tbyrne.composure) org.tbyrne.composure = {}
if(!org.tbyrne.composure.core) org.tbyrne.composure.core = {}
org.tbyrne.composure.core.ComposeItem = $hxClasses["org.tbyrne.composure.core.ComposeItem"] = function(initTraits) {
	this._traitCollection = new org.tbyrne.composure.traits.TraitCollection();
	this._siblingMarrier = new org.tbyrne.composure.injectors.InjectorMarrier(this,this._traitCollection);
	this._parentMarrier = new org.tbyrne.composure.injectors.InjectorMarrier(this,this._traitCollection);
	this._traitToCast = new time.types.ds.ObjectHash();
	if(initTraits != null) {
		var _g = 0;
		while(_g < initTraits.length) {
			var trait = initTraits[_g];
			++_g;
			this.addTrait(trait);
		}
	}
};
org.tbyrne.composure.core.ComposeItem.__name__ = ["org","tbyrne","composure","core","ComposeItem"];
org.tbyrne.composure.core.ComposeItem.prototype = {
	parentItem: null
	,getParentItem: function() {
		return this._parentItem;
	}
	,setParentItem: function(value) {
		if(this._parentItem != value) {
			if(this._parentItem != null) this.onParentRemove();
			this._parentItem = value;
			if(this._parentItem != null) this.onParentAdd();
		}
		return value;
	}
	,root: null
	,getRoot: function() {
		return this._root;
	}
	,_parentItem: null
	,_root: null
	,_traitCollection: null
	,_siblingMarrier: null
	,_parentMarrier: null
	,_ascInjectors: null
	,_traitToCast: null
	,setRoot: function(root) {
		this._root = root;
	}
	,getTrait: function(TraitType) {
		return this._traitCollection.getTrait(TraitType);
	}
	,getTraits: function(TraitType) {
		return this._traitCollection.getTraits(TraitType);
	}
	,callForTraits: function(func,ifMatches) {
		this._traitCollection.callForTraits(func,ifMatches,this);
	}
	,addTrait: function(trait) {
		this._addTrait(trait);
	}
	,addTraits: function(traits) {
		var _g = 0;
		while(_g < traits.length) {
			var trait = traits[_g];
			++_g;
			this._addTrait(trait);
		}
	}
	,_addTrait: function(trait) {
		var castTrait = null;
		var restrictions;
		var getProxyTrait = Reflect.field(trait,"getProxiedTrait");
		if(getProxyTrait != null) {
			var proxy = trait.getProxiedTrait();
			if(Std["is"](proxy,org.tbyrne.composure.traits.ITrait)) castTrait = (function($this) {
				var $r;
				var $t = proxy;
				if(Std["is"]($t,org.tbyrne.composure.traits.ITrait)) $t; else throw "Class cast error";
				$r = $t;
				return $r;
			}(this));
		}
		if(castTrait == null && Std["is"](trait,org.tbyrne.composure.traits.ITrait)) castTrait = (function($this) {
			var $r;
			var $t = trait;
			if(Std["is"]($t,org.tbyrne.composure.traits.ITrait)) $t; else throw "Class cast error";
			$r = $t;
			return $r;
		}(this));
		if(castTrait != null) {
			castTrait.set_item(this);
			restrictions = castTrait.getRestrictions();
			var _g = 0;
			while(_g < restrictions.length) {
				var restriction = restrictions[_g];
				++_g;
				if(!restriction.allowAddTo(trait,this)) return;
			}
			this._traitToCast.set(trait,castTrait);
		}
		var traits = this._traitCollection.traits.getlist();
		var _g = 0;
		while(_g < traits.length) {
			var otherTrait = traits[_g];
			++_g;
			var otherCast = this._traitToCast.get(otherTrait);
			if(otherCast != null) {
				restrictions = otherCast.getRestrictions();
				var _g1 = 0;
				while(_g1 < restrictions.length) {
					var restriction = restrictions[_g1];
					++_g1;
					if(!restriction.allowNewSibling(otherTrait,this,trait)) return;
				}
			}
		}
		this._traitCollection.addTrait(trait);
		if(this._parentItem != null) this._parentItem.addChildTrait(trait);
		if(castTrait != null) {
			var castInjectors = castTrait.getInjectors();
			var _g = 0;
			while(_g < castInjectors.length) {
				var injector = castInjectors[_g];
				++_g;
				this.addTraitInjector(injector);
			}
		}
	}
	,removeTrait: function(trait) {
		this._removeTrait(trait);
	}
	,removeTraits: function(traits) {
		var _g = 0;
		while(_g < traits.length) {
			var trait = traits[_g];
			++_g;
			this._removeTrait(trait);
		}
	}
	,removeAllTraits: function() {
		var list = this._traitCollection.traits.getlist();
		while(list.length > 0) this._removeTrait(list[0]);
	}
	,_removeTrait: function(trait) {
		var castTrait = this._traitToCast.get(trait);
		if(castTrait != null) {
			castTrait = (function($this) {
				var $r;
				var $t = trait;
				if(Std["is"]($t,org.tbyrne.composure.traits.ITrait)) $t; else throw "Class cast error";
				$r = $t;
				return $r;
			}(this));
			var castInjectors = castTrait.getInjectors();
			var _g = 0;
			while(_g < castInjectors.length) {
				var injector = castInjectors[_g];
				++_g;
				this.removeTraitInjector(injector);
			}
			this._traitToCast.remove(trait);
		}
		this._traitCollection.removeTrait(trait);
		if(this._parentItem != null) this._parentItem.removeChildTrait(trait);
		if(castTrait != null) castTrait.set_item(null);
	}
	,addTraitInjector: function(injector) {
		if(injector.siblings) this._siblingMarrier.addInjector(injector);
		if(injector.ascendants) {
			if(this._ascInjectors == null) this._ascInjectors = new org.tbyrne.collections.IndexedList();
			this._ascInjectors.add(injector);
			if(this._parentItem != null) this._parentItem.addAscendingInjector(injector);
		}
	}
	,removeTraitInjector: function(injector) {
		if(injector.siblings) this._siblingMarrier.removeInjector(injector);
		if(injector.ascendants) {
			this._ascInjectors.remove(injector);
			if(this._parentItem != null) this._parentItem.removeAscendingInjector(injector);
		}
	}
	,onParentAdd: function() {
		var _g = 0, _g1 = this._traitCollection.traits.getlist();
		while(_g < _g1.length) {
			var trait = _g1[_g];
			++_g;
			this._parentItem.addChildTrait(trait);
		}
		if(this._ascInjectors != null) {
			var _g = 0, _g1 = this._ascInjectors.getlist();
			while(_g < _g1.length) {
				var injector = _g1[_g];
				++_g;
				this._parentItem.addAscendingInjector(injector);
			}
		}
	}
	,onParentRemove: function() {
		var _g = 0, _g1 = this._traitCollection.traits.getlist();
		while(_g < _g1.length) {
			var trait = _g1[_g];
			++_g;
			this._parentItem.removeChildTrait(trait);
		}
		if(this._ascInjectors != null) {
			var _g = 0, _g1 = this._ascInjectors.getlist();
			while(_g < _g1.length) {
				var injector = _g1[_g];
				++_g;
				this._parentItem.removeAscendingInjector(injector);
			}
		}
	}
	,addParentInjector: function(injector) {
		this._parentMarrier.addInjector(injector);
	}
	,removeParentInjector: function(injector) {
		this._parentMarrier.removeInjector(injector);
	}
	,__class__: org.tbyrne.composure.core.ComposeItem
	,__properties__: {get_root:"getRoot",set_parentItem:"setParentItem",get_parentItem:"getParentItem"}
}
org.tbyrne.composure.core.ComposeGroup = $hxClasses["org.tbyrne.composure.core.ComposeGroup"] = function(initTraits) {
	this._descendantTraits = new org.tbyrne.composure.traits.TraitCollection();
	this._children = new org.tbyrne.collections.IndexedList();
	this._descInjectors = new org.tbyrne.collections.IndexedList();
	org.tbyrne.composure.core.ComposeItem.call(this,initTraits);
	this._childAscendingMarrier = new org.tbyrne.composure.injectors.InjectorMarrier(this,this._traitCollection);
};
org.tbyrne.composure.core.ComposeGroup.__name__ = ["org","tbyrne","composure","core","ComposeGroup"];
org.tbyrne.composure.core.ComposeGroup.__super__ = org.tbyrne.composure.core.ComposeItem;
org.tbyrne.composure.core.ComposeGroup.prototype = $extend(org.tbyrne.composure.core.ComposeItem.prototype,{
	_descendantTraits: null
	,_children: null
	,_childAscInjectors: null
	,_ignoredChildAscInjectors: null
	,_childAscendingMarrier: null
	,_descInjectors: null
	,_parentDescInjectors: null
	,_ignoredParentDescInjectors: null
	,setRoot: function(game) {
		org.tbyrne.composure.core.ComposeItem.prototype.setRoot.call(this,game);
		var _g = 0, _g1 = this._children.getlist();
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.setRoot(game);
		}
	}
	,addItem: function(item) {
		this._children.add(item);
		item.setParentItem(this);
		var _g = 0, _g1 = this._descInjectors.getlist();
		while(_g < _g1.length) {
			var traitInjector = _g1[_g];
			++_g;
			item.addParentInjector(traitInjector);
		}
		if(this._parentDescInjectors != null) {
			var _g = 0, _g1 = this._parentDescInjectors.getlist();
			while(_g < _g1.length) {
				var traitInjector = _g1[_g];
				++_g;
				item.addParentInjector(traitInjector);
			}
		}
		item.setRoot(this._root);
	}
	,removeItem: function(item) {
		this._children.remove(item);
		item.setParentItem(null);
		var _g = 0, _g1 = this._descInjectors.getlist();
		while(_g < _g1.length) {
			var traitInjector = _g1[_g];
			++_g;
			item.removeParentInjector(traitInjector);
		}
		if(this._parentDescInjectors != null) {
			var _g = 0, _g1 = this._parentDescInjectors.getlist();
			while(_g < _g1.length) {
				var traitInjector = _g1[_g];
				++_g;
				item.removeParentInjector(traitInjector);
			}
		}
		item.setRoot(null);
	}
	,removeAllItem: function() {
		while(this._children.getlist().length > 0) this.removeItem(this._children.getlist()[0]);
	}
	,addChildTrait: function(trait) {
		this._descendantTraits.addTrait(trait);
		if(this._parentItem != null) this._parentItem.addChildTrait(trait);
	}
	,removeChildTrait: function(trait) {
		this._descendantTraits.removeTrait(trait);
		if(this._parentItem != null) this._parentItem.removeChildTrait(trait);
	}
	,addTrait: function(trait) {
		org.tbyrne.composure.core.ComposeItem.prototype.addTrait.call(this,trait);
		this.checkForNewlyIgnoredInjectors();
	}
	,addTraits: function(traits) {
		org.tbyrne.composure.core.ComposeItem.prototype.addTraits.call(this,traits);
		this.checkForNewlyIgnoredInjectors();
	}
	,removeTrait: function(trait) {
		org.tbyrne.composure.core.ComposeItem.prototype.removeTrait.call(this,trait);
		this.checkForNewlyUnignoredInjectors();
	}
	,removeTraits: function(traits) {
		org.tbyrne.composure.core.ComposeItem.prototype.removeTraits.call(this,traits);
		this.checkForNewlyUnignoredInjectors();
	}
	,removeAllTraits: function() {
		org.tbyrne.composure.core.ComposeItem.prototype.removeAllTraits.call(this);
		this.checkForNewlyUnignoredInjectors();
	}
	,addTraitInjector: function(injector) {
		org.tbyrne.composure.core.ComposeItem.prototype.addTraitInjector.call(this,injector);
		if(injector.descendants) {
			this._descInjectors.add(injector);
			var _g = 0, _g1 = this._children.getlist();
			while(_g < _g1.length) {
				var child = _g1[_g];
				++_g;
				child.addParentInjector(injector);
			}
		}
	}
	,removeTraitInjector: function(injector) {
		org.tbyrne.composure.core.ComposeItem.prototype.removeTraitInjector.call(this,injector);
		if(this._descInjectors.containsItem(injector)) {
			this._descInjectors.remove(injector);
			var _g = 0, _g1 = this._children.getlist();
			while(_g < _g1.length) {
				var child = _g1[_g];
				++_g;
				child.removeParentInjector(injector);
			}
		}
	}
	,getDescTrait: function(matchType) {
		return this._descendantTraits.getTrait(matchType);
	}
	,getDescTraits: function(ifMatches) {
		return this._descendantTraits.getTraits(ifMatches);
	}
	,callForDescTraits: function(func,ifMatches) {
		this._descendantTraits.callForTraits(func,ifMatches,this);
	}
	,onParentAdd: function() {
		org.tbyrne.composure.core.ComposeItem.prototype.onParentAdd.call(this);
		var _g = 0, _g1 = this._descendantTraits.traits.getlist();
		while(_g < _g1.length) {
			var trait = _g1[_g];
			++_g;
			this._parentItem.addChildTrait(trait);
		}
		if(this._childAscInjectors != null) {
			var _g = 0, _g1 = this._childAscInjectors.getlist();
			while(_g < _g1.length) {
				var injector = _g1[_g];
				++_g;
				this._parentItem.addAscendingInjector(injector);
			}
		}
	}
	,onParentRemove: function() {
		org.tbyrne.composure.core.ComposeItem.prototype.onParentRemove.call(this);
		var _g = 0, _g1 = this._descendantTraits.traits.getlist();
		while(_g < _g1.length) {
			var trait = _g1[_g];
			++_g;
			this._parentItem.removeChildTrait(trait);
		}
		if(this._childAscInjectors != null) {
			var _g = 0, _g1 = this._childAscInjectors.getlist();
			while(_g < _g1.length) {
				var injector = _g1[_g];
				++_g;
				this._parentItem.removeAscendingInjector(injector);
			}
		}
	}
	,addAscendingInjector: function(injector) {
		this._childAscendingMarrier.addInjector(injector);
		if(injector.shouldAscend(this)) this._addAscendingInjector(injector); else {
			if(this._ignoredChildAscInjectors == null) this._ignoredChildAscInjectors = new org.tbyrne.collections.IndexedList();
			this._ignoredChildAscInjectors.add(injector);
		}
	}
	,_addAscendingInjector: function(injector) {
		if(this._childAscInjectors == null) this._childAscInjectors = new org.tbyrne.collections.IndexedList();
		this._childAscInjectors.add(injector);
		if(this._parentItem != null) this._parentItem.addAscendingInjector(injector);
	}
	,removeAscendingInjector: function(injector) {
		this._childAscendingMarrier.removeInjector(injector);
		if(this._childAscInjectors != null && this._childAscInjectors.containsItem(injector)) this._removeAscendingInjector(injector); else this._ignoredChildAscInjectors.remove(injector);
	}
	,_removeAscendingInjector: function(injector) {
		this._childAscInjectors.remove(injector);
		if(this._parentItem != null) this._parentItem.removeAscendingInjector(injector);
	}
	,addParentInjector: function(injector) {
		org.tbyrne.composure.core.ComposeItem.prototype.addParentInjector.call(this,injector);
		if(injector.shouldDescend(this)) this.addDescParentInjector(injector); else {
			if(this._ignoredParentDescInjectors == null) this._ignoredParentDescInjectors = new org.tbyrne.collections.IndexedList();
			this._ignoredParentDescInjectors.add(injector);
		}
	}
	,removeParentInjector: function(injector) {
		org.tbyrne.composure.core.ComposeItem.prototype.removeParentInjector.call(this,injector);
		if(this._parentDescInjectors != null && this._parentDescInjectors.containsItem(injector)) this.removeDescParentInjector(injector); else if(this._ignoredParentDescInjectors != null) this._ignoredParentDescInjectors.remove(injector);
	}
	,checkForNewlyIgnoredInjectors: function() {
		var i = 0;
		if(this._parentDescInjectors != null) while(i < this._parentDescInjectors.getlist().length) {
			var injector = this._parentDescInjectors.getlist()[i];
			if(!injector.shouldDescend(this)) {
				this.removeDescParentInjector(injector);
				if(this._ignoredParentDescInjectors == null) this._ignoredParentDescInjectors = new org.tbyrne.collections.IndexedList();
				this._ignoredParentDescInjectors.add(injector);
			} else ++i;
		}
		if(this._childAscInjectors != null) {
			i = 0;
			while(i < this._childAscInjectors.getlist().length) {
				var injector = this._childAscInjectors.getlist()[i];
				if(!injector.shouldAscend(this)) {
					this._removeAscendingInjector(injector);
					if(this._ignoredChildAscInjectors == null) this._ignoredChildAscInjectors = new org.tbyrne.collections.IndexedList();
					this._ignoredChildAscInjectors.add(injector);
				} else ++i;
			}
		}
	}
	,checkForNewlyUnignoredInjectors: function() {
		var i = 0;
		if(this._ignoredParentDescInjectors != null) while(i < this._ignoredParentDescInjectors.getlist().length) {
			var injector = this._ignoredParentDescInjectors.getlist()[i];
			if(injector.shouldDescend(this)) {
				this.addDescParentInjector(injector);
				this._ignoredParentDescInjectors.remove(injector);
			} else ++i;
		}
		if(this._ignoredChildAscInjectors != null) {
			i = 0;
			while(i < this._ignoredChildAscInjectors.getlist().length) {
				var injector = this._ignoredChildAscInjectors.getlist()[i];
				if(injector.shouldAscend(this)) {
					this._addAscendingInjector(injector);
					this._ignoredChildAscInjectors.remove(injector);
				} else ++i;
			}
		}
	}
	,addDescParentInjector: function(injector) {
		if(this._parentDescInjectors == null) this._parentDescInjectors = new org.tbyrne.collections.IndexedList();
		this._parentDescInjectors.add(injector);
		var _g = 0, _g1 = this._children.getlist();
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.addParentInjector(injector);
		}
	}
	,removeDescParentInjector: function(injector) {
		this._parentDescInjectors.remove(injector);
		var _g = 0, _g1 = this._children.getlist();
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			child.removeParentInjector(injector);
		}
	}
	,__class__: org.tbyrne.composure.core.ComposeGroup
});
org.tbyrne.composure.core.ComposeRoot = $hxClasses["org.tbyrne.composure.core.ComposeRoot"] = function(initTraits) {
	org.tbyrne.composure.core.ComposeGroup.call(this,initTraits);
	this.setRoot(this);
};
org.tbyrne.composure.core.ComposeRoot.__name__ = ["org","tbyrne","composure","core","ComposeRoot"];
org.tbyrne.composure.core.ComposeRoot.__super__ = org.tbyrne.composure.core.ComposeGroup;
org.tbyrne.composure.core.ComposeRoot.prototype = $extend(org.tbyrne.composure.core.ComposeGroup.prototype,{
	__class__: org.tbyrne.composure.core.ComposeRoot
});
if(!org.tbyrne.composure.injectors) org.tbyrne.composure.injectors = {}
org.tbyrne.composure.injectors.IInjector = $hxClasses["org.tbyrne.composure.injectors.IInjector"] = function() { }
org.tbyrne.composure.injectors.IInjector.__name__ = ["org","tbyrne","composure","injectors","IInjector"];
org.tbyrne.composure.injectors.IInjector.prototype = {
	siblings: null
	,ascendants: null
	,descendants: null
	,acceptOwnerTrait: null
	,ownerTrait: null
	,injectorAdded: null
	,injectorRemoved: null
	,shouldDescend: null
	,shouldAscend: null
	,isInterestedIn: null
	,__class__: org.tbyrne.composure.injectors.IInjector
}
org.tbyrne.composure.injectors.AbstractInjector = $hxClasses["org.tbyrne.composure.injectors.AbstractInjector"] = function(interestedTraitType,addHandler,removeHandler,siblings,descendants,ascendants) {
	if(ascendants == null) ascendants = false;
	if(descendants == null) descendants = false;
	if(siblings == null) siblings = true;
	this.addHandler = addHandler;
	this.removeHandler = removeHandler;
	this.siblings = siblings;
	this.descendants = descendants;
	this.ascendants = ascendants;
	this.interestedTraitType = interestedTraitType;
	this._addedTraits = new org.tbyrne.collections.IndexedList();
	this.passThroughInjector = false;
	this.passThroughItem = false;
};
org.tbyrne.composure.injectors.AbstractInjector.__name__ = ["org","tbyrne","composure","injectors","AbstractInjector"];
org.tbyrne.composure.injectors.AbstractInjector.__interfaces__ = [org.tbyrne.composure.injectors.IInjector];
org.tbyrne.composure.injectors.AbstractInjector.prototype = {
	addHandler: null
	,removeHandler: null
	,siblings: null
	,descendants: null
	,ascendants: null
	,acceptOwnerTrait: null
	,interestedTraitType: null
	,ownerTrait: null
	,passThroughInjector: null
	,passThroughItem: null
	,_addedTraits: null
	,injectorAdded: function(trait,item) {
		if(this._addedTraits.add(trait) && this.addHandler != null) {
			if(this.passThroughInjector) {
				if(this.passThroughItem) this.addHandler(this,trait,item); else this.addHandler(this,trait);
			} else if(this.passThroughItem) this.addHandler(trait,item); else this.addHandler(trait);
		}
	}
	,injectorRemoved: function(trait,item) {
		if(this._addedTraits.remove(trait) && this.removeHandler != null) {
			if(this.passThroughInjector) {
				if(this.passThroughItem) this.removeHandler(this,trait,item); else this.removeHandler(this,trait);
			} else if(this.passThroughItem) this.removeHandler(trait,item); else this.removeHandler(trait);
		}
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
	,itemMatchesAny: function(item,traitTypes) {
		var _g = 0;
		while(_g < traitTypes.length) {
			var traitType = traitTypes[_g];
			++_g;
			if(item.getTrait(traitType) != null) return true;
		}
		return false;
	}
	,shouldDescend: function(item) {
		return true;
	}
	,shouldAscend: function(item) {
		return true;
	}
	,isInterestedIn: function(trait) {
		return Std["is"](trait,this.interestedTraitType);
	}
	,__class__: org.tbyrne.composure.injectors.AbstractInjector
}
org.tbyrne.composure.injectors.Injector = $hxClasses["org.tbyrne.composure.injectors.Injector"] = function(interestedTraitType,addHandler,removeHandler,siblings,descendants,ascendants) {
	if(ascendants == null) ascendants = false;
	if(descendants == null) descendants = false;
	if(siblings == null) siblings = true;
	org.tbyrne.composure.injectors.AbstractInjector.call(this,interestedTraitType,addHandler,removeHandler,siblings,descendants,ascendants);
	this.maxMatches = -1;
};
org.tbyrne.composure.injectors.Injector.__name__ = ["org","tbyrne","composure","injectors","Injector"];
org.tbyrne.composure.injectors.Injector.__super__ = org.tbyrne.composure.injectors.AbstractInjector;
org.tbyrne.composure.injectors.Injector.prototype = $extend(org.tbyrne.composure.injectors.AbstractInjector.prototype,{
	unlessHasTraits: null
	,additionalTraits: null
	,stopDescendingAt: null
	,stopAscendingAt: null
	,matchProps: null
	,maxMatches: null
	,shouldDescend: function(item) {
		if(this.stopDescendingAt != null) return !this.stopDescendingAt(item,this); else return true;
	}
	,shouldAscend: function(item) {
		if(this.stopAscendingAt != null) return !this.stopAscendingAt(item,this); else return true;
	}
	,isInterestedIn: function(trait) {
		var item = null;
		var getProxyTrait = Reflect.field(trait,"getProxiedTrait");
		if(getProxyTrait != null) {
			var proxy = trait.getProxiedTrait();
			if(Std["is"](proxy,org.tbyrne.composure.traits.ITrait)) item = ((function($this) {
				var $r;
				var $t = proxy;
				if(Std["is"]($t,org.tbyrne.composure.traits.ITrait)) $t; else throw "Class cast error";
				$r = $t;
				return $r;
			}(this))).item;
		}
		if(item == null && Std["is"](trait,org.tbyrne.composure.traits.ITrait)) item = trait.item; else item = null;
		return org.tbyrne.composure.injectors.AbstractInjector.prototype.isInterestedIn.call(this,trait) && (item == null || (this.additionalTraits == null || this.itemMatchesAll(item,this.additionalTraits)) && (this.unlessHasTraits == null || !this.itemMatchesAll(item,this.unlessHasTraits)) && (this.matchProps == null || this.propsMatch(trait,this.matchProps))) && (this.maxMatches == -1 || this._addedTraits.getlist().length < this.maxMatches);
	}
	,propsMatch: function(trait,props) {
		var $it0 = props.keys();
		while( $it0.hasNext() ) {
			var i = $it0.next();
			if(Reflect.field(trait,i) != props.get(i)) return false;
		}
		return true;
	}
	,__class__: org.tbyrne.composure.injectors.Injector
});
org.tbyrne.composure.injectors.InjectorMarrier = $hxClasses["org.tbyrne.composure.injectors.InjectorMarrier"] = function(item,traits) {
	this._traitInjectors = new org.tbyrne.collections.IndexedList();
	this._injectorLookup = new time.types.ds.ObjectHash();
	this._traitLookup = new time.types.ds.ObjectHash();
	this._item = item;
	this.set_traits(traits);
};
org.tbyrne.composure.injectors.InjectorMarrier.__name__ = ["org","tbyrne","composure","injectors","InjectorMarrier"];
org.tbyrne.composure.injectors.InjectorMarrier.prototype = {
	traits: null
	,get_traits: function() {
		return this._traits;
	}
	,set_traits: function(value) {
		if(this._traits != value) {
			if(this._traits != null) {
				this._traits.getTraitAdded().unbind(this.onTraitAdded.$bind(this));
				this._traits.getTraitRemoved().unbind(this.onTraitRemoved.$bind(this));
			}
			this._traits = value;
			if(this._traits != null) {
				this._traits.getTraitAdded().bind(this.onTraitAdded.$bind(this));
				this._traits.getTraitRemoved().bind(this.onTraitRemoved.$bind(this));
			}
		}
		return value;
	}
	,traitInjectors: null
	,getTraitInjectors: function() {
		return this._traitInjectors;
	}
	,_traits: null
	,_traitInjectors: null
	,_injectorLookup: null
	,_traitLookup: null
	,_item: null
	,addInjector: function(traitInjector) {
		if(this._traitInjectors.add(traitInjector)) {
			var _g = 0, _g1 = this._traits.traits.getlist();
			while(_g < _g1.length) {
				var trait = _g1[_g];
				++_g;
				this.compareTrait(trait,traitInjector);
			}
		}
	}
	,removeInjector: function(traitInjector) {
		if(this._traitInjectors.remove(traitInjector)) {
			var traits = this._injectorLookup.get(traitInjector);
			if(traits != null) {
				var _g = 0, _g1 = traits.getlist();
				while(_g < _g1.length) {
					var trait = _g1[_g];
					++_g;
					traitInjector.injectorRemoved(trait,this._item);
					var traitLookup = this._traitLookup.get(trait);
					traitLookup.remove(traitInjector);
				}
				traits.clear();
				this._injectorLookup.remove(traitInjector);
			}
		}
	}
	,onTraitAdded: function(trait) {
		var _g = 0, _g1 = this._traitInjectors.getlist();
		while(_g < _g1.length) {
			var traitInjector = _g1[_g];
			++_g;
			this.compareTrait(trait,traitInjector);
		}
	}
	,onTraitRemoved: function(trait) {
		var injectors = this._traitLookup.get(trait);
		if(injectors != null) {
			var _g = 0, _g1 = injectors.getlist();
			while(_g < _g1.length) {
				var traitInjector = _g1[_g];
				++_g;
				traitInjector.injectorRemoved(trait,this._item);
				var injectorLookup = this._injectorLookup.get(traitInjector);
				injectorLookup.remove(trait);
			}
			injectors.clear();
			this._traitLookup.remove(trait);
		}
	}
	,compareTrait: function(trait,traitInjector) {
		if((trait != traitInjector.ownerTrait || traitInjector.acceptOwnerTrait) && traitInjector.isInterestedIn(trait)) {
			var injectorList = this._injectorLookup.get(traitInjector);
			if(injectorList == null) {
				injectorList = new org.tbyrne.collections.IndexedList();
				this._injectorLookup.set(traitInjector,injectorList);
			}
			injectorList.add(trait);
			var traitList = this._traitLookup.get(trait);
			if(traitList == null) {
				traitList = new org.tbyrne.collections.IndexedList();
				this._traitLookup.set(trait,traitList);
			}
			traitList.add(traitInjector);
			traitInjector.injectorAdded(trait,this._item);
		}
	}
	,__class__: org.tbyrne.composure.injectors.InjectorMarrier
	,__properties__: {get_traitInjectors:"getTraitInjectors",set_traits:"set_traits",get_traits:"get_traits"}
}
org.tbyrne.composure.injectors.PropInjector = $hxClasses["org.tbyrne.composure.injectors.PropInjector"] = function(interestedTraitType,subject,prop,siblings,descendants,ascendants,writeOnly) {
	if(writeOnly == null) writeOnly = false;
	if(ascendants == null) ascendants = false;
	if(descendants == null) descendants = false;
	if(siblings == null) siblings = true;
	this.subject = subject;
	this.prop = prop;
	this.writeOnly = writeOnly;
	org.tbyrne.composure.injectors.Injector.call(this,interestedTraitType,this.addProp.$bind(this),this.removeProp.$bind(this),siblings,descendants,ascendants);
};
org.tbyrne.composure.injectors.PropInjector.__name__ = ["org","tbyrne","composure","injectors","PropInjector"];
org.tbyrne.composure.injectors.PropInjector.__super__ = org.tbyrne.composure.injectors.Injector;
org.tbyrne.composure.injectors.PropInjector.prototype = $extend(org.tbyrne.composure.injectors.Injector.prototype,{
	subject: null
	,prop: null
	,writeOnly: null
	,isSet: null
	,setTrait: null
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
	,removeProp: function(trait) {
		if(this.isSet && trait == this.setTrait) {
			this.setTrait = null;
			if(Reflect.getProperty(this.subject,this.prop) != null) {
				this.isSet = true;
				return;
			} else {
				this.isSet = false;
				Reflect.setProperty(this.subject,this.prop,null);
			}
		}
	}
	,__class__: org.tbyrne.composure.injectors.PropInjector
});
if(!org.tbyrne.composure.macro) org.tbyrne.composure.macro = {}
org.tbyrne.composure.macro.InjectorMacro = $hxClasses["org.tbyrne.composure.macro.InjectorMacro"] = function() { }
org.tbyrne.composure.macro.InjectorMacro.__name__ = ["org","tbyrne","composure","macro","InjectorMacro"];
org.tbyrne.composure.macro.InjectorMacro.prototype = {
	__class__: org.tbyrne.composure.macro.InjectorMacro
}
org.tbyrne.composure.macro.InjectorAccess = $hxClasses["org.tbyrne.composure.macro.InjectorAccess"] = function() {
	this.siblings = true;
	this.descendants = false;
	this.ascendants = false;
};
org.tbyrne.composure.macro.InjectorAccess.__name__ = ["org","tbyrne","composure","macro","InjectorAccess"];
org.tbyrne.composure.macro.InjectorAccess.prototype = {
	siblings: null
	,descendants: null
	,ascendants: null
	,__class__: org.tbyrne.composure.macro.InjectorAccess
}
if(!org.tbyrne.composure.restrictions) org.tbyrne.composure.restrictions = {}
org.tbyrne.composure.restrictions.ITraitRestriction = $hxClasses["org.tbyrne.composure.restrictions.ITraitRestriction"] = function() { }
org.tbyrne.composure.restrictions.ITraitRestriction.__name__ = ["org","tbyrne","composure","restrictions","ITraitRestriction"];
org.tbyrne.composure.restrictions.ITraitRestriction.prototype = {
	allowNewSibling: null
	,allowAddTo: null
	,__class__: org.tbyrne.composure.restrictions.ITraitRestriction
}
org.tbyrne.composure.restrictions.SingularTraitRestriction = $hxClasses["org.tbyrne.composure.restrictions.SingularTraitRestriction"] = function(restrictSubclasses) {
	this.restrictSubclasses = restrictSubclasses;
};
org.tbyrne.composure.restrictions.SingularTraitRestriction.__name__ = ["org","tbyrne","composure","restrictions","SingularTraitRestriction"];
org.tbyrne.composure.restrictions.SingularTraitRestriction.__interfaces__ = [org.tbyrne.composure.restrictions.ITraitRestriction];
org.tbyrne.composure.restrictions.SingularTraitRestriction.getInheritedRestrictor = function() {
	if(org.tbyrne.composure.restrictions.SingularTraitRestriction._inheritedRestrictor == null) org.tbyrne.composure.restrictions.SingularTraitRestriction._inheritedRestrictor = new org.tbyrne.composure.restrictions.SingularTraitRestriction(true);
	return org.tbyrne.composure.restrictions.SingularTraitRestriction._inheritedRestrictor;
}
org.tbyrne.composure.restrictions.SingularTraitRestriction.getNonInheritedRestrictor = function() {
	if(org.tbyrne.composure.restrictions.SingularTraitRestriction._nonInheritedRestrictor == null) org.tbyrne.composure.restrictions.SingularTraitRestriction._nonInheritedRestrictor = new org.tbyrne.composure.restrictions.SingularTraitRestriction(false);
	return org.tbyrne.composure.restrictions.SingularTraitRestriction._nonInheritedRestrictor;
}
org.tbyrne.composure.restrictions.SingularTraitRestriction._inheritedRestrictor = null;
org.tbyrne.composure.restrictions.SingularTraitRestriction._nonInheritedRestrictor = null;
org.tbyrne.composure.restrictions.SingularTraitRestriction.prototype = {
	restrictSubclasses: null
	,lastOwner: null
	,lastClass: null
	,allowNewSibling: function(owner,item,newTrait) {
		this.validateForOwner(owner);
		if(this.restrictSubclasses) return !Std["is"](newTrait,this.lastClass); else return Type.getClass(newTrait) != this.lastClass;
	}
	,allowAddTo: function(owner,item) {
		this.validateForOwner(owner);
		var traits = item.getTraits(this.lastClass);
		if(this.restrictSubclasses) return false; else {
			var _g = 0;
			while(_g < traits.length) {
				var trait = traits[_g];
				++_g;
				if(Type.getClass(trait) == this.lastClass) return false;
			}
		}
		return true;
	}
	,validateForOwner: function(owner) {
		if(this.lastOwner != owner) {
			this.lastOwner = owner;
			this.lastClass = Type.getClass(owner);
		}
	}
	,__class__: org.tbyrne.composure.restrictions.SingularTraitRestriction
}
if(!org.tbyrne.composure.traits) org.tbyrne.composure.traits = {}
org.tbyrne.composure.traits.ITrait = $hxClasses["org.tbyrne.composure.traits.ITrait"] = function() { }
org.tbyrne.composure.traits.ITrait.__name__ = ["org","tbyrne","composure","traits","ITrait"];
org.tbyrne.composure.traits.ITrait.prototype = {
	item: null
	,group: null
	,getInjectors: null
	,getRestrictions: null
	,__class__: org.tbyrne.composure.traits.ITrait
	,__properties__: {set_item:"set_item"}
}
org.tbyrne.composure.traits.AbstractTrait = $hxClasses["org.tbyrne.composure.traits.AbstractTrait"] = function(ownerTrait) {
	this._groupOnly = false;
	if(ownerTrait != null) this._ownerTrait = ownerTrait; else this._ownerTrait = this;
};
org.tbyrne.composure.traits.AbstractTrait.__name__ = ["org","tbyrne","composure","traits","AbstractTrait"];
org.tbyrne.composure.traits.AbstractTrait.__interfaces__ = [org.tbyrne.composure.traits.ITrait];
org.tbyrne.composure.traits.AbstractTrait.prototype = {
	group: null
	,item: null
	,set_item: function(value) {
		if(this.item != value) {
			if(this.item != null) {
				if(this._siblingTraits != null) {
					var _g = 0, _g1 = this._siblingTraits.getlist();
					while(_g < _g1.length) {
						var trait = _g1[_g];
						++_g;
						this.item.removeTrait(trait);
					}
				}
				if(this.group != null && this._childItems != null) {
					var _g = 0, _g1 = this._childItems.getlist();
					while(_g < _g1.length) {
						var trait = _g1[_g];
						++_g;
						this.group.removeItem(trait);
					}
				}
				this.onItemRemove();
			}
			this.item = value;
			this.group = null;
			if(this.item != null) {
				if(Std["is"](value,org.tbyrne.composure.core.ComposeGroup)) {
					this.group = (function($this) {
						var $r;
						var $t = value;
						if(Std["is"]($t,org.tbyrne.composure.core.ComposeGroup)) $t; else throw "Class cast error";
						$r = $t;
						return $r;
					}(this));
					if(this._childItems != null) {
						var _g = 0, _g1 = this._childItems.getlist();
						while(_g < _g1.length) {
							var child = _g1[_g];
							++_g;
							this.group.addItem(child);
						}
					}
				}
				this.onItemAdd();
				if(this._siblingTraits != null) {
					var _g = 0, _g1 = this._siblingTraits.getlist();
					while(_g < _g1.length) {
						var trait = _g1[_g];
						++_g;
						this.item.addTrait(trait);
					}
				}
			}
		}
		return value;
	}
	,_injectors: null
	,_restrictions: null
	,_siblingTraits: null
	,_childItems: null
	,_groupOnly: null
	,_ownerTrait: null
	,onItemRemove: function() {
	}
	,onItemAdd: function() {
	}
	,getInjectors: function() {
		if(this._injectors == null) this._injectors = new org.tbyrne.collections.IndexedList();
		return this._injectors.getlist();
	}
	,getRestrictions: function() {
		if(this._restrictions == null) this._restrictions = new org.tbyrne.collections.IndexedList();
		return this._restrictions.getlist();
	}
	,addSiblingTrait: function(trait) {
		if(this._siblingTraits == null) this._siblingTraits = new org.tbyrne.collections.IndexedList();
		if(this._siblingTraits.add(trait)) {
			if(this.item != null) this.item.addTrait(trait);
		}
	}
	,removeSiblingTrait: function(trait) {
		if(this._siblingTraits != null && this._siblingTraits.remove(trait)) {
			if(this.item != null) this.item.removeTrait(trait);
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
	,addChildItem: function(child) {
		if(this._childItems == null) this._childItems = new org.tbyrne.collections.IndexedList();
		if(this._childItems.add(child)) {
			if(this.group != null) this.group.addItem(child);
		}
	}
	,removeChildItem: function(child) {
		if(this._childItems != null && this._childItems.remove(child)) {
			if(this.group != null) this.group.removeItem(child);
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
	,addInjector: function(injector) {
		if(this._injectors == null) this._injectors = new org.tbyrne.collections.IndexedList();
		if(this._injectors.add(injector)) injector.ownerTrait = this._ownerTrait;
	}
	,removeInjector: function(injector) {
		if(this._injectors != null && this._injectors.remove(injector)) injector.ownerTrait = null;
	}
	,addRestriction: function(restriction) {
		if(this._restrictions == null) this._restrictions = new org.tbyrne.collections.IndexedList();
		if(this._restrictions.add(restriction)) {
		}
	}
	,removeRestriction: function(restriction) {
		if(this._injectors != null && this._restrictions.remove(restriction)) {
		}
	}
	,__class__: org.tbyrne.composure.traits.AbstractTrait
	,__properties__: {set_item:"set_item"}
}
org.tbyrne.composure.traits.TraitCollection = $hxClasses["org.tbyrne.composure.traits.TraitCollection"] = function() {
	this._traitTypeCache = new Hash();
	this.traits = new org.tbyrne.collections.IndexedList();
};
org.tbyrne.composure.traits.TraitCollection.__name__ = ["org","tbyrne","composure","traits","TraitCollection"];
org.tbyrne.composure.traits.TraitCollection.prototype = {
	traitAdded: null
	,getTraitAdded: function() {
		if(this._traitAdded == null) this._traitAdded = new hsl.haxe.DirectSignaler(this);
		return this._traitAdded;
	}
	,traitRemoved: null
	,getTraitRemoved: function() {
		if(this._traitRemoved == null) this._traitRemoved = new hsl.haxe.DirectSignaler(this);
		return this._traitRemoved;
	}
	,_traitRemoved: null
	,_traitAdded: null
	,_traitTypeCache: null
	,traits: null
	,getTrait: function(TraitType) {
		if(TraitType == null) {
			haxe.Log.trace("TraitCollection.getTrait must be supplied an ITrait class to match",{ fileName : "TraitCollection.hx", lineNumber : 44, className : "org.tbyrne.composure.traits.TraitCollection", methodName : "getTrait"});
			return null;
		} else {
			var cache = this.validateCache(TraitType);
			if(cache != null) return cache.getTrait; else return null;
		}
	}
	,getTraits: function(TraitType) {
		var cache = this.validateCache(TraitType);
		if(cache != null) return cache.getTraits; else return null;
	}
	,validateCache: function(matchType) {
		var typeName = Type.getClassName(matchType);
		var cache;
		cache = this._traitTypeCache.get(typeName);
		var invalid;
		if(cache != null) invalid = cache.invalid; else {
			cache = new org.tbyrne.composure.traits._TraitCollection.TraitTypeCache();
			this._traitTypeCache.set(typeName,cache);
			invalid = this.traits;
		}
		if(!cache.methodCachesSafe) {
			var _g = 0, _g1 = invalid.getlist();
			while(_g < _g1.length) {
				var trait = _g1[_g];
				++_g;
				if(Std["is"](trait,matchType)) cache.matched.add(trait);
			}
			cache.invalid.clear();
			cache.methodCachesSafe = true;
			cache.getTraits = cache.matched.getlist();
			cache.getTrait = cache.getTraits[0];
		}
		return cache;
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
			var _g = 0, _g1 = cache.matched.getlist();
			while(_g < _g1.length) {
				var trait = _g1[_g];
				++_g;
				realParams[1] = trait;
				func.apply(thisObj,realParams);
			}
			invalid = cache.invalid;
		} else {
			if(matchingType) {
				cache = new org.tbyrne.composure.traits._TraitCollection.TraitTypeCache();
				this._traitTypeCache.set(typeName,cache);
			}
			invalid = this.traits;
		}
		if(matchingType) {
			if(cache != null && cache.methodCachesSafe == false) {
				var _g = 0, _g1 = invalid.getlist();
				while(_g < _g1.length) {
					var trait = _g1[_g];
					++_g;
					if(Std["is"](trait,matchType)) {
						realParams[1] = trait;
						if(matchingType) cache.matched.add(trait);
						if(collectReturns != null) collectReturns.push(func.apply(thisObj,realParams)); else func.apply(thisObj,realParams);
					}
				}
				cache.invalid.clear();
				cache.methodCachesSafe = true;
				cache.getTraits = cache.matched.getlist();
				cache.getTrait = cache.getTraits[0];
			}
		} else {
			var _g = 0, _g1 = invalid.getlist();
			while(_g < _g1.length) {
				var trait = _g1[_g];
				++_g;
				realParams[1] = trait;
				if(collectReturns != null) collectReturns.push(func.apply(thisObj,realParams)); else func.apply(thisObj,realParams);
			}
		}
	}
	,addTrait: function(trait) {
		this.traits.add(trait);
		var $it0 = this._traitTypeCache.iterator();
		while( $it0.hasNext() ) {
			var cache = $it0.next();
			cache.invalid.add(trait);
			cache.methodCachesSafe = false;
		}
		if(this._traitAdded != null) this._traitAdded.dispatch(trait,null,{ fileName : "TraitCollection.hx", lineNumber : 165, className : "org.tbyrne.composure.traits.TraitCollection", methodName : "addTrait"});
	}
	,removeTrait: function(trait) {
		this.traits.remove(trait);
		var $it0 = this._traitTypeCache.iterator();
		while( $it0.hasNext() ) {
			var cache = $it0.next();
			cache.matched.remove(trait);
			cache.invalid.remove(trait);
			cache.methodCachesSafe = false;
		}
		if(this._traitRemoved != null) this._traitRemoved.dispatch(trait,null,{ fileName : "TraitCollection.hx", lineNumber : 176, className : "org.tbyrne.composure.traits.TraitCollection", methodName : "removeTrait"});
	}
	,__class__: org.tbyrne.composure.traits.TraitCollection
	,__properties__: {get_traitRemoved:"getTraitRemoved",get_traitAdded:"getTraitAdded"}
}
if(!org.tbyrne.composure.traits._TraitCollection) org.tbyrne.composure.traits._TraitCollection = {}
org.tbyrne.composure.traits._TraitCollection.TraitTypeCache = $hxClasses["org.tbyrne.composure.traits._TraitCollection.TraitTypeCache"] = function() {
	this.matched = new org.tbyrne.collections.IndexedList();
	this.invalid = new org.tbyrne.collections.IndexedList();
};
org.tbyrne.composure.traits._TraitCollection.TraitTypeCache.__name__ = ["org","tbyrne","composure","traits","_TraitCollection","TraitTypeCache"];
org.tbyrne.composure.traits._TraitCollection.TraitTypeCache.prototype = {
	methodCachesSafe: null
	,getTrait: null
	,getTraits: null
	,matched: null
	,invalid: null
	,__class__: org.tbyrne.composure.traits._TraitCollection.TraitTypeCache
}
if(!org.tbyrne.composure.utils) org.tbyrne.composure.utils = {}
org.tbyrne.composure.utils.GenerationChecker = $hxClasses["org.tbyrne.composure.utils.GenerationChecker"] = function() { }
org.tbyrne.composure.utils.GenerationChecker.__name__ = ["org","tbyrne","composure","utils","GenerationChecker"];
org.tbyrne.composure.utils.GenerationChecker.createTraitCheck = function(maxGenerations,relatedItem) {
	if(maxGenerations == null) maxGenerations = -1;
	return function(item,from) {
		var compare;
		var $e = (relatedItem);
		switch( $e[1] ) {
		case 0:
			var other = $e[2];
			compare = other;
			break;
		case 1:
			compare = from.ownerTrait.item;
			break;
		case 2:
			compare = item.getRoot();
			break;
		}
		return false;
	};
}
org.tbyrne.composure.utils.GenerationChecker.prototype = {
	__class__: org.tbyrne.composure.utils.GenerationChecker
}
org.tbyrne.composure.utils.ItemType = $hxClasses["org.tbyrne.composure.utils.ItemType"] = { __ename__ : ["org","tbyrne","composure","utils","ItemType"], __constructs__ : ["specific","injectorItem","root"] }
org.tbyrne.composure.utils.ItemType.specific = function(ItemType) { var $x = ["specific",0,ItemType]; $x.__enum__ = org.tbyrne.composure.utils.ItemType; $x.toString = $estr; return $x; }
org.tbyrne.composure.utils.ItemType.injectorItem = ["injectorItem",1];
org.tbyrne.composure.utils.ItemType.injectorItem.toString = $estr;
org.tbyrne.composure.utils.ItemType.injectorItem.__enum__ = org.tbyrne.composure.utils.ItemType;
org.tbyrne.composure.utils.ItemType.root = ["root",2];
org.tbyrne.composure.utils.ItemType.root.toString = $estr;
org.tbyrne.composure.utils.ItemType.root.__enum__ = org.tbyrne.composure.utils.ItemType;
org.tbyrne.composure.utils.TraitChecker = $hxClasses["org.tbyrne.composure.utils.TraitChecker"] = function() { }
org.tbyrne.composure.utils.TraitChecker.__name__ = ["org","tbyrne","composure","utils","TraitChecker"];
org.tbyrne.composure.utils.TraitChecker.createTraitCheck = function(types,useOrCheck) {
	if(useOrCheck) return function(item,from) {
		var _g = 0;
		while(_g < types.length) {
			var type = types[_g];
			++_g;
			if(item.getTrait(type) != null) return true;
		}
		return false;
	}; else return function(item,from) {
		var _g = 0;
		while(_g < types.length) {
			var type = types[_g];
			++_g;
			if(item.getTrait(type) == null) return false;
		}
		return true;
	};
}
org.tbyrne.composure.utils.TraitChecker.prototype = {
	__class__: org.tbyrne.composure.utils.TraitChecker
}
org.tbyrne.composure.utils.TraitFurnisher = $hxClasses["org.tbyrne.composure.utils.TraitFurnisher"] = function(addType,injectoredTraitType,traitTypes,traitFactories,searchSiblings,searchDescendants,searchAscendants,adoptTrait) {
	if(searchAscendants == null) searchAscendants = false;
	if(searchDescendants == null) searchDescendants = true;
	if(searchSiblings == null) searchSiblings = true;
	org.tbyrne.composure.traits.AbstractTrait.call(this);
	this._addType = addType;
	this._addedTraits = new time.types.ds.ObjectHash();
	if(traitTypes != null) this._traitTypes = new org.tbyrne.collections.IndexedList(traitTypes);
	if(traitFactories != null) this._traitFactories = new org.tbyrne.collections.IndexedList(traitFactories);
	this.set_adoptTrait(adoptTrait);
	this.set_searchSiblings(searchSiblings);
	this.set_searchDescendants(searchDescendants);
	this.set_searchAscendants(searchAscendants);
	this.set_injectoredTraitType(injectoredTraitType);
};
org.tbyrne.composure.utils.TraitFurnisher.__name__ = ["org","tbyrne","composure","utils","TraitFurnisher"];
org.tbyrne.composure.utils.TraitFurnisher.__super__ = org.tbyrne.composure.traits.AbstractTrait;
org.tbyrne.composure.utils.TraitFurnisher.prototype = $extend(org.tbyrne.composure.traits.AbstractTrait.prototype,{
	injectoredTraitType: null
	,set_injectoredTraitType: function(value) {
		if(this._injector == null) {
			this._injector = new org.tbyrne.composure.injectors.Injector(value,this.onInjectoredTraitAdded.$bind(this),this.onInjectoredTraitRemoved.$bind(this),this.searchSiblings,this.searchDescendants,this.searchAscendants);
			this._injector.passThroughItem = true;
		} else {
			this.removeInjector(this._injector);
			this._injector.interestedTraitType = value;
		}
		this.injectoredTraitType = value;
		if(this.injectoredTraitType != null) this.addInjector(this._injector);
		return value;
	}
	,searchSiblings: null
	,set_searchSiblings: function(value) {
		if(this._injector != null) {
			this.removeInjector(this._injector);
			this._injector.siblings = value;
			this.addInjector(this._injector);
		}
		this.searchSiblings = value;
		return value;
	}
	,searchDescendants: null
	,set_searchDescendants: function(value) {
		if(this._injector != null) {
			this.removeInjector(this._injector);
			this._injector.descendants = value;
			this.addInjector(this._injector);
		}
		this.searchDescendants = value;
		return value;
	}
	,searchAscendants: null
	,set_searchAscendants: function(value) {
		if(this._injector != null) {
			this.removeInjector(this._injector);
			this._injector.ascendants = value;
			this.addInjector(this._injector);
		}
		this.searchAscendants = value;
		return value;
	}
	,adoptTrait: null
	,set_adoptTrait: function(value) {
		this.adoptTrait = value;
		if(this._foundTraits != null) {
			if(value) {
				var _g = 0, _g1 = this._foundTraits.getlist();
				while(_g < _g1.length) {
					var trait = _g1[_g];
					++_g;
					var item = this.getItem(trait);
					var origItem = this._originalItems.get(trait);
					if(item != origItem) {
						origItem.removeTrait(trait);
						item.addTrait(trait);
					}
				}
			} else {
				var _g = 0, _g1 = this._foundTraits.getlist();
				while(_g < _g1.length) {
					var trait = _g1[_g];
					++_g;
					var item = this.getItem(trait);
					var origItem = this._originalItems.get(trait);
					if(item != origItem) {
						item.removeTrait(trait);
						origItem.addTrait(trait);
					}
				}
			}
		}
		return value;
	}
	,_addType: null
	,_injector: null
	,_traits: null
	,_traitTypes: null
	,_traitFactories: null
	,_foundTraits: null
	,_addedTraits: null
	,_traitToItems: null
	,_originalItems: null
	,_originalParents: null
	,_ignoreTraitChanges: null
	,onInjectoredTraitAdded: function(trait,origItem) {
		if(this._ignoreTraitChanges) return;
		this._ignoreTraitChanges = true;
		if(this._foundTraits == null) {
			this._foundTraits = new org.tbyrne.collections.IndexedList();
			this._originalItems = new time.types.ds.ObjectHash();
		}
		this._foundTraits.add(trait);
		this._originalItems.set(trait,origItem);
		var item = this.registerItem(trait,origItem);
		if(this.adoptTrait && item != origItem) {
			origItem.removeTrait(trait);
			item.addTrait(trait);
		}
		var traitsAdded = [];
		if(this._traits != null) {
			var _g = 0, _g1 = this._traits.getlist();
			while(_g < _g1.length) {
				var otherTrait = _g1[_g];
				++_g;
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		if(this._traitTypes != null) {
			var _g = 0, _g1 = this._traitTypes.getlist();
			while(_g < _g1.length) {
				var traitType = _g1[_g];
				++_g;
				var otherTrait = Type.createInstance(traitType,[]);
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		if(this._traitFactories != null) {
			var _g = 0, _g1 = this._traitFactories.getlist();
			while(_g < _g1.length) {
				var traitFactory = _g1[_g];
				++_g;
				var otherTrait = traitFactory();
				item.addTrait(otherTrait);
				traitsAdded.push(otherTrait);
			}
		}
		this._addedTraits.set(trait,traitsAdded);
		this._ignoreTraitChanges = false;
	}
	,onInjectoredTraitRemoved: function(trait,currItem) {
		if(this._ignoreTraitChanges) return;
		this._ignoreTraitChanges = true;
		this._foundTraits.remove(trait);
		var origItem = this._originalItems.get(trait);
		if(this.adoptTrait && origItem != currItem) {
			currItem.removeTrait(trait);
			origItem.addTrait(trait);
		}
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
		this.unregisterItem(trait,item);
		this._ignoreTraitChanges = false;
	}
	,addTrait: function(trait) {
		if(this._traits == null) this._traits = new org.tbyrne.collections.IndexedList();
		this._traits.add(trait);
		if(this._foundTraits != null) {
			var _g = 0, _g1 = this._foundTraits.getlist();
			while(_g < _g1.length) {
				var foundTrait = _g1[_g];
				++_g;
				this.getItem(foundTrait).addTrait(trait);
				var traitsAdded = this._addedTraits.get(foundTrait);
				traitsAdded.push(trait);
			}
		}
	}
	,addTraitType: function(traitType) {
		if(this._traitTypes == null) this._traitTypes = new org.tbyrne.collections.IndexedList();
		this._traitTypes.add(traitType);
		if(this._foundTraits != null) {
			var _g = 0, _g1 = this._foundTraits.getlist();
			while(_g < _g1.length) {
				var trait = _g1[_g];
				++_g;
				var otherTrait = Type.createInstance(traitType,[]);
				this.getItem(trait).addTrait(otherTrait);
				var traitsAdded = this._addedTraits.get(trait);
				traitsAdded.push(otherTrait);
			}
		}
	}
	,addTraitFactory: function(traitFactory) {
		if(this._traitFactories == null) this._traitFactories = new org.tbyrne.collections.IndexedList();
		this._traitFactories.add(traitFactory);
		if(this._foundTraits != null) {
			var _g = 0, _g1 = this._foundTraits.getlist();
			while(_g < _g1.length) {
				var trait = _g1[_g];
				++_g;
				var otherTrait = traitFactory();
				this.getItem(trait).addTrait(otherTrait);
				var traitsAdded = this._addedTraits.get(trait);
				traitsAdded.push(otherTrait);
			}
		}
	}
	,getItem: function(trait) {
		return this._traitToItems.get(trait);
	}
	,registerItem: function(trait,origItem) {
		if(this._traitToItems == null) this._traitToItems = new time.types.ds.ObjectHash();
		var item;
		var $e = (this._addType);
		switch( $e[1] ) {
		case 4:
			item = this.item;
			break;
		case 1:
			item = origItem;
			break;
		case 0:
			var newParent = $e[2];
			item = origItem;
			if(this._originalParents == null) this._originalParents = new time.types.ds.ObjectHash();
			this._originalParents.set(trait,origItem.getParentItem());
			if(origItem.getParentItem() != newParent) {
				origItem.getParentItem().removeItem(origItem);
				newParent.addItem(origItem);
			}
			break;
		case 7:
			var specItem = $e[2];
			item = specItem;
			break;
		default:
			item = new org.tbyrne.composure.core.ComposeGroup();
			var $e = (this._addType);
			switch( $e[1] ) {
			case 5:
				this.item.getParentItem().addItem(item);
				break;
			case 2:
				origItem.getParentItem().addItem(item);
				break;
			case 6:
				this.group.addItem(item);
				break;
			case 3:
				if(Std["is"](origItem,org.tbyrne.composure.core.ComposeGroup)) {
					var origGroup;
					origGroup = origItem;
					origGroup.addItem(item);
				}
				break;
			case 8:
				var group = $e[2];
				group.addItem(item);
				break;
			case 9:
				var sibling = $e[2];
				sibling.getParentItem().addItem(item);
				break;
			default:
				haxe.Log.trace(new org.tbyrne.logging.LogMsg("Unsupported AddType",[org.tbyrne.logging.LogType.devError]),{ fileName : "TraitFurnisher.hx", lineNumber : 285, className : "org.tbyrne.composure.utils.TraitFurnisher", methodName : "registerItem"});
			}
		}
		this._traitToItems.set(trait,item);
		return item;
	}
	,unregisterItem: function(trait,currItem) {
		var $e = (this._addType);
		switch( $e[1] ) {
		case 2:
		case 5:
		case 3:
		case 6:
			currItem.getParentItem().removeItem(currItem);
			break;
		case 8:
			var group = $e[2];
			currItem.getParentItem().removeItem(currItem);
			break;
		case 9:
			var group = $e[2];
			currItem.getParentItem().removeItem(currItem);
			break;
		case 0:
			var newParent = $e[2];
			var oldParent = this._originalParents.get(trait);
			if(oldParent != currItem.getParentItem()) {
				this.item.getParentItem().removeItem(currItem);
				oldParent.addItem(currItem);
			}
			break;
		default:
		}
		this._traitToItems.remove(trait);
	}
	,__class__: org.tbyrne.composure.utils.TraitFurnisher
	,__properties__: $extend(org.tbyrne.composure.traits.AbstractTrait.prototype.__properties__,{set_adoptTrait:"set_adoptTrait",set_searchAscendants:"set_searchAscendants",set_searchDescendants:"set_searchDescendants",set_searchSiblings:"set_searchSiblings",set_injectoredTraitType:"set_injectoredTraitType"})
});
org.tbyrne.composure.utils.AddType = $hxClasses["org.tbyrne.composure.utils.AddType"] = { __ename__ : ["org","tbyrne","composure","utils","AddType"], __constructs__ : ["adoptItem","traitItem","traitSibling","traitChild","selfItem","selfSibling","selfChild","item","itemChild","itemSibling"] }
org.tbyrne.composure.utils.AddType.adoptItem = function(newParent) { var $x = ["adoptItem",0,newParent]; $x.__enum__ = org.tbyrne.composure.utils.AddType; $x.toString = $estr; return $x; }
org.tbyrne.composure.utils.AddType.traitItem = ["traitItem",1];
org.tbyrne.composure.utils.AddType.traitItem.toString = $estr;
org.tbyrne.composure.utils.AddType.traitItem.__enum__ = org.tbyrne.composure.utils.AddType;
org.tbyrne.composure.utils.AddType.traitSibling = ["traitSibling",2];
org.tbyrne.composure.utils.AddType.traitSibling.toString = $estr;
org.tbyrne.composure.utils.AddType.traitSibling.__enum__ = org.tbyrne.composure.utils.AddType;
org.tbyrne.composure.utils.AddType.traitChild = ["traitChild",3];
org.tbyrne.composure.utils.AddType.traitChild.toString = $estr;
org.tbyrne.composure.utils.AddType.traitChild.__enum__ = org.tbyrne.composure.utils.AddType;
org.tbyrne.composure.utils.AddType.selfItem = ["selfItem",4];
org.tbyrne.composure.utils.AddType.selfItem.toString = $estr;
org.tbyrne.composure.utils.AddType.selfItem.__enum__ = org.tbyrne.composure.utils.AddType;
org.tbyrne.composure.utils.AddType.selfSibling = ["selfSibling",5];
org.tbyrne.composure.utils.AddType.selfSibling.toString = $estr;
org.tbyrne.composure.utils.AddType.selfSibling.__enum__ = org.tbyrne.composure.utils.AddType;
org.tbyrne.composure.utils.AddType.selfChild = ["selfChild",6];
org.tbyrne.composure.utils.AddType.selfChild.toString = $estr;
org.tbyrne.composure.utils.AddType.selfChild.__enum__ = org.tbyrne.composure.utils.AddType;
org.tbyrne.composure.utils.AddType.item = function(item) { var $x = ["item",7,item]; $x.__enum__ = org.tbyrne.composure.utils.AddType; $x.toString = $estr; return $x; }
org.tbyrne.composure.utils.AddType.itemChild = function(group) { var $x = ["itemChild",8,group]; $x.__enum__ = org.tbyrne.composure.utils.AddType; $x.toString = $estr; return $x; }
org.tbyrne.composure.utils.AddType.itemSibling = function(item) { var $x = ["itemSibling",9,item]; $x.__enum__ = org.tbyrne.composure.utils.AddType; $x.toString = $estr; return $x; }
if(!org.tbyrne.composureTest) org.tbyrne.composureTest = {}
org.tbyrne.composureTest.ClassIncluder = $hxClasses["org.tbyrne.composureTest.ClassIncluder"] = function() { }
org.tbyrne.composureTest.ClassIncluder.__name__ = ["org","tbyrne","composureTest","ClassIncluder"];
org.tbyrne.composureTest.ClassIncluder.main = function() {
}
org.tbyrne.composureTest.ClassIncluder.prototype = {
	__class__: org.tbyrne.composureTest.ClassIncluder
}
if(!org.tbyrne.logging) org.tbyrne.logging = {}
org.tbyrne.logging.LogMsg = $hxClasses["org.tbyrne.logging.LogMsg"] = function(message,types,title,id) {
	this.message = message;
	this.types = types;
	this.title = title;
	this.id = id;
};
org.tbyrne.logging.LogMsg.__name__ = ["org","tbyrne","logging","LogMsg"];
org.tbyrne.logging.LogMsg.prototype = {
	id: null
	,message: null
	,types: null
	,title: null
	,__class__: org.tbyrne.logging.LogMsg
}
org.tbyrne.logging.LogType = $hxClasses["org.tbyrne.logging.LogType"] = function() { }
org.tbyrne.logging.LogType.__name__ = ["org","tbyrne","logging","LogType"];
org.tbyrne.logging.LogType.devInfo = null;
org.tbyrne.logging.LogType.devWarning = null;
org.tbyrne.logging.LogType.devError = null;
org.tbyrne.logging.LogType.userInfo = null;
org.tbyrne.logging.LogType.userWarning = null;
org.tbyrne.logging.LogType.userError = null;
org.tbyrne.logging.LogType.performanceWarning = null;
org.tbyrne.logging.LogType.deprecationWarning = null;
org.tbyrne.logging.LogType.externalError = null;
org.tbyrne.logging.LogType.prototype = {
	__class__: org.tbyrne.logging.LogType
}
var time = time || {}
if(!time.types) time.types = {}
if(!time.types.ds) time.types.ds = {}
time.types.ds.ObjectHash = $hxClasses["time.types.ds.ObjectHash"] = function() {
	this.ival = new IntHash();
	this.length = 0;
};
time.types.ds.ObjectHash.__name__ = ["time","types","ds","ObjectHash"];
time.types.ds.ObjectHash.hashString = function(str) {
	var h = 0;
	var _g1 = 0, _g = str.length;
	while(_g1 < _g) {
		var i = _g1++;
		var i1 = str.cca(i);
		h += (i1 << 5) - i1;
	}
	return h;
}
time.types.ds.ObjectHash.prototype = {
	ival: null
	,length: null
	,set: function(k,v) {
		var oid = this.getObjectId(k);
		var g = this.ival.get(oid);
		if(g == null) {
			g = [];
			this.ival.set(oid,g);
		}
		var i = 0;
		var len = g.length;
		while(i < len) {
			if(g[i] == k) {
				g[i + 1] = v;
				return;
			}
			i += 2;
		}
		g.push(k);
		g.push(v);
		this.length++;
	}
	,getObjectId: function(obj) {
		if(Std["is"](obj,String)) return time.types.ds.ObjectHash.hashString(obj); else if(Std["is"](obj,Class)) {
			if(obj.__cls_id__ == null) obj.__cls_id__ = time.types.ds.ObjectHash.clsId++;
			return obj.__cls_id__;
		} else {
			if(obj.__get_id__ == null) {
				var cls = Type.getClass(obj);
				if(cls == null) {
					var id = Std.random(2147483647);
					obj.__get_id__ = function() {
						return id;
					};
					return id;
				}
				var fstid = Std.random(2147483647);
				cls.prototype.__get_id__ = function() {
					if(this.___id___ == null) return this.___id___ = Std.random(2147483647);
					return this.___id___;
				};
			}
			return obj.__get_id__();
		}
	}
	,get: function(k) {
		if(k == null) return null;
		var oid = this.getObjectId(k);
		var g = this.ival.get(oid);
		if(g == null) return null;
		var i = 0;
		var len = g.length;
		while(i < len) {
			if(g[i] == k) return g[i + 1];
			i += 2;
		}
		return null;
	}
	,exists: function(k) {
		var oid = this.getObjectId(k);
		var removed = false;
		var g = this.ival.get(oid);
		if(g == null) return false;
		var i = 0;
		var len = g.length;
		while(i < len) {
			if(g[i] == k) return true;
			i += 2;
		}
		return false;
	}
	,remove: function(k) {
		var oid = this.getObjectId(k);
		var removed = false;
		var g = this.ival.get(oid);
		if(g == null) return false;
		var i = 0;
		var len = g.length;
		while(i < len) {
			if(g[i] == k) {
				g.splice(i,2);
				removed = true;
				this.length--;
				break;
			}
			i += 2;
		}
		if(g.length == 0) this.ival.remove(oid);
		return removed;
	}
	,keys: function() {
		var valit = this.ival.iterator();
		var curr = null;
		var currIndex = 0;
		return { hasNext : function() {
			return curr != null || valit.hasNext();
		}, next : function() {
			if(curr == null) curr = valit.next();
			var ret = curr[currIndex];
			currIndex += 2;
			if(currIndex >= curr.length) {
				currIndex = 0;
				curr = null;
			}
			return ret;
		}};
	}
	,iterator: function() {
		var valit = this.ival.iterator();
		var curr = null;
		var currIndex = 1;
		return { hasNext : function() {
			return curr != null || valit.hasNext();
		}, next : function() {
			if(curr == null) curr = valit.next();
			var ret = curr[currIndex];
			currIndex += 2;
			if(currIndex >= curr.length) {
				currIndex = 1;
				curr = null;
			}
			return ret;
		}};
	}
	,toString: function() {
		var ret = new StringBuf();
		ret.b[ret.b.length] = "{ ";
		var first = true;
		var $it0 = this.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			if(first) {
				ret.b[ret.b.length] = "\"";
				first = false;
			} else ret.b[ret.b.length] = ", \"";
			ret.b[ret.b.length] = k == null?"null":k;
			ret.b[ret.b.length] = "\" => \"";
			ret.add(this.get(k));
			ret.b[ret.b.length] = "\"";
		}
		ret.b[ret.b.length] = " }";
		return ret.b.join("");
	}
	,hxSerialize: function(s) {
		s.serialize(this.length);
		var valit = this.ival.iterator();
		var curr = null;
		var currIndex = 0;
		while(curr != null || valit.hasNext()) {
			if(curr == null) curr = valit.next();
			var ret = curr[currIndex];
			s.serialize(curr[currIndex]);
			s.serialize(curr[currIndex + 1]);
			currIndex += 2;
			if(currIndex >= curr.length) {
				currIndex = 0;
				curr = null;
			}
		}
	}
	,hxUnserialize: function(s) {
		var len = s.unserialize();
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			var k = s.unserialize();
			var v = s.unserialize();
			this.set(k,v);
		}
	}
	,__class__: time.types.ds.ObjectHash
}
js.Boot.__res = {}
js.Boot.__init();
{
	var d = Date;
	d.now = function() {
		return new Date();
	};
	d.fromTime = function(t) {
		var d1 = new Date();
		d1["setTime"](t);
		return d1;
	};
	d.fromString = function(s) {
		switch(s.length) {
		case 8:
			var k = s.split(":");
			var d1 = new Date();
			d1["setTime"](0);
			d1["setUTCHours"](k[0]);
			d1["setUTCMinutes"](k[1]);
			d1["setUTCSeconds"](k[2]);
			return d1;
		case 10:
			var k = s.split("-");
			return new Date(k[0],k[1] - 1,k[2],0,0,0);
		case 19:
			var k = s.split(" ");
			var y = k[0].split("-");
			var t = k[1].split(":");
			return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
		default:
			throw "Invalid date format : " + s;
		}
	};
	d.prototype["toString"] = function() {
		var date = this;
		var m = date.getMonth() + 1;
		var d1 = date.getDate();
		var h = date.getHours();
		var mi = date.getMinutes();
		var s = date.getSeconds();
		return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d1 < 10?"0" + d1:"" + d1) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
	};
	d.prototype.__class__ = $hxClasses["Date"] = d;
	d.__name__ = ["Date"];
}
{
	Math.__name__ = ["Math"];
	Math.NaN = Number["NaN"];
	Math.NEGATIVE_INFINITY = Number["NEGATIVE_INFINITY"];
	Math.POSITIVE_INFINITY = Number["POSITIVE_INFINITY"];
	$hxClasses["Math"] = Math;
	Math.isFinite = function(i) {
		return isFinite(i);
	};
	Math.isNaN = function(i) {
		return isNaN(i);
	};
}
{
	String.prototype.__class__ = $hxClasses["String"] = String;
	String.__name__ = ["String"];
	Array.prototype.__class__ = $hxClasses["Array"] = Array;
	Array.__name__ = ["Array"];
	var Int = $hxClasses["Int"] = { __name__ : ["Int"]};
	var Dynamic = $hxClasses["Dynamic"] = { __name__ : ["Dynamic"]};
	var Float = $hxClasses["Float"] = Number;
	Float.__name__ = ["Float"];
	var Bool = $hxClasses["Bool"] = Boolean;
	Bool.__ename__ = ["Bool"];
	var Class = $hxClasses["Class"] = { __name__ : ["Class"]};
	var Enum = { };
	var Void = $hxClasses["Void"] = { __ename__ : ["Void"]};
}
{
	if(typeof document != "undefined") js.Lib.document = document;
	if(typeof window != "undefined") {
		js.Lib.window = window;
		js.Lib.window.onerror = function(msg,url,line) {
			var f = js.Lib.onerror;
			if(f == null) return false;
			return f(msg,[url + ":" + line]);
		};
	}
}
{
	org.tbyrne.logging.LogType.devInfo = "devInfo";
	org.tbyrne.logging.LogType.devWarning = "devWarning";
	org.tbyrne.logging.LogType.devError = "devError";
	org.tbyrne.logging.LogType.userInfo = "userInfo";
	org.tbyrne.logging.LogType.userWarning = "userWarning";
	org.tbyrne.logging.LogType.userError = "userError";
	org.tbyrne.logging.LogType.performanceWarning = "performanceWarning";
	org.tbyrne.logging.LogType.deprecationWarning = "deprecationWarning";
	org.tbyrne.logging.LogType.externalError = "externalError";
}
haxe.Serializer.USE_CACHE = false;
haxe.Serializer.USE_ENUM_INDEX = false;
haxe.Serializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe.Unserializer.DEFAULT_RESOLVER = Type;
haxe.Unserializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe.Unserializer.CODES = null;
hsl.haxe._DirectSignaler.PropagationStatus.IMMEDIATELY_STOPPED = 1;
hsl.haxe._DirectSignaler.PropagationStatus.STOPPED = 2;
hsl.haxe._DirectSignaler.PropagationStatus.UNDISTURBED = 3;
js.Lib.onerror = null;
time.types.ds.ObjectHash.SAFE_NUM = 2147483647;
time.types.ds.ObjectHash.clsId = 0;
org.tbyrne.composureTest.ClassIncluder.main()