package org.tbyrne.collections;
import haxe.ds.GenericStack;

class UniqueList<T> {
	
	public function new(?list:Iterable<T>) {
		this.list = new GenericStack<T>();
		
		if (list != null) {
			for (item in list) add(item);
		}
	}
	
	public function iterator():Iterator<T> {
		return list.iterator();
	}
	public var length(get, null):Int;
	private function get_length():Int {
		return _length;
	}
	
	
	private var list:GenericStack<T>;
	
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
		list = new GenericStack<T>();
		_length = 0;
	}
}
