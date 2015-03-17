package composure.macro;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroUtils
{
	#if macro
	public static function makeAccessPublic(field:Field):Void {
		field.access = [APublic];
	}
	public static function doesTypeInherit(classpath:String, type:Type):Bool {
		switch(type) {
			
			case TMono( t ):
				return doesTypeInherit(classpath, t.get());
			case TDynamic( t ):
				if (t == null) return false;
				else return doesTypeInherit(classpath, t);
			case TType( t , _ ):
				return doesTypeInherit(classpath, t.get().type);
			case TInst( t , _ ):
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
	public static function getClassTypePath(t:ClassType):String {
		if(t.pack.length>0){
			return t.pack.join(".") + "."+t.name;
		}else {
			return t.name;
		}
	}
	#end
	
}