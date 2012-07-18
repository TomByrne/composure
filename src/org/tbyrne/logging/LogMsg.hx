package org.tbyrne.logging;

/**
 * ...
 * @author Tom Byrne
 */

class LogMsg 
{
	public var id:String; // optional, can be used for readable message mapping, applying icons, styling etc.
	public var message:String;
	public var types:Array<String>;
	public var title:String;
	
	public function new(?message:String, ?types:Array<String>, ?title:String, ?id:String) {
		this.message = message;
		this.types = types;
		this.title = title;
		this.id = id;
	}
	/**
	 * Used by trace when Logging hasn't been setup.
	 */
	public function toString():String {
		var ret:String = "";
		if (types!=null && types.length>0) {
			ret += "[" + types.join(", ") + "] ";
		}
		if (title!=null && title.length>0) ret += title + ": ";
		if (message!=null && message.length>0) ret += message;
		return ret;
	}
}



 // I'd love to do this as an enum, but the LoggerList class uses them as keys, which isn't cross-platform.
class LogType 
{
	
	// These are aimed for dev consumption
	public static var devInfo:String;				// Traces
	public static var devWarning:String;				// Suspicious implementations etc.
	public static var devError:String;				// Internal code errors etc.
	
	// These are aimed for user consumption
	public static var userInfo:String;				// Interaction tips, etc.
	public static var userWarning:String;			// Pre-submit validation, etc.
	public static var userError:String;				// Post-submit validation etc.
	
	// These are typically warnings used in library code for other developers' consumption.
	public static var performanceWarning:String;	
	public static var deprecationWarning:String;

	public static var externalError:String;			// An external app/service/request has failed.
	
	
	
	static function __init__():Void {
		devInfo = "devInfo";
		devWarning = "devWarning";
		devError = "devError";
		userInfo = "userInfo";
		userWarning = "userWarning";
		userError = "userError";
		performanceWarning = "performanceWarning";
		deprecationWarning = "deprecationWarning";
		externalError = "externalError";
	}
}