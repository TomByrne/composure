package org.tbyrne.logging;
import haxe.Log;
import haxe.PosInfos;
import org.tbyrne.logging.loggers.ErrorThrowingLogger;
import org.tbyrne.logging.loggers.FlashTraceLogger;
import org.tbyrne.logging.loggers.HaxeLogger;
import org.tbyrne.logging.LogMsg;

/**
 * ...
 * @author Tom Byrne
 */

class LoggerList 
{
	public static var nativeTrace(get_nativeTrace, null):Dynamic;
	static function get_nativeTrace():Dynamic
	{
		return _nativeTrace;
	}
	
	
	public static var fallbackLogger:ILogger;
	
	static function __init__():Void {
		_nativeTrace = Log.trace;
		defaultTypes = [LogType.devInfo];
	}
	private static var _nativeTrace:Dynamic;
	private static var _loggers:Hash<Array<ILogger>>;
	
	public static var defaultTypes:Array<String>;
	
	
	public static function install():Void {
		Log.trace = trace;
		if (fallbackLogger == null) {
			#if flash
			fallbackLogger = new FlashTraceLogger();
			addLogger(new ErrorThrowingLogger(), [LogType.devError, LogType.externalError]);
			#else
			fallbackLogger = new HaxeLogger();
			#end
		}
	}

	public static function trace( v : Dynamic, ?infos : PosInfos):Void {
		if (Std.is(v, LogMsg)) {
			log(v, infos);
		}else if(_nativeTrace!=null){
			_nativeTrace(v,infos);
		}
	}

	public static function log( logMsg : LogMsg, ?infos : PosInfos):Void {
		var types = logMsg.types;
		if (types == null) {
			if (defaultTypes == null) {
				Log.trace(new LogMsg("LoggerList.defaultTypes is not set, unable to Log",[LogType.devError]));
				return;
			}
			types = defaultTypes;
		}
		var found:Bool = false;
		if(_loggers!=null){
			for (type in types) {
				var list:Array<ILogger> = _loggers.get(type);
				if (list != null) {
					for (logger in list) {
						found = true;
						logger.log(logMsg,infos);
					}
				}
			}
		}
		if (!found && fallbackLogger!=null) {
			fallbackLogger.log(logMsg,infos);
		}
	}

	public static function addLogger( logger:ILogger , types:Array<String>):Void {
		if (_loggers == null) {
			_loggers = new Hash<Array<ILogger>>();
		}
		for (type in types) {
			var list:Array<ILogger> = _loggers.get(type);
			if (list == null) {
				list = new Array<ILogger>();
				_loggers.set(type, list);
			}
			list.push(logger);
		}
	}
	
}