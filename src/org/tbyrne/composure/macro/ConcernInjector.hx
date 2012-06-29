package org.tbyrne.composure.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;

/**
 * ...
 * @author Tom Byrne
 */

class ConcernInjector
{

	@:macro public static function inject() : Array<Field> {
        var fields:Array<Field> = Context.getBuildFields();
		if (fields.length == 0) return fields;
		
		var constructor:Function;
		var addExpr:Array<Expr>;
		
		var addMethods:Hash<Field>;
		var remMethods:Hash<Field>;
		var typePathToExpr:Hash<ExprDef>;
		
		var type:Type = Context.getLocalType();
		var isTrait:Bool = doesTypeInherit("org.tbyrne.composure.traits.ITrait", type);
		
		var addConcernMethod:Expr;
		if (isTrait) {
			addConcernMethod = { expr : EConst(CIdent("addConcern")), pos : fields[0].pos };
		}else {
			addConcernMethod = { expr : EField( { expr : EConst(CIdent("_proxiedTrait")), pos : fields[0].pos }, "addConcern"), pos :fields[0].pos };
		}
		
		for (field in fields) {
			if (field.name == "new") {
				switch(field.kind) {
					case FFun( f ):
						constructor = f;
					default:
				}
			}else{
				for (meta in field.meta) {
					if (meta.name == "inject") {
						var pos:Position = field.pos;
						if (addExpr == null) addExpr = [];
						switch(field.kind) {
							case FVar( t , e  ):
								createPropConcern(field.name, getTypeExpr(t, pos), false, meta, addExpr, pos, addConcernMethod);
							case FProp( get , set , t , e  ):
								createPropConcern(field.name, getTypeExpr(t, pos), (get=="null" || get=="never"), meta, addExpr, pos, addConcernMethod);
							default:
								//ignore
						}
					}else if (meta.name == "injectAdd") {
						if (addMethods == null) addMethods = new Hash<Field>();
						if (typePathToExpr == null) typePathToExpr = new Hash<ExprDef>();
						addInjectMethod(field, addMethods, typePathToExpr);
					}else if (meta.name == "injectRemove" || meta.name == "injectRem") {
						if (remMethods == null) remMethods = new Hash<Field>();
						if (typePathToExpr == null) typePathToExpr = new Hash<ExprDef>();
						addInjectMethod(field, remMethods, typePathToExpr);
					}
				}
			}
		}
		
		if (addMethods != null || remMethods != null) {
			if (addExpr == null) addExpr = [];
			
			var done:Hash<Bool> = new Hash<Bool>();
			for (typePath in addMethods.keys()) {
				if (!done.get(typePath)) {
					done.set(typePath, true);
					
					var field = addMethods.get(typePath);
					var remMeth:Field;
					if(remMethods!=null){
						remMeth = remMethods.get(typePath);
					}
					createMethConcern(field, remMeth, typePathToExpr.get(typePath), addExpr, field.pos, addConcernMethod);
				}
			}
			for (typePath in remMethods.keys()) {
				if (!done.get(typePath)) {
					done.set(typePath, true);
					
					var field = remMethods.get(typePath);
					createMethConcern(null, field, typePathToExpr.get(typePath), addExpr, field.pos, addConcernMethod);
				}
			}
		}
		
		if (addExpr != null) {
			if (constructor != null) {
				if (!isTrait) {
					// add ITraitProxy interface (This is impossible in current macro system)
					/*switch(type) {
						case TInst( t , params  ):
							var classType:ClassType = t.get();
							var proxyInterface:ClassType = cast Context.getType("org.tbyrne.composure.traits.ITraitProxy");
							classType.interfaces.push( { params : [], t : Ref. (proxyInterface) } );
						
						default:
							throw new Error("ConcernInjector can't operate on non-classes that don't extend ITrait", Context.getLocalClass().get().pos);
					}*/
					// add _proxiedTrait variable
					fields.push({ kind : FVar(TPath( { name : "AbstractTrait", pack : ["org", "tbyrne", "composure", "traits"], params : [], sub : null } ), null), meta : [], name : "_proxiedTrait", doc : null, pos : constructor.expr.pos, access : [APrivate] });
					// add getProxiedTrait function
					fields.push( { kind : FFun( { args : [], expr : { expr : EBlock([ { expr : EReturn( { expr : EConst(CIdent("_proxiedTrait")), pos : constructor.expr.pos } ), pos : constructor.expr.pos } ]), pos : constructor.expr.pos }, params : [], ret : TPath( { name : "ITrait", pack : ["org", "tbyrne", "composure", "traits"], params : [], sub : null } ) } ), meta : [], name : "getProxiedTrait", doc : null, pos : constructor.expr.pos, access : [APublic] } );
					// instantiate proxiedTrait
					addExpr.unshift({ expr : EBlock([{ expr : EBinop(OpAssign,{ expr : EConst(CIdent("_proxiedTrait")), pos : constructor.expr.pos },{ expr : ENew({ name : "AbstractTrait", pack : ["org", "tbyrne", "composure", "traits"], params : [], sub : null },[{expr:EConst(CIdent("this")), pos:constructor.expr.pos}]), pos : constructor.expr.pos }), pos : constructor.expr.pos }]), pos : constructor.expr.pos });
				}
				switch(constructor.expr.expr) {
					case EBlock(exprs):
						for (expr in addExpr) {
							exprs.push(expr);
						}
					default:
						addExpr.unshift(constructor.expr);
						constructor.expr.expr = EBlock(addExpr);
				}
			}else {
				throw new Error("ConcernInjector can't operate on classes without a constructor", Context.getLocalClass().get().pos);
			}
		}
		
        return fields;
    }
	
	#if macro
	private static function doesTypeInherit(classpath:String, type:Type):Bool {
		switch(type) {
			
			case TMono( t ):
				return doesTypeInherit(classpath, t.get());
			case TDynamic( t ):
				if (t == null) return false;
				else return doesTypeInherit(classpath, t);
			case TType( t , params ):
				return doesTypeInherit(classpath, t.get().type);
			case TInst( t , params ):
				return doesClassTypeInherit(classpath, t.get());
			default:
				return false;
		}
	}
	private static function doesClassTypeInherit(classpath:String, type:ClassType):Bool {
		if (type.superClass != null) {
			if (classpath == getClassTypePath(type) || doesClassTypeInherit(classpath, type.superClass.t.get())) return true;
		}
		for (interf in type.interfaces) {
			var intType:ClassType = interf.t.get();
			if (classpath == getClassTypePath(intType) || doesClassTypeInherit(classpath, intType)) return true;
		}
		return false;
	}
	private static function addInjectMethod(field:Field, toHash:Hash<Field>, typePathToExpr:Hash<ExprDef>):Void {
		switch(field.kind) {
			case FFun( f ):
				if (f.args.length != 1) {
					throw new Error("Injectible functions must have only one argument", field.pos);
				}
				var arg = f.args[0];
				var typePath:String = getComplexTypePath(arg.type, field.pos);
				toHash.set(typePath, field);
				if (!typePathToExpr.exists(typePath)) {
					typePathToExpr.set(typePath, getTypeExpr(arg.type, field.pos));
				}
			default:
				//ignore
		}
	}
	private static function createMethConcern(addMeth:Field, remMeth:Field, typeExpr:ExprDef, addTo:Array<Expr>, pos:Position, addConcernMeth:Expr):Void {
		var concernAccess:ConcernAccess = new ConcernAccess();
		var remExpr:ExprDef;
		if(remMeth!=null){
			for (meta in remMeth.meta) {
				if(meta.name == "injectRemove" || meta.name == "injectRem"){
					checkMetaAccess(concernAccess, meta);
				}
			}
			remExpr = EConst(CIdent(remMeth.name));
		}else {
			remExpr = EConst(CIdent("null"));
		}
		var addExpr:ExprDef;
		if(addMeth!=null){
			for (meta in addMeth.meta) {
				if(meta.name == "injectAdd"){
					checkMetaAccess(concernAccess, meta);
				}
			}
			addExpr = EConst(CIdent(addMeth.name));
		}else {
			addExpr = EConst(CIdent("null"));
		}
		var expr:Expr = { expr : ECall( addConcernMeth, [ { expr : ENew( { name : "Concern", pack : ["org", "tbyrne", "composure", "concerns"], params : [], sub : null }, [ { expr : typeExpr, pos : pos }, { expr : addExpr, pos :pos}, { expr : remExpr, pos :pos}, { expr : EConst(CIdent(concernAccess.siblings?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.descendants?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.ascendants?"true":"false")), pos : pos } ]), pos : pos } ]), pos : pos };
		addTo.push(expr);
	}
	private static function createPropConcern(fieldName:String, typeExpr:ExprDef, writeOnly:Bool, meta:{ name : String, params : Array<Expr>, pos : Position }, addTo:Array<Expr>, pos:Position, addConcernMethod:Expr):Void {
		var concernAccess:ConcernAccess = new ConcernAccess();
		checkMetaAccess(concernAccess, meta);
		var expr:Expr = { expr : ECall( addConcernMethod, [ { expr : ENew( { name : "PropConcern", pack : ["org", "tbyrne", "composure", "concerns"], params : [], sub : null }, [ { expr : typeExpr, pos : pos }, { expr : EConst(CIdent("this")), pos : pos }, { expr : EConst(CString(fieldName)), pos : pos }, { expr : EConst(CIdent(concernAccess.siblings?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.descendants?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.ascendants?"true":"false")), pos : pos }, { expr : EConst(CIdent(writeOnly?"true":"false")), pos : pos } ]), pos : pos } ]), pos : pos };
		addTo.push(expr);
	}
	private static function checkMetaAccess(concernAccess:ConcernAccess, meta: { name : String, params : Array<Expr>, pos : Position } ):Void {
		for (metaExpr in meta.params) {
			switch(metaExpr.expr) {
				case EObjectDecl(metaFields):
					for (metaField in metaFields) {
						if (metaField.field == "sibl" || metaField.field == "siblings") {
							concernAccess.siblings = getBool(metaField.expr, meta.pos, metaField.field);
						}else if (metaField.field == "desc" || metaField.field == "descendants") {
							concernAccess.descendants = getBool(metaField.expr, meta.pos, metaField.field);
						}else if (metaField.field == "asc" || metaField.field == "ascendants") {
							concernAccess.ascendants = getBool(metaField.expr, meta.pos, metaField.field);
						}
					}
				default:
					// ignore
			}
		}
	}
	private static function getBool(expr:Expr, pos:Position, propName:String):Bool {
		switch(expr.expr) {
			case EConst(c):
				switch(c) {
					case CIdent(s):
						if (s == "true") {
							return true;
						}else if (s == "false") {
							return false;
						}
					default:
						// ignore
				}
			default:
				// ignore
		}
		throw new Error(propName + " must be set to either true or false", pos);
	}
	
	private static function getTypeExpr(t:ComplexType, pos:Position):ExprDef {
		switch(t) {
			case TPath(t):
				if (t.pack.length > 0) {
					var pack:ExprDef;
					for (packStr in t.pack) {
						if (pack == null) {
							pack = EConst(CIdent(packStr));
						}else {
							pack = EField( { expr : pack, pos : pos }, packStr);
						}
					}
					return EType({expr:pack,pos:pos},t.name);
				}else{
					return EConst(CType(t.name));
				}
			default:
				throw new Error("Only simple can currrently be injected", pos);
		}
	}
	private static function getComplexTypePath(t:ComplexType, pos:Position):String {
		switch(t) {
			case TPath(t):
				if (t.pack.length > 0) {
					return t.pack.join(".")+"."+t.name;
				}else{
					return t.name;
				}
			default:
				throw new Error("Only simple can currrently be injected", pos);
		}
	}
	private static function getClassTypePath(t:ClassType):String {
		if(t.pack.length>0){
			return t.pack.join(".") + "."+t.name;
		}else {
			return t.name;
		}
	}
	
	#end
}
class ConcernAccess {
	public var siblings:Bool;
	public var descendants:Bool;
	public var ascendants:Bool;
	
	public function new() {
		siblings = true;
		descendants = false;
		ascendants = false;
	}
	
}