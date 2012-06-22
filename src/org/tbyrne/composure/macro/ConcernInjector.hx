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
		var constructor:Function;
		var addExpr:Array<Expr>;
		
		var addMethods:Hash<Field>;
		var remMethods:Hash<Field>;
		var typePathToExpr:Hash<ExprDef>;
		
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
								createPropConcern(field.name, getTypeExpr(t, pos), false, meta, addExpr, pos);
							case FProp( get , set , t , e  ):
								createPropConcern(field.name, getTypeExpr(t, pos), (get=="null" || get=="never"), meta, addExpr, pos);
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
					createMethConcern(field, remMeth, typePathToExpr.get(typePath), addExpr, field.pos);
				}
			}
			for (typePath in remMethods.keys()) {
				if (!done.get(typePath)) {
					done.set(typePath, true);
					
					var field = remMethods.get(typePath);
					createMethConcern(null, field, typePathToExpr.get(typePath), addExpr, field.pos);
				}
			}
		}
		
		if (addExpr != null) {
			if(constructor!=null){
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
	private static function addInjectMethod(field:Field, toHash:Hash<Field>, typePathToExpr:Hash<ExprDef>):Void {
		switch(field.kind) {
			case FFun( f ):
				if (f.args.length != 1) {
					trace(field.name);
					throw new Error("Injectible functions must have only one argument", field.pos);
				}
				var arg = f.args[0];
				var typePath:String = getTypePath(arg.type, field.pos);
				toHash.set(typePath, field);
				if (!typePathToExpr.exists(typePath)) {
					typePathToExpr.set(typePath, getTypeExpr(arg.type, field.pos));
				}
			default:
				//ignore
		}
	}
	private static function createMethConcern(addMeth:Field, remMeth:Field, typeExpr:ExprDef, addTo:Array<Expr>, pos:Position):Void {
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
		var expr:Expr = { expr : ECall( { expr : EConst(CIdent("addConcern")), pos : pos }, [ { expr : ENew( { name : "Concern", pack : ["org", "tbyrne", "composure", "concerns"], params : [], sub : null }, [ { expr : typeExpr, pos : pos }, { expr : addExpr, pos :pos}, { expr : remExpr, pos :pos}, { expr : EConst(CIdent(concernAccess.siblings?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.descendants?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.ascendants?"true":"false")), pos : pos } ]), pos : pos } ]), pos : pos };
		addTo.push(expr);
	}
	private static function createPropConcern(fieldName:String, typeExpr:ExprDef, writeOnly:Bool, meta:{ name : String, params : Array<Expr>, pos : Position }, addTo:Array<Expr>, pos:Position):Void {
		var concernAccess:ConcernAccess = new ConcernAccess();
		checkMetaAccess(concernAccess, meta);
		var expr:Expr = { expr : ECall( { expr : EConst(CIdent("addConcern")), pos : pos }, [ { expr : ENew( { name : "PropConcern", pack : ["org", "tbyrne", "composure", "concerns"], params : [], sub : null }, [ { expr : typeExpr, pos : pos }, { expr : EConst(CIdent("this")), pos : pos }, { expr : EConst(CString(fieldName)), pos : pos }, { expr : EConst(CIdent(concernAccess.siblings?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.descendants?"true":"false")), pos : pos }, { expr : EConst(CIdent(concernAccess.ascendants?"true":"false")), pos : pos }, { expr : EConst(CIdent(writeOnly?"true":"false")), pos : pos } ]), pos : pos } ]), pos : pos };
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
	private static function getTypePath(t:ComplexType, pos:Position):String {
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