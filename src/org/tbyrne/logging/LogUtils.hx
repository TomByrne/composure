package org.tbyrne.logging;
import haxe.PosInfos;

/**
 * ...
 * @author Tom Byrne
 */

class LogUtils 
{

	public static function formatMsg(logMsg:LogMsg, addLine:Bool, infos : PosInfos):String {
		var ret:String;
		if (addLine) {
			ret = "\n";
		}else {
			ret = "";
		}
		if (infos!=null) {
			ret += infos.fileName + ":" + infos.lineNumber + ": ";
		}
		if (logMsg.title != null) {
			if (logMsg.message != null) {
				ret += logMsg.title+": "+logMsg.message;
			}else {
				ret += logMsg.title;
			}
		}else if (logMsg.message != null) {
			ret += logMsg.message;
		}
		return ret;
	}
	
}