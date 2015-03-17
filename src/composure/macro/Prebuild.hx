package composure.macro;
import composure.macro.Prebuild.TraitInfo;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class Prebuild
{
	/**
	 * Sets whether a warning is output whenever a prebuild is defined.
	 */
	macro public static function setVerbose(value:Bool):Expr{
		verbose = value;
		return macro null;
	}

	/**
	 * Defines a Prebuild item which can be easily created with all binding between the traits already resolved at compile-time.
	 * @param id An id string for this prebuild.
	 * @param compileBindings An array of trait classes which will be created and bound amoung one another (including the compile-time traits). These items will not be added as traits to the item for runtime binding.
	 * @param runtimeBindings An array of trait classes which will be created and bound amoung one another (including the runtime traits). These items are added to the item as traits and are available for runtime binding.
	 * @param itemType An optional class reference which specifies the class used for the created item (defaults to ComposeGroup).
	 */
	macro public static function define(id:Expr, compileBindings:Expr, runtimeBindings:Expr, ?itemType:Expr):Expr
	{
		var idStr = getId(id, Context.getLocalClass().get());
		var compileList = getArrayContents(compileBindings);
		var runtimeList = getArrayContents(runtimeBindings);
		if (verbose) Context.warning("Defining prebuild '"+idStr+"' with "+compileList.length+" compile-time traits and "+runtimeList.length+" runtime traits", Context.currentPos());
		if (isIdent(itemType, 'null')) itemType = null;
		defined.set(idStr, { compileBindings:compileList, runtimeBindings:runtimeList, itemType:itemType } );
		return macro null;
	}


	/**
	 * Creates an instance of an item previously defined with the 'define' method.
	 * @param id The id string of this prebuild (as specified in the 'define' call).
	 */
	macro public static function get(id:Expr):Expr
	{
		var idStr = getId(id, Context.getLocalClass().get());
		var pos = Context.currentPos();
		if (!defined.exists(idStr)) {
			throw new Error("Can't find a predefined item with id: "+id, pos);
		}
		
		var predef:PreDefined = defined.get(idStr);
		return doMake(predef.compileBindings, predef.runtimeBindings, predef.itemType, pos);
	}

	/**
	 * Creates a prebuild item.
	 * @param compileBindings An array of trait classes which will be created and bound amoung one another (including the compile-time traits). These items will not be added as traits to the item for runtime binding.
	 * @param runtimeBindings An array of trait classes which will be created and bound amoung one another (including the runtime traits). These items are added to the item as traits and are available for runtime binding.
	 * @param itemType An optional class reference which specifies the class used for the created item (defaults to ComposeGroup).
	 */
	macro public static function make(compileBindings:Expr, runtimeBindings:Expr, ?itemType:Expr):Expr
	{
		var pos = Context.currentPos();
		return doMake(getArrayContents(compileBindings), getArrayContents(runtimeBindings), itemType, pos);
	}
	
	#if macro
	
	private static var defined:Map<String, PreDefined> = new Map();
	private static var verbose:Bool = false;

	private static function getArrayContents(arrayExpr:Expr):Array<Expr>
	{
		switch(arrayExpr.expr) {
			case EArrayDecl(contents):
				return contents;
			default:
				throw new Error("This argument must be an array of trait classes", arrayExpr.pos);
		}
	}
	
	private static var PREBUILD_ID:String = "_prebuilt__";
	private static var PREBUILD_COUNT:Int = 0;
	

	private static function doMake(compileTraits:Array<Expr>, runtimeTraits:Array<Expr>, itemType:Expr, pos:Position):Expr
	{
		var id:String = PREBUILD_ID + PREBUILD_COUNT++;
		
		var block : Array<Expr> = [];
		if (itemType == null) {
			itemType = convertToConstructor(new TraitInfo("ComposeGroup", ["composure", "core"], pos));
		}else {
			itemType = convertToConstructor(getTraitInfo(itemType, itemType.pos));
		}
		block.push( { expr : EVars([ { expr : itemType, name : id, type : null } ]), pos : pos } );
		
		var allTraits = compileTraits.concat(runtimeTraits);
		
		var traitInfos:Array<TraitInfo> = [];
		// Create all traits
		for (traitClass in allTraits) {
			var traitId:String = PREBUILD_ID + PREBUILD_COUNT++;
			var traitInfo:TraitInfo = getTraitInfo(traitClass, pos);
			traitInfo.localVarName = traitId;
			traitInfos.push(traitInfo);
			block.push( { expr : EVars([ { expr : convertToConstructor(traitInfo), name : traitId, type : null } ]), pos : traitClass.pos } );
			var traitType:Type = Context.getType(traitInfo.classpath);
			
			traitInfo.type = traitType;
			traitInfo.classpath = getClassPathFromType(traitType, traitClass.pos);
			
			if (traitType==null) {
				throw new Error("Can't resolve type: "+traitInfo.classpath+" please use fully resolved class paths", traitClass.pos);
			}
			switch(traitType) {
				case TInst(t, params):
					var traitClassType:ClassType = t.get();
					if (traitClassType==null) {
						throw new Error("This type cannot has not been compiled yet and cannot be accessed.", traitClass.pos);
					}
					var fields:Array<ClassField> = traitClassType.fields.get();
					if (fields==null) {
						continue;
					}
					for (field in fields) {
						switch(field.kind) {
							case FVar(read, write):
								if ( field.meta.has(":inject") ) {
									//switch(write) {
									traitInfo.injectProps.push(new FieldInfo(field, field.type));
								}
							case FMethod(k):
								if ( field.meta.has(":injectAdd") ) {
									var t = Context.follow(field.type);
									switch(t) {
										case TFun(args, ret):
											if (args.length != 1) {
												throw new Error(":injectAdd methods must have exactly one argument.", field.pos);
											}
											traitInfo.injectMeths.push(new FieldInfo(field, args[0].t));
										default:
											trace("HM: "+field.type);
									}
								}
						}
					}
				default:
					throw new Error("Can't use instantiate this type as a trait", traitClass.pos);
			}
		}
		// Bind all traits
		for (traitInfo1 in traitInfos) {
			for (field in traitInfo1.injectProps) {
				var pos = field.field.pos;
				var fieldCP:String = getClassPathFromType(field.type, pos);
				for (traitInfo2 in traitInfos) {
					if (traitInfo2 == traitInfo1) continue;
					if (fieldCP==traitInfo2.classpath || MacroUtils.doesTypeInherit(fieldCP, traitInfo2.type)) {
						block.push({ expr : EBinop(OpAssign,{ expr : EField({ expr : EConst(CIdent(traitInfo1.localVarName)), pos : pos }, field.field.name), pos : pos },{ expr : EConst(CIdent(traitInfo2.localVarName)), pos : pos }), pos : pos });
					}
				}
			}
			for (field in traitInfo1.injectMeths) {
				var pos = field.field.pos;
				var fieldCP:String = getClassPathFromType(field.type, field.field.pos);
				for (traitInfo2 in traitInfos) {
					if (traitInfo2 == traitInfo1) continue;
					if (fieldCP==traitInfo2.classpath || MacroUtils.doesTypeInherit(fieldCP, traitInfo2.type)) {
						block.push({ expr : ECall({ expr : EField({ expr : EConst(CIdent(traitInfo1.localVarName)), pos : pos },field.field.name), pos : pos },[{ expr : EConst(CIdent(traitInfo2.localVarName)), pos : pos }]), pos : pos });
					}
				}
			}
		}
		// Add all traits
		for (i in 0...traitInfos.length) {
			if (i >= compileTraits.length) {
				var traitInfo = traitInfos[i];
				block.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent(id)), pos : pos }, "addTrait"), pos : pos }, [ { expr : EConst(CIdent(traitInfo.localVarName)), pos : pos } ]), pos : pos } );
			}
		}
		
		block.push( { expr : EConst(CIdent(id)), pos : pos } );
		return { expr:EBlock(block), pos:pos };
	}
	
	private static function getClassPathFromType(type:Type, pos:Position):String {
		
		switch(type) {
			case TInst(t, params):
				var type:ClassType = t.get();
				if(type==null){
					throw new Error("Injection type isn't available yet.", pos);
				}
				return MacroUtils.getClassTypePath(type);
				
			default:
				throw new Error("Can't inject this type", pos);
		}
	}
	

	private static function getTraitInfo(type:Expr, pos:Position):TraitInfo
	{
		var className:String;
		var packageParts:Array<String> = [];
		var focus:ExprDef = type.expr;
		while (focus != null) {
			switch(focus) {
				case EField(e, field):
					if (className == null) {
						className = field;
					}else {
						packageParts.unshift(field);
					}
					focus = e.expr;
				case EConst(c):
					switch(c) {
						case CIdent(s):
							if (className == null) {
								className = s;
							}else {
								packageParts.unshift(s);
							};
						default:
							throw new Error("This argument must be a class", pos);
					}
					focus = null;
				default:
					throw new Error("This argument must be a class", pos);
					focus = null;
			}
		}
		return new TraitInfo(className, packageParts, pos); 
	}
	

	private static function isIdent(expr:Expr, ident:String):Bool
	{
		switch(expr.expr) {
			case EConst(c):
				switch(c){
					case CIdent(s):
						return ident == s;
					default:
				}
			default:
		}
		return false;
	}
	

	private static function convertToConstructor(traitInfo:TraitInfo):Expr
	{
		return { expr : ENew( { name : traitInfo.name, pack : traitInfo.pack, params : [] }, []), pos : traitInfo.pos };
	}
	

	private static function getId(expr:Expr, contextClass:ClassType):String
	{
		var field;
		switch(expr.expr) {
			case EField(e, f):
				var type = getType(e);
				if (type!=null) {
					field = TypeTools.findField(type, f, true);
				}
			case EConst(c):
				switch(c) {
					case CString(s):
						return s;
					case CIdent(s):
						field = TypeTools.findField(contextClass, s, true);
					default:
				}
			default:
		}
		if(field!=null){
			var ex = field.expr();
			if (ex != null) return getStr(ex);
		}
		throw new Error("Couldn't resolve this value to an id string", expr.pos);
	}
	

	private static function getType(expr:Expr, pack:String=""):Null<ClassType>
	{
		switch(expr.expr) {
			case EField(e, field):
				return getType(e, pack+field+".");
				
			case EConst(c):
				switch(c) {
					case CIdent(s):
						var t = Context.getType(pack + s);
						t = Context.follow(t);
						switch(t) {
							case TInst(t, params):
								return t.get();
							default:
						}
					default:
				}
			default:
		}
		return null;
	}
	

	private static function getStr(expr:TypedExpr):Null<String>
	{
		switch(expr.expr) {
			case TConst(c):
				switch(c) {
					case TString(s):
						return s;
					default:
				}
			default:
		}
		return null;
	}
	
	
	#end
	
}
#if macro

class TraitInfo {
	
	public function new(name:String, pack:Array<String>, pos:Position) {
		this.name = name;
		this.pack = pack;
		this.pos = pos;
		
		injectProps = [];
		injectMeths = [];
		
		if (this.pack.length > 0) {
			this.classpath = pack.join(".") + "." + name;
		}else {
			this.classpath = name;
		}
	}
	
	public var pos:Position;
	public var name:String;
	public var type:Type;
	public var classpath:String;
	public var pack:Array<String>;
	public var localVarName:String;
	
	public var injectProps:Array<FieldInfo>;
	public var injectMeths:Array<FieldInfo>;
}

class FieldInfo {
	public var field:ClassField;
	public var type:Type;
	
	public function new(field:ClassField, type:Type) {
		this.field = field;
		this.type = type;
	}
	
}

typedef PreDefined = {
	var compileBindings:Array<Expr>;
	var runtimeBindings:Array<Expr>;
	var itemType:Expr;
}


#end