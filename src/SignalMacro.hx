package ;


import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.Log;
import msignal.Signal;

/**
 * @author Tom Byrne
 */

class SignalMacro 
{
	private static var TYPE_PARAM_PATTERN:EReg = ~/^(.*?)<(.*)>$/;

	@:macro public static function add(signals:Expr) :Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();
		var pos:Position = Context.getLocalClass().get().pos;
		
		/*for (field in fields) {
			trace(field);
		}*/
		
		var signalNames:Array<String> = [];
		var signalInfos:Array<SignalInfo> = [];
		var wrongFormat:Bool;
		switch(signals.expr) {
			case EObjectDecl(fields):
				for (field in fields) {
					var name:String = field.field;
					var typeList:Array<TypeParam> = [];
					signalNames.push(name);
					
					switch(field.expr.expr) {
						case EArrayDecl(values):
							if (values.length > 0) {
								for (value in values) {
									switch(value.expr) {
										case EConst(c):
											switch(c) {
												case CIdent(name):
													typeList.push(TPType(TPath( { name : name, pack : [], params : [], sub : null } )));
												case CString(str): // this is a bit of a hack to allow type parameters
													typeList.push(createTypeFromString(str));
												default: wrongFormat = true;
											}
										default: wrongFormat = true;
									}
								}
							}
						case EConst(const):
							if(!isEmptyConst(const))wrongFormat = true;
						default:
							wrongFormat = true;
							break;
					}
					signalNames.push(name);
					signalInfos.push( { name:name, pos:field.expr.pos, typeList:typeList } );
				}
			default:
				wrongFormat = true;
		}
		if (wrongFormat) {
			throw new Error("Signals should be declared as an object declaration, e.g: {buttonPressed:[Button], buttonReleased:[Button]}", pos);
			return fields;
		}
		
		for (signalInfo in signalInfos) {
			
			var signalName:String = signalInfo.name;
			var getterName:String = "get_" + signalName;
			var privateName:String = "_" + signalName;
			
			var pos:Position = signalInfo.pos;
			var typeList:Array<TypeParam> = signalInfo.typeList;
			var signalType:String = "Signal" + typeList.length;
			
			checkForField(fields, signalName, pos);
			checkForField(fields, getterName, pos);
			checkForField(fields, privateName, pos);
			
			// add private property
			var privateProp = { kind : FVar(TPath( { name : signalType, pack : [], params : typeList, sub : null } ), null), meta : [], name : privateName, doc : null, pos : pos, access : [APrivate] };
			fields.push(privateProp);
			// add getter function
			var getterFunc = { kind : FFun( { args : [], expr : { expr : EBlock([ { expr : EIf( { expr : EBinop(OpEq, { expr : EConst(CIdent(privateName)), pos : pos }, { expr : EConst(CIdent("null")), pos : pos } ), pos : pos }, { expr : EBinop(OpAssign, { expr : EConst(CIdent(privateName)), pos : pos }, { expr : ENew( { name : signalType, pack : [], params : [], sub : null }, []), pos : pos } ), pos : pos }, null), pos : pos }, { expr : EReturn( { expr : EConst(CIdent(privateName)), pos : pos } ), pos : pos } ]), pos : pos }, params : [], ret : TPath( { name : signalType, pack : [], params : typeList, sub : null } ) } ), meta : [], name : getterName, doc : null, pos : pos, access : [APrivate] };
			fields.push(getterFunc);
			// add public property
			var publicProp = { kind : FProp(getterName, "null", TPath( { name : signalType, pack : [], params : typeList, sub : null } ), null), meta : [], name : signalName, doc : null, pos : pos, access : [APublic] };
			fields.push(publicProp);
			
			
			// All in all, it adds something like this:
			/*
			public var mySignal(get_mySignal, null):Signal1<TypeParam<Dynamic>>;
			private function get_mySignal():Signal1<TypeParam<Dynamic>>{
				if (_mySignal == null)_mySignal = new Signal1();
				return _mySignal;
			}
			private var _mySignal:Signal1<TypeParam<Dynamic>>;
			*/
		}
		
		
		return fields;
	}
	@:macro public static function dispatch(signalName:Expr, params:Array<Expr>):Expr 
	{
		// The dispatch macro adds something like this:
		//if (_mySignal != null)_mySignal.dispatch(typeParam);
		
		var pos:Position = Context.currentPos();
		
		var wrongFormat:Bool;
		var privateName:String;
		switch(signalName.expr) {
			case EConst(c):
				switch(c) {
					case CString(str):
						privateName = "_" + str;
					default:
						wrongFormat = true;
				}
			default:
				wrongFormat = true;
		}
		if (wrongFormat) {
			throw new Error("Signal dispatching must use a signal name as listed in the class build metadata.", pos);
			return null;
		}
		
		return { expr : EIf( { expr : EBinop(OpNotEq, { expr : EConst(CIdent(privateName)), pos : pos }, { expr : EConst(CIdent("null")), pos : pos } ), pos : pos }, { expr : ECall( { expr : EField( { expr : EConst(CIdent(privateName)), pos : pos }, "dispatch"), pos : pos }, params), pos : pos }, null), pos : pos };
	}
	
	#if macro
	private static function isEmptyConst(const:Constant):Bool {
		switch(const){
			case CIdent(name):
				if (name == "null" || name == "Void") {
					return true;
				}else {
					return false;
				}
			default:
				return false;
		}
	}
	
	private static function checkForField(fields:Array<Field>, name:String, pos:Position):Void {
		for (field in fields) {
			if (field.name==name) {
				throw new Error("Signal cannot be created as there is already a field with the name " + field.name, pos);
			}
		}
	}
	
	private static function createTypeFromString(str:String):TypeParam {
		//TPType(TPath( { name : TraitPair, pack : [], params : [TPType(TPath( { name : Dynamic, pack : [], params : [], sub : null } ))], sub : null } ))
		if (TYPE_PARAM_PATTERN.match(str)) {
			// this isn't the fastest way to parse these strings, but saves us adding in more dependencies
			var typeName:String = TYPE_PARAM_PATTERN.matched(1);
			var paramStr:String = TYPE_PARAM_PATTERN.matched(2);
			var params:Array<TypeParam> = [];
			if(paramStr.length>0){
				var start:Int = 0;
				var i:Int = 0;
				var open:Int = 0;
				while (i < paramStr.length) {
					var char:String = paramStr.charAt(i);
					if (char == ",") {
						if (open == 0) {
							params.push(createTypeFromString(paramStr.substr(start, i)));
							start = i + 1;
						}
					}else if (char == "<") {
						open++;
					}else if (char == ">") {
						open--;
					}
					++i;
				}
				var typeStr:String = paramStr.substr(start, i);
				params.push(createTypeFromString(typeStr));
			}
			return TPType(TPath( { name : typeName, pack : [], params : params, sub : null } ));
		}else {
			return TPType(TPath( { name : str, pack : [], params : [], sub : null } ));
		}
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