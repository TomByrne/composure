package org.tbyrne.logging.loggers;
import org.tbyrne.logging.ILogger;
import haxe.io.Error;
import org.tbyrne.logging.LogUtils;
import haxe.PosInfos;

/**
 * ...
 * @author Tom Byrne
 */

class ErrorThrowingLogger implements ILogger
{

	public function new() 
	{
		
	}
	public function log(logMsg:LogMsg, ?infos : PosInfos):Void {
		throw formatMsg(logMsg, infos);
	}
	private function formatMsg(logMsg:LogMsg, ?infos : PosInfos):String {
		return LogUtils.formatMsg(logMsg, false, infos);
	}
	
}