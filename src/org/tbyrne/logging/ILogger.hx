package org.tbyrne.logging;

import haxe.Log;
import haxe.PosInfos;
/**
 * ...
 * @author Tom Byrne
 */

interface ILogger 
{
	function log(logMsg:LogMsg, ?infos : PosInfos):Void;
}