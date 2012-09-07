package ;


import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.Log;
import msignal.Signal;

/**
 * @author Tom Byrne
 */

class LazyInst 
{
	private static var _metaName:String = "lazyInst";
	//private static var TYPE_PARAM_PATTERN:EReg = ~/^(.*?)<(.*)>$/;

	@:macro public static function check() :Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		var pos:Position = Context.getLocalClass().get().pos;
		
		/*for (field in fields) {
			trace(field);
		}*/
		
		var signalNames:Array<String> = [];
		var signalInfos:Array<SignalInfo> = [];
		//var wrongFormat:Bool;
		for (field in fields) {
			var doLazy:Bool;
			for (meta in field.meta) {
				if (meta.name == _metaName) {
					doLazy = true;
					break;
				}
			}
			if (doLazy) {
				var privateName:String = "_" + field.name;
				var getterName:String = "get_" + field.name;
				var fieldPos:Position = field.pos;
				switch(field.kind) {
					case FVar( t , e):
						switch(t) {
							case TPath(tp):
								addPrivateProp(privateName, t, fields, fieldPos);
								addGetter(getterName, privateName, tp, false, fields, fieldPos);
								field.kind = FProp( getterName , "null" , t , e );
							default:
								throw new Error("Lazy Instantiation can only be properties typed by class", field.pos);
						}
					case FProp( get , set , t , e ):
						addPrivateProp(privateName, t, fields, fieldPos);
						var isPrivate:Bool = get == "null";
						if (get == "default" || isPrivate) {
							switch(t) {
								case TPath(tp):
									addGetter(getterName, privateName, tp, isPrivate, fields, fieldPos);
									if (set == "default") set = "null";
									field.kind = FProp( getterName , set , t , e );
								default:
									throw new Error("Lazy Instantiation can only be properties typed by class", field.pos);
							}
						}else if (get == "never") {
							throw new Error("Lazy Instantiation can only be used on accessible properties", field.pos);
						}else {
							switch(t) {
								case TPath(tp):
									var field:Field = findField(fields, field.name);
									switch(field.kind) {
										case FFun(f):
											addToGetter(f.expr, privateName, tp, fieldPos);
										default:
											// getter is set up wrong, compiler will argue
									}
								default:
									throw new Error("Lazy Instantiation can only be properties typed by class", field.pos);
							}
						}
					default:
						throw new Error("Lazy Instantiation can only be used on properties", field.pos);
				}
			}
		}
		return fields;
	}
	@:macro public static function get<PropType>(prop:ExprOf<PropType>):ExprOf<PropType> 
	{
		// The get macro adds something like this:
		//	if (_prop != null)_prop
		// which will then be followed by whatever expression was used after the get() call
		
		var pos:Position = Context.currentPos();
		
		var wrongFormat:Bool;
		var privateName:String;
		switch(prop.expr) {
			case EConst(c):
				switch(c) {
					case CIdent(str):
						privateName = "_" + str;
					default:
						wrongFormat = true;
				}
			default:
				wrongFormat = true;
		}
		if (wrongFormat) {
			throw new Error("Lazy getting must reference a lazy property, as tagged with the @lazyInst metadata.", pos);
			return null;
		}
		
		return { expr : EIf( { expr : EBinop(OpNotEq, { expr : EConst(CIdent(privateName)), pos : pos }, { expr : EConst(CIdent("null")), pos : pos } ), pos : pos }, { expr : EConst(CIdent(privateName)), pos : pos }, null), pos : pos };
	}
	
	#if macro
	private static function findField(fields:Array<Field>, fieldName:String):Field {
		for (field in fields) {
			if (field.name == fieldName) {
				return field;
			}
		}
		return null;
	}
	private static function addPrivateProp(privateName:String, t:ComplexType, fields:Array<Field>, pos:Position):Void {
		/*
		 * Adds:
		 * private var {privateName}:{T};
		 */
		var privateProp = { kind : FVar(t, null), meta : [], name : privateName, doc : null, pos : pos, access : [APrivate] };
		fields.push(privateProp);
			
	}
	private static function addGetter(getterName:String, privateName:String, t:TypePath, isPrivate:Bool, fields:Array<Field>, pos:Position):Field {
		var addExpr:Expr = createLazyInst(privateName, t, pos);
		var field:Field = { kind : FFun( { args : [], expr : { expr : EBlock([ addExpr, { expr : EReturn( { expr : EConst(CIdent(privateName)), pos : pos } ), pos : pos } ]), pos : pos }, params : [], ret : TPath( t ) } ), meta : [], name : getterName, doc : null, pos : pos, access : [APrivate] };
		fields.push(field);
		return field;
	}
	private static function addToGetter(e:Expr, privateName:String, t:TypePath, pos:Position):Void {
		var addExpr:Expr = createLazyInst(privateName, t, pos);
		switch(e.expr) {
			case EBlock(exprs):
				exprs.insert(0, addExpr);
			default:
				e.expr = EBlock([addExpr,{expr:e.expr, pos:e.pos}]);
		}
	}
	private static function createLazyInst(privateName:String, t:TypePath, pos:Position):Expr {
		/*
		 * Creates:
		 * if({privateName}==null){privateName} = new {t}();
		 */
		return { expr : EIf( { expr : EBinop(OpEq, { expr : EConst(CIdent(privateName)), pos : pos }, { expr : EConst(CIdent("null")), pos : pos } ), pos : pos }, { expr : EBinop(OpAssign, { expr : EConst(CIdent(privateName)), pos : pos }, { expr : ENew( t, []), pos : pos } ), pos : pos }, null), pos : pos }
		
	}
	#end
}

#if macro
typedef SignalInfo = {
	var name:String;
	var pos:Position;
	var typeList:Array<TypeParam>;
}

#end