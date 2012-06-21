package org.tbyrne.collections;

import time.types.ds.ObjectHash;

// TODO: pooling
class IndexedList<T> {
	
	public function new(?list:Array<T>) {
		this.list = list;
	}
	
	
	private var _indices:ObjectHash<T,Int>;
	public var list(getlist, setlist):Array<T>;
	
	function getlist():Array<T> {
		if (this.list == null) {
			_indices = new ObjectHash<T,Int>();
			this.list = new Array<T>();
		}
		return list;
	}
	function setlist(value:Array<T>):Array<T> {
		if(value!=null){
			_indices = new ObjectHash();
			var i:Int = 0;
			while ( i < value.length) {
				var item:T = value[i];
				if (_indices.exists(item)) {
					value.splice(i, 1);
				}else{
					_indices.set(item, i);
					++i;
				}
			}
		}else {
			_indices = null;
		}
		this.list = value;
		return value;
	}
	
	
	public function add(value:T):Bool {
		list; // will create list if needed
		if(!_indices.exists(value)){
			_indices.set(value,list.length);
			list.push(value);
			return true;
		}else{
			return false;
		}
	}
	public function remove(value:T):Bool{
		if(list!=null && _indices.exists(value)){
			var index:Int = _indices.get(value);
			_indices.remove(value);
			list.splice(index,1);
			while(index<list.length){
				_indices.set(list[index],index);
				++index;
			}
			return true;
		}else{
			return false;
		}
	}
	public function containsItem(value:T):Bool{
		return (list!=null && _indices.get(value)!=null);
	}
	public function clear():Void{
		if(list!=null){
			list = null;
			_indices = null;
		}
	}
}
