package org.tbyrne.logging.loggers;
import org.tbyrne.logging.ILogger;
import haxe.Log;
import haxe.PosInfos;
import org.tbyrne.logging.LoggerList;

/**
 * ...
 * @author Tom Byrne
 */

class HaxeLogger implements ILogger
{
	public function new(){
		
	}
	public function log(logMsg:LogMsg, ?infos : PosInfos):Void{
		LoggerList.nativeTrace(formatMsg(logMsg,infos),infos);
	}
	private function formatMsg(logMsg:LogMsg, ?infos : PosInfos):String {
		if (logMsg.title != null) {
			if (logMsg.message != null) {
				return logMsg.title+": "+logMsg.message;
			}else {
				return logMsg.title;
			}
		}else if (logMsg.message != null) {
			return logMsg.message;
		}
		return logMsg.id;
	}
	
}