package ;


import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.Log;
import msignal.Signal;


class LazyInst 
{
	private static var _metaName:String = "lazyInst";

	@:macro public static function check() :Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		var pos:Position = Context.getLocalClass().get().pos;
		
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
	@:macro public static function exec(expr:Expr):Expr
	{
		// The get macro adds something like this:
		//	if (_prop != null)_prop
		// which will then be followed by whatever expression was used after the get() call
		
		var pos:Position = Context.currentPos();
		var fields:Array<ClassField> = Context.getLocalClass().get().fields.get();
		
		var reads:Array<String> = [];
		findLocalReads(reads, expr, fields);
		if (reads.length==0) {
			throw new Error("No lazy props were found", pos);
		}
		
		var ifExpr:Expr;
		for (prop in reads) {
			var newExpr = EBinop(OpNotEq, { expr : EConst(CIdent("_"+prop)), pos : pos }, { expr : EConst(CIdent("null")), pos : pos } );
			if (ifExpr != null) {
				ifExpr = { expr : EBinop(OpBoolAnd,ifExpr,{ expr:newExpr, pos:pos }), pos : pos };
			}else {
				ifExpr = { expr:newExpr, pos:pos };
			}
		}
		return { expr : EIf( ifExpr, expr, null), pos : pos };
	}
	
	#if macro
	private static function findLocalReads(reads:Array<String>, expr:Expr, fields:Array<ClassField>):Void {
		switch(expr.expr) {
			case EConst(c):
				switch(c) {
					case CIdent(str):
						if (hasLazyField(fields, str)) {
							if (Lambda.indexOf(reads, str)==-1)reads.push(str);
							
							expr.expr = EConst(CIdent("_"+str));
						}
					default:
				}
			case ECall(e,params):
				findLocalReads(reads, e, fields);
				for (e in params) {
					findLocalReads(reads, e, fields);
				}
			case EBlock(exprList):
				for (e in exprList) {
					findLocalReads(reads, e, fields);
				}
			case EArray( e1, e2 ):
				findLocalReads(reads, e1, fields);
				findLocalReads(reads, e2, fields);
			case EBinop( op, e1, e2 ):
				findLocalReads(reads, e1, fields);
				findLocalReads(reads, e2, fields);
			case EField( e , field ):
				findLocalReads(reads, e, fields);
				switch(e.expr) {
					case EConst(c):
						switch(c) {
							case CIdent(str):
								if (str == "this" && hasLazyField(fields, field)) {
									if (Lambda.indexOf(reads, field)==-1)reads.push(field);
							
									expr.expr = EField(e, "_"+field);
								}
							default:
						}
					default:
				}
			case EParenthesis( e ):
				findLocalReads(reads, e, fields);
			case EObjectDecl( decFields ):
				for (field in decFields) {
					findLocalReads(reads, field.expr, fields);
				}
			case EArrayDecl( values ):
				for (e in values) {
					findLocalReads(reads, e, fields);
				}
			case EUnop( op, postFix, e ):
				findLocalReads(reads, e, fields);
			case EVars( vars ):
				for (vari in vars) {
					findLocalReads(reads, vari.expr, fields);
				}
			case EFor( it, expr ):
				findLocalReads(reads, expr, fields);
			case EIn( e1, e2 ):
				findLocalReads(reads, e1, fields);
				findLocalReads(reads, e2, fields);
			case EIf( econd, eif, eelse ):
				findLocalReads(reads, econd, fields);
				findLocalReads(reads, eif, fields);
				if(eelse!=null)findLocalReads(reads, eelse, fields);
			case EWhile( econd, e, normalWhile ):
				findLocalReads(reads, econd, fields);
				findLocalReads(reads, e, fields);
			case ESwitch( e, cases, edef  ):
				findLocalReads(reads, e, fields);
				for (caseinfo in cases) {
					findLocalReads(reads, caseinfo.expr, fields);
				}
				if(edef!=null)findLocalReads(reads, edef, fields);
			case ETry( e, catches ):
				findLocalReads(reads, e, fields);
				for (catchinfo in catches) {
					findLocalReads(reads, catchinfo.expr, fields);
				}
			case EReturn( e ):
				if(e!=null)findLocalReads(reads, e, fields);
			case EUntyped( e ):
				findLocalReads(reads, e, fields);
			case EThrow( e ):
				findLocalReads(reads, e, fields);
			case ECast( e, t ):
				findLocalReads(reads, e, fields);
			case EDisplay( e, isCall ):
				findLocalReads(reads, e, fields);
			case ETernary( econd, eif, eelse ):
				findLocalReads(reads, econd, fields);
				findLocalReads(reads, eif, fields);
				findLocalReads(reads, eelse, fields);
			case ECheckType( e, t ):
				findLocalReads(reads, e, fields);
			#if !haxe3
			case EType( e, field ):
				findLocalReads(reads, e, fields);
			#end
			default:
		}
	}
	private static function hasLazyField(fields:Array<ClassField>, fieldName:String):Bool {
		for (field in fields) {
			if (field.name == fieldName) {
				return field.meta.has(_metaName);
			}
		}
		return false;
	}
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
		var kind:FieldType = FieldType.FVar(t, null);
		var privateProp = { kind :kind, meta : [], name : privateName, doc : null, pos : pos, access : [APrivate] };
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