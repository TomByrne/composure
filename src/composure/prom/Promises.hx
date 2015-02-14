package composure.prom;
import haxe.ds.StringMap;


class Promises
{
	private static var _typeInfo:StringMap<PromiseClassInfo> = new StringMap();
	
	public static inline function isRegistered(typeName:String):Bool {
		return (_typeInfo.exists(typeName));
	}
	public static inline function registerTypePromises(typeName:String, promisesMetProp:String, promiseInfo:Array<PromiseInfo>):Void {
		var backMap:StringMap<Array<PromiseInfo>> = new StringMap();
		var prom:PromiseInfo;
		for (prom in promiseInfo) {
			var req:PromiseReq;
			for (req in prom.requirements) {
				switch(req) {
					case RProp(propName):
						var list:Array<PromiseInfo> = backMap.get(propName);
						if (list==null) {
							list = [prom];
							backMap.set(propName, list);
						}else {
							list.push(prom);
						}
				}
			}
		}
		_typeInfo.set(typeName, { typeName:typeName, promisesMetProp:promisesMetProp, promiseInfo:promiseInfo, backMap:backMap });
	}
	public static inline function registerOnce(typeName:String, promisesMetProp:String, promiseInfoGenerator:Void -> Array<PromiseInfo>):Void {
		if(!isRegistered(typeName)){
			registerTypePromises(typeName, promisesMetProp, promiseInfoGenerator());
		}
	}
	public static function prePropChange(typeName:String, target:Dynamic , prop:String, oldValue:Dynamic, newValue:Dynamic):Void {
		if (oldValue == newValue) return;
		
		var classInfo:PromiseClassInfo = _typeInfo.get(typeName);
		var list:Array<PromiseInfo> = classInfo.backMap.get(prop);
		var prom:PromiseInfo;
		var metMap:StringMap<Bool> = Reflect.getProperty(target, classInfo.promisesMetProp);
		for (prom in list) {
			if (metMap.get(prom.methodName)) {
				Reflect.callMethod(target, Reflect.field(target, prom.methodName), [false]);
				metMap.remove(prom.methodName);
			}
		}
	}
	public static function postPropChange(typeName:String, target:Dynamic, prop:String, oldValue:Dynamic, newValue:Dynamic):Void {
		if (oldValue == newValue) return;
		
		var classInfo:PromiseClassInfo = _typeInfo.get(typeName);
		var list:Array<PromiseInfo> = classInfo.backMap.get(prop);
		var prom:PromiseInfo;
		var metMap:StringMap<Bool> = Reflect.getProperty(target, classInfo.promisesMetProp);
		for (prom in list) {
			var isReady:Bool = true;
			var req:PromiseReq;
			for (req in prom.requirements) {
				switch(req) {
					case RProp(propName):
						if (Reflect.getProperty(target, propName) == null) {
							isReady = false;
							break;
						}
				}
			}
			
			if (isReady) {
				Reflect.callMethod(target, Reflect.field(target, prom.methodName), [true]);
				metMap.set(prom.methodName, true);
			}
		}
	}
	
}
typedef PromiseClassInfo = {
	var typeName:String;
	var promisesMetProp:String;
	var promiseInfo:Array<PromiseInfo>;
	var backMap:StringMap<Array<PromiseInfo>>;
}
typedef PromiseInfo = {
	var methodName:String;
	var requirements:Array<PromiseReq>;
}
enum PromiseReq {
	RProp(propName:String);
}