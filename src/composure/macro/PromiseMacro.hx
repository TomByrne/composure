package composure.macro;

import haxe.ds.StringMap;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;

class PromiseMacro
{

	/**
	 * 
	 * 
	 * TODO:
	 * - Add code to register promises for each class when first one is instantiated
	 * - Add actual promise checking code below, alt. pass through list of props when calling below.
	 * 
	 * Alternatively:
	 * - Injectors get modified to notify PromiseMacro when changing prop (remove prop/var mods below)
	 * 
	 * 
	 * NEED SOMEWHERE TO STORE STATE? Is this implicit in the pre-check?
	 * 
	 */
	
	macro public static function inject() : Array<Field> {
        var fields:Array<Field> = Context.getBuildFields();
		if (fields.length == 0) return fields;
		
		var classType:ClassType = Context.getLocalClass().get();
		var classPos:Position = Context.getLocalClass().get().pos;
		var constructor:Function;
		var constructorPos:Position;
		var addExpr:Array<Expr> = [];
		
		var watchedNames:Array<Expr> = [];
		var watchedFields:Array<Field> = [];
		var watchedMap:StringMap<Bool> = new StringMap();
		var fieldMap:StringMap<Field> = new StringMap();
		
		var registerExprs:Array<Expr> = [];
		
		for (field in fields) {
			switch(field.kind) {
				case FVar (t, e):
					fieldMap.set(field.name, field);
					
				case FProp (get, set, t, e):
					fieldMap.set(field.name, field);
					
				default:
			}
		}
		
		for (field in fields) {
			if (field.name == "new") {
				switch(field.kind) {
					case FFun( f ):
						constructor = f;
						constructorPos = field.pos;
					default:
				}
			}
			switch(field.kind) {
				case FFun( f ):
					var meta:MetadataEntry = null;
					var mt:MetadataEntry;
					for (mt in field.meta) {
						if (mt.name == "promise") {
							meta = mt;
							break;
						}
					}
					if (meta == null) continue;
					
					if (field.name == "new") {
						throw new Error("Promises are not supported on the constructor", meta.pos);
						
					}else {
						var promiseProps:Array<String> = [];
						if(meta.params!=null){
							for (param in meta.params) {
								switch(param.expr) {
									case EConst(c):
										switch(c) {
											case CString(s):
												if (fieldMap.exists(s)) {
													var f:Field = fieldMap.get(s);
													if (!watchedMap.exists(s)) {
														watchedFields.push(f);
													}
												}else if(findFieldSuper(classType, s) == null){
													throw new Error("Name must match a prop / var on this class", param.pos);
													break;
												}
												promiseProps.push(s);
												
												if (!watchedMap.exists(s)) {
													watchedNames.push(param);
													watchedMap.set(s, true);
												}
											default:
											
										}
									default:
								}
							}
						}
						if (promiseProps.length == 0) {
							throw new Error("Promise metadata should specify a list of property names to watch", meta.pos);
							continue;
						}
						
						var props:Array<Expr> = [];
						var prop:String;
						for ( prop in promiseProps) {
							props.push({ expr : ECall({ expr : EField({ expr : EField({ expr : EField({ expr : EField({ expr : EConst(CIdent("composure")), pos : meta.pos },"prom"), pos : meta.pos },"Promises"), pos : meta.pos },"PromiseReq"), pos : meta.pos },"RProp"), pos : meta.pos },[{ expr : EConst(CString(prop)), pos : meta.pos }]), pos : meta.pos });
						}
						registerExprs.push({ expr : ECall({ expr : EField({ expr : EConst(CIdent("ret")), pos : meta.pos },"push"), pos : meta.pos },[{ expr : EObjectDecl([{ expr : { expr : EConst(CString(field.name)), pos : meta.pos }, field : "methodName" },{ expr : { expr : EArrayDecl(props), pos : meta.pos }, field : "requirements" }]), pos : meta.pos }]), pos : meta.pos });
						
						break;
					}
					
				default:
			}
		}
		
		if (watchedNames.length > 0) {
			
			
			var promiseCallName:String;
			var classNameProp:String;
			var superMeta:MetadataEntry = getSuperPromiseMeta(classType);
			var doOverride:Bool = (superMeta != null);
			var firstExpr:Expr;
			
			if (!doOverride) {
				if(constructor == null)
					throw new Error("PromiseMacro can't operate on classes without a constructor", Context.getLocalClass().get().pos);
				
				// add a String > Bool map to the class to store the state of each promise
				var promiseMetName = findAvailableFieldName(PROMISES_MET_NAME, classType, fields);
				var metProp:FieldType = FVar( null, macro new haxe.ds.StringMap<Bool>() );
				fields.push({ name:promiseMetName, access:[APublic], pos:constructorPos, kind:metProp});
				
				// add a var to store the class name (so we're not constantly working it out)
				classNameProp = findAvailableFieldName(PROMISE_CLASS_PROP, classType, fields);
				var metProp:FieldType = FVar( TPath( { name : "String", pack : []} ) );
				fields.push({ name:classNameProp, access:[APublic], pos:constructorPos, kind:metProp});
				addExpr.push({ expr:EBinop(OpAssign, { expr:EConst(CIdent(classNameProp)), pos:constructorPos }, { expr : ECall( { expr : EField( { expr : EConst(CIdent("Type")), pos : constructorPos }, "getClassName"), pos : constructorPos }, [ { expr : ECall( { expr : EField( { expr : EConst(CIdent("Type")), pos : constructorPos }, "getClass"), pos : constructorPos }, [ { expr : EConst(CIdent("this")), pos : constructorPos } ]), pos : constructorPos } ]), pos : constructorPos } ), pos:constructorPos });
					
				promiseCallName = findAvailableFieldName(PROMISE_CALL_NAME, classType, fields);
				var meta:MetaAccess = classType.meta;
				meta.add(PROMISE_CALL_META, [ { expr : EConst(CString(promiseCallName)), pos:classPos }, { expr : EConst(CString(classNameProp)), pos:classPos } ], classPos);
				
				// add call in constructor to register class (only in top-most promise class), only does anything once per end-class.
				var registerCall:Expr = { expr : EBlock([ { expr : ECall( { expr : EField( { expr : EField( { expr : EField( { expr : EConst(CIdent("composure")), pos : constructorPos }, "prom"), pos : constructorPos }, "Promises"), pos : constructorPos }, "registerOnce"), pos : constructorPos }, [ { expr:EField( { expr:EConst(CIdent("this")), pos:constructorPos }, classNameProp), pos:constructorPos }, { expr : EConst(CString(promiseMetName)), pos : constructorPos }, { expr : EConst(CIdent(promiseCallName)), pos : constructorPos } ]), pos : constructorPos } ]), pos : constructorPos };
				addExpr.push(registerCall);
					
				firstExpr = { expr : EVars([ { expr : { expr : EArrayDecl([]), pos : constructorPos }, name : "ret", type : TPath( { name : "Array", pack : [], params : [TPType(TPath( { name : "Promises", pack : ["composure", "prom"], params : [], sub : "PromiseInfo" } ))] } ) } ]), pos : constructorPos };
			}else {
				var param:Expr;
				var i = 0;
				for (i in 0 ... superMeta.params.length) {
					var param = superMeta.params[i];
					switch(param.expr) {
						case EConst(c):
							switch(c) {
								case CString(s):
									switch(i) {
										case 0:
											promiseCallName = s;
										case 1:
											classNameProp = s;
										default:
									}
								default:
							}
						default:
					}
				}
				firstExpr = { expr : EVars([ { expr : { expr : ECall( { expr : EField( { expr : EConst(CIdent("super")), pos : constructorPos }, promiseCallName), pos : constructorPos }, []), pos : constructorPos }, name : "ret", type : TPath( { name : "Array", pack : [], params : [TPType(TPath( { name : "Promises", pack : ["composure", "prom"], params : [], sub : "PromiseInfo" } ))] } ) } ]), pos : constructorPos };
			}
			
			var block:Array<Expr> = [firstExpr];
			block = block.concat(registerExprs);
			block.push(macro return ret);
			
			// add registration method which provides promise info to the Promises engine
			var access:Array<Access> = [APrivate];
			if (doOverride) access.push(AOverride);
			var func:Function = { args:[], expr:{expr:EBlock(block), pos:constructorPos}, ret:TPath({ name : "Array", pack : [], params : [TPType(TPath({ name : "Promises", pack : ["composure","prom"], params : [], sub : "PromiseInfo" }))] })};
			fields.push( { name:promiseCallName, access:access, pos:constructorPos, kind:FieldType.FFun(func)} );
			
			// make fields notify when changing
			for (field in watchedFields) {
				addPromiseCalls(field, classType, fields, classNameProp);
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
		
		}
		
        return fields;
	}
	#if macro
	
	private static var PROMISE_CALL_META:String = ":promiseInfoCall";
	private static var PROMISE_CALL_NAME:String = "__getPromiseInfo";
	private static var PROMISES_MET_NAME:String = "__promisesMet";
	private static var PROMISE_CLASS_PROP:String = "__promiseClassName";
	private static var OLD_VAL_VAR:String = "__oldVal";
	
	public static function addPromiseCalls(field:Field, type:ClassType, fields:Array<Field>, classNameProp:String):Void {
		switch(field.kind) {
			case FVar( t , e  ):
				var pos = field.pos;
				var setterName:String = findAvailableFieldName("set_" + field.name, type, fields); // should check we're not conflicting with another method
				var func:Function = { args:[ { name:"value", opt:false, type:t, value:null } ], expr:createSetter(field.name, pos, classNameProp), ret:t, params:[] };
				var newField:Field = { name:setterName, doc:field.doc, access:[APrivate], kind:FFun(func), pos:pos, meta:[] };
				fields.push(newField);
				field.kind = FProp("default", setterName, t, e);
				
			case FProp( get , set , t , e  ):
				var setter = findField(set, fields);
				var pos = setter.pos;
				switch(setter.kind) {
					case FFun(f):
						f.expr = modifySetter(field.name, pos, f.expr, f.args[0].name, classNameProp);
					default:
						trace("Setter must be a function");
				}
			default:
		}
	}
	private static function createSetter(name:String, pos:Position, classNameProp:String):Expr {
		var newVal:Expr = { expr:EConst(CIdent("value")), pos:pos };
		var preChangedCall:Array<Expr> = createPreChangedCall(name, pos, newVal, classNameProp);
		var postChangedCall:Expr = createPostChangedCall(name, pos, classNameProp);
		var exprBlock:Array<Expr> = preChangedCall.concat([ { expr:EBinop(OpAssign, { expr:EField( { expr:EConst(CIdent("this")), pos:pos }, name), pos:pos }, newVal ), pos:pos }, postChangedCall ]);
		return { expr:EBlock([ { expr:EIf( { expr:EBinop(OpNotEq, newVal, { expr:EField( { expr:EConst(CIdent("this")), pos:pos }, name), pos:pos } ), pos:pos }, { expr:EBlock(exprBlock), pos:pos }, null), pos:pos }, { expr:EReturn( newVal ), pos:pos } ]), pos:pos };
	}
	private static function modifySetter(name:String, pos:Position, expr:Expr, valueName:String, classNameProp:String, ?parentExpr:Array<Expr>, ?index:Int):Expr {
		switch(expr.expr) {
			case EReturn(retExpr):
				var preChangedCall:Array<Expr> = createPreChangedCall(name, pos, { expr:EConst(CIdent(valueName)), pos:pos }, classNameProp);
				var postChangedCall:Expr = createPostChangedCall(name, pos, classNameProp);
				if (parentExpr == null) {
					return { expr:EBlock(preChangedCall.concat([expr, postChangedCall])), pos:pos };
				}else {
					parentExpr.insert(index + 1, postChangedCall);
					for (i in 0...preChangedCall.length) {
						parentExpr.insert(index+i, preChangedCall[i]);
					}
				}
			case EBlock(exprs):
				for (i in 0...exprs.length) {
					var child = exprs[i];
					var childRet:Expr = modifySetter(name, pos, child, valueName, classNameProp, exprs, i);
				}
			default:
		}
		return expr;
	}
	private static function createPreChangedCall(name:String, pos:Position, newValIdent:Expr, classNameProp:String):Array<Expr> {
		return [
				{ expr : EVars([{ expr : { expr:EField( { expr:EConst(CIdent("this")), pos:pos }, name), pos:pos }, name : OLD_VAL_VAR, type : null }]), pos : pos },
				{ expr:ECall( { expr:EField( { expr:EField( { expr:EField( { expr:EConst(CIdent("composure")), pos:pos }, "prom"), pos:pos }, "Promises"), pos:pos }, "prePropChange"), pos:pos }, [ { expr:EField( { expr:EConst(CIdent("this")), pos:pos }, classNameProp), pos:pos }, { expr:EConst(CIdent("this")), pos:pos }, { expr:EConst(CString(name)), pos:pos }, { expr:EConst(CIdent(OLD_VAL_VAR)), pos:pos }, newValIdent ]), pos:pos }
		];
	}
	private static function createPostChangedCall(name:String, pos:Position, classNameProp:String):Expr {
		return { expr:ECall( { expr:EField( { expr:EField( { expr:EField( { expr:EConst(CIdent("composure")), pos:pos }, "prom"), pos:pos }, "Promises"), pos:pos }, "postPropChange"), pos:pos }, [ { expr:EField( { expr:EConst(CIdent("this")), pos:pos }, classNameProp), pos:pos }, { expr:EConst(CIdent("this")), pos:pos }, { expr:EConst(CString(name)), pos:pos }, { expr:EConst(CIdent(OLD_VAL_VAR)), pos:pos }, { expr:EField( { expr:EConst(CIdent("this")), pos:pos }, name), pos:pos } ]), pos:pos };
	}
	private static function findField(name:String, fields:Array<Field>):Field {
		for (field in fields) {
			if (field.name == name) {
				return field;
			}
		}
		return null;
	}
	private static function findAvailableFieldName(baseName:String, type:ClassType, fields:Array<Field>):String {
		var found:Bool = true;
		var count:Int = 1;
		var name:String = baseName;
		var classFocus:ClassType;
		var classFields:Array<ClassField>;
		while (found) {
			found = false;
			classFocus = type;
			while (true) {
				if(classFocus==type){
					for (field in fields) {
						if (field.name == name) {
							found = true;
							break;
						}
					}
				}else {
					for (field in classFields) {
						if (field.name == name) {
							found = true;
							break;
						}
					}
				}
				if (found) {
					name = baseName + "_"+count;
					++count;
					break;
				}
				if (classFocus.superClass != null) {
					classFocus = classFocus.superClass.t.get();
					classFields = classFocus.fields.get();
				}else {
					break;
				}
			}
		}
		return name;
	}
	
	private static function getSuperPromiseMeta(type:ClassType):MetadataEntry {
		var classFocus:ClassType = type;
		while (true) {
			var metaAccess:MetaAccess = classFocus.meta;
			if(metaAccess.has(PROMISE_CALL_META)){
				var meta:Metadata = metaAccess.get();
				var mt:MetadataEntry;
				for (mt in meta) {
					if (mt.name == PROMISE_CALL_META) {
						return mt;
					}
				}
			}
			if (classFocus.superClass != null) {
				classFocus = classFocus.superClass.t.get();
			}else {
				break;
			}
		}
		return null;
	}
	private static function findFieldSuper(type:ClassType, name:String):ClassField {
		var classFocus:ClassType = type;
		while (true) {
			var fields:Array<ClassField> = classFocus.fields.get();
			var field:ClassField;
			for (field in fields) {
				if (field.name == name) {
					return field;
				}
			}
			if (classFocus.superClass != null) {
				classFocus = classFocus.superClass.t.get();
			}else {
				break;
			}
		}
		return null;
	}
	
	
	#end
	
	
	
}