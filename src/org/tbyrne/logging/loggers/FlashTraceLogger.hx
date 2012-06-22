package org.tbyrne.logging.loggers;

import haxe.PosInfos;
import org.tbyrne.logging.ILogger;
import org.tbyrne.logging.LogUtils;
import org.tbyrne.logging.LoggerList;

/**
 * ...
 * @author Tom Byrne
 */

class FlashTraceLogger implements ILogger
{

	public function new() 
	{
	}
	public function log(logMsg:LogMsg, ?infos : PosInfos):Void {
		var message = formatMsg(logMsg, infos);
		
		#if (flash9 || flash10)
		untyped __global__["trace"](message);
		#elseif flash
		flash.Lib.trace(message);
		#else
		if (LoggerList.fallbackLogger != null) {
			LoggerList.fallbackLogger.log(logMsg, infos);
		}
		#end
	}
	private function formatMsg(logMsg:LogMsg, ?infos : PosInfos):String {
		return LogUtils.formatMsg(logMsg, false, infos);
	}
	
}