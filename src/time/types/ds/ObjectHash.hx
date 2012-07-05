/**
 * ...
 * @author waneck
 */

package time.types.ds;
import haxe.Serializer;
import haxe.Unserializer;

class ObjectHash<Key, Val>
{
	private static inline var SAFE_NUM = #if neko 1073741823 #else 2147483647 #end;
	private static var clsId:Int = 0;

#if php
	private var ival:Hash<Array<Dynamic>>;
#elseif flash9
	private var ival:flash.utils.Dictionary;
#else
	private var ival:IntHash<Array<Dynamic>>;
#end

	public var length(default, null):Int;

	public function new()
	{
#if php
		ival = new Hash();
#elseif flash9
		ival = new flash.utils.Dictionary();
#else
		ival = new IntHash();
#end

		length = 0;
	}

	public function set(k:Key, v:Val)
	{
#if flash9
		var mv = get(k);
		if (mv != v)
		{
			if (v == null)
				length--;
			else
				length++;
			untyped ival[k] = v;
		}

#else
		var oid = getObjectId(k);

		var g = ival.get(oid);
		if (g == null)
		{
			g = [];
			ival.set(oid, g);
		}

		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				g[i + 1] = v;
				return;
			}

			i += 2;
		}

		g.push(k);
		g.push(v);

		length++;
#end
	}

	static #if php inline #end function hashString(str:String)
	{
#if php
		return str;
#else
		var h = 0;
		for (i in 0...str.length)
		{
			var i = StringTools.fastCodeAt(str, i);

			h += (i << 5) - i;
		}

		return h;
#end
	}


	private #if (php || java || cs) inline #end function getObjectId(obj:Dynamic):#if !php Int #else String #end untyped
	{
		if (Std.is(obj, String)) return hashString(obj);
		else
		{
	#if cpp
			return __global__.__hxcpp_obj_id(obj);
	#elseif (neko || js || flash)
			if (Std.is(obj, Class))
			{
				if (obj.__cls_id__ == null)
					obj.__cls_id__ = clsId++;
				return obj.__cls_id__;
			} else {
	#if neko
				if (__dollar__typeof(obj) == __dollar__tfunction)
					return 0;
	#end
				if (obj.__get_id__ == null)
				{
					var cls:Dynamic = Type.getClass(obj);
					if (cls == null)
					{
						var id = Std.random(SAFE_NUM);
						obj.__get_id__ = function() return id;
						return id;
					}

					var fstid = Std.random(SAFE_NUM);
					cls.prototype.__get_id__ = function()
					{
						if (__this__.___id___ == null)
						{
							return __this__.___id___ = Std.random(SAFE_NUM);
						}
						return __this__.___id___;
					}
				}
				return obj.__get_id__();
			}
	#elseif php
			if (Reflect.isFunction(obj))
				return "fun";
			else
				return __call__('spl_object_hash', obj);
	#elseif java
			return obj.hashCode();
	#elseif cs
			return obj.GetHashCode();
	#else
			return null;
			//UnsupportedPlatform
	#end
		}
	}

	public function get(k:Key):Null<Val>
	{
#if flash9
		return untyped ival[k];
#else
		if (k == null)
			return null;
		var oid = getObjectId(k);

		var g = ival.get(oid);
		if (g == null)
		{
			return null;
		}

		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				return g[i + 1];
			}

			i += 2;
		}

		return null;
#end
	}

	public function exists(k:Key):Bool
	{
#if flash9
		return untyped ival[k] != null;
#else
		var oid = getObjectId(k);

		var removed = false;

		var g = ival.get(oid);
		if (g == null)
		{
			return false;
		}

		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				return true;
			}
			i += 2;
		}

		return false;
#end
	}

	public function remove(k:Key):Bool
	{
#if flash9
		if (untyped __delete__(ival, k))
		{
			length--;
			return true;
		}
		return false;
#else
		var oid = getObjectId(k);

		var removed = false;

		var g = ival.get(oid);
		if (g == null)
		{
			return false;
		}

		var i = 0;
		var len = g.length;
		while (i < len)
		{
			if (g[i] == k)
			{
				g.splice(i, 2);
				removed = true;
				length--;
				break;
			}
			i += 2;
		}

		if (g.length == 0)
			ival.remove(oid);

		return removed;
#end
	}

	public function keys():Iterator<Key>
	{
#if flash9
		return untyped __keys__(ival);
#else
		var valit = ival.iterator();
		var curr = null;
		var currIndex = 0;
		return {
			hasNext: function() return (curr != null || valit.hasNext()),
			next: function()
			{
				if (curr == null)
					curr = valit.next();

				var ret = curr[currIndex];
				currIndex += 2;

				if (currIndex >= curr.length)
				{
					currIndex = 0;
					curr = null;
				}

				return ret;
			}
		};
#end
	}

	public inline function iterator():Iterator<Val>
	{
#if flash9
		return untyped keys().iterator();
#else
		var valit = ival.iterator();
		var curr = null;
		var currIndex = 1;
		return {
			hasNext: function() return (curr != null || valit.hasNext()),
			next: function()
			{
				if (curr == null)
					curr = valit.next();

				var ret = curr[currIndex];
				currIndex += 2;

				if (currIndex >= curr.length)
				{
					currIndex = 1;
					curr = null;
				}

				return ret;
			}
		};
#end
	}

	public function toString()
	{
		var ret = new StringBuf();
		ret.add("{ ");
		var first = true;

		for (k in keys())
		{
			if (first)
			{
				ret.add("\"");
				first = false;
			} else {
				ret.add(", \"");
			}

			ret.add(k);
			ret.add("\" => \"");
			ret.add(get(k));
			ret.add("\"");
		}

		ret.add(" }");
		return ret.toString();
	}

	public function hxSerialize(s:Serializer)
	{
		s.serialize(length);
#if flash9

		for (k in keys())
		{
			s.serialize(k);
			s.serialize(get(k));
		}

#else

		var valit = ival.iterator();
		var curr = null;
		var currIndex = 0;
		while (curr != null || valit.hasNext())
		{
			if (curr == null)
				curr = valit.next();

			var ret = curr[currIndex];
			s.serialize(curr[currIndex]);
			s.serialize(curr[currIndex + 1]);

			currIndex += 2;
			if (currIndex >= curr.length)
			{
				currIndex = 0;
				curr = null;
			}

		}
#end
	}

	public function hxUnserialize(s:Unserializer)
	{
		var len:Int = s.unserialize();
		for (i in 0...len)
		{
			var k = s.unserialize();
			var v = s.unserialize();
			set(k, v);
		}
	}
}