package org.tbyrne.collections;
import haxe.FastList;

// TODO: pooling
class UniqueList<T> {
	
	public function new(?list:Iterable<T>) {
		#if flash
		this.list = new FastList<T>();
		#else
		this.list = new List<T>();
		#end
		
		if (list != null) {
			for (item in list) add(item);
		}
	}
	
	public function iterator():Iterator<T> {
		return list.iterator();
	}
	public var length(get_length, never):Int;
	private function get_length():Int {
		return _length;
	}
	
	
	#if flash
	private var list:FastList<T>;
	#else
	private var list:List<T>;
	#end
	
	private var _length:Int = 0;
	
	public function first():Null<T> {
		return list.first();
	}
	
	public function add(value:T):Bool {
		if (!containsItem(value)) {
			++_length;
			list.add(value);
			return true;
		}
		return false;
	}
	public function containsItem(value:T):Bool {
		return Lambda.exists(list, function(item):Bool { return value == item; } );
	}
	public function remove(value:T):Bool {
		if (list.remove(value)) {
			--_length;
			return true;
		}else {
			return false;
		}
	}
	public function clear():Void{
		#if flash
		list = new FastList<T>();
		#else
		list = new List<T>();
		#end
		_length = 0;
	}
}
