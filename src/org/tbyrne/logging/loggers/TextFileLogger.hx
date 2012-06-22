package org.tbyrne.logging.loggers;

/**
 * ...
 * @author Tom Byrne
 */
import haxe.PosInfos;
import org.tbyrne.logging.ILogger;
import org.tbyrne.logging.LoggerList;
import org.tbyrne.logging.LogMsg;


#if php
typedef File = php.io.File;
#elseif cpp
typedef File = cpp.io.File;
#elseif neko
typedef File = neko.io.File;
#end

import org.tbyrne.logging.LogUtils;

class TextFileLogger implements ILogger
{
	public var fileUrl:String;
	
	private var _open:Bool;
	private var _lineCount:Int;

	public function new(fileUrl:String) 
	{
		_lineCount = 0;
		this.fileUrl = fileUrl;
	}
	public function log(logMsg:LogMsg, ?infos : PosInfos):Void {
		#if (php || neko || cpp)
		if(_open!=true){
			_open = true;
		}
		var fout = File.append(fileUrl,false);
        fout.writeString(formatMsg(logMsg,_lineCount));
        fout.close();
		
		++_lineCount;
		#else
		if (LoggerList.fallbackLogger != null) {
			LoggerList.fallbackLogger.log(logMsg, infos);
		}
		#end
	}
	private function formatMsg(logMsg:LogMsg, lineCount:Int, ?infos : PosInfos):String {
		return LogUtils.formatMsg(logMsg, lineCount > 0, infos);
	}
}