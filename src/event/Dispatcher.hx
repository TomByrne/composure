/*
 * Copyright (c) 2009, The Caffeine-HX Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 * Author:
 *  Danny Wilson - deCube.net
 */

package event;

enum StopPropagation {
	/** Immediately stop calling handlers for this event **/
	Now;
	/** Immediately stop calling handlers for this event, but pass it on to the parent **/
	ThenBubble;
}

enum EventGroupException {
	/** Event.global() requires an EventGroup! Was called with [cl] instead. **/
	NonEventGroupArg(cl:Class<Dynamic>);
	/** Event.global() null EventGroup ID. Are you sure you specified an EventGroup class as parameter? **/
	Null;
}

/** Implementing this interface is adviced for classes that enable/disable or bind and unbind listeners alot.
	Pass the typedef of Bindings for your handlers in the Type parameter.
	Example:
	
	typedef MyListenerHandlers = {
		var onSomething : Binding;
		var onAnother	: Binding;
	}
	class MyListener implements EventHandlers<MyListenerHandlers> {
		public var handlers : MyListenerHandlers;
		...
	}
	
	When you properly implement this interface, you will be able to use "Event.unbind(this);" to easily unbind every handler used.
**/
interface EventHandlers<T> {
	var handlers : T;
}

/** Every class that dispatches any event is adviced to implement this, for easier documentation. **/
interface EventDispatchers<G : EventGroup> {
	var events : G;
}

/** Use this for handler typedefs. See EventHandlers for example. **/
interface Binding {
	function enable()	: Void;
	function disable()	: Void;
	
	/** Unlinks / removes a Binding. After this, the Binding can not be re-enabled.
		If the listener class this handler belongs to implements EventHandlers<...>, 
		the coresponding instance will automatically be set null aswell. **/ 
	function unbind( ?skipSelfDestruction : Bool ) : Void;
	
	/** Checks if this binding is bound to the given listener and handler. **/
	function boundTo( listener : Dynamic, ?handler : Dynamic ) : Bool;
}

interface Unbindable<T> {
	public function unbind( listener : Dynamic, ?handler : T ) : Bool;
}

interface EventGroup #if !flash9 implements Unbindable<Dynamic> #end
/* 	Implementing Unbindable<Dynamic> for flash9 causes:
		VerifyError: Error #1053: Illegal override of BasicEventGroup in event.BasicEventGroup.
	in haxe 2.0 :-(  */
{
	public function bubbleTo( group : EventGroup ) : Void;
	public function dontBubble() : Void;
#if flash9
	public function unbind( listener : Dynamic, ?handler : Dynamic ) : Bool;
#end
}

private class Util
{
	// Std.is is reaaally slow, it takes about 100 ms in the 5000 listeners basic speedtest
	// Directly using instanceof takes like 10-20 ms instead !! :-/
	static public inline function is(o:Dynamic, t:Dynamic)
	{
		return
		#if flash9
			untyped __is__(o, t)
		#elseif flash
			untyped __instanceof__(o, t)
		#elseif js
			
		#else
			Std.is(o, t)
		#end
		;
	}
}

/**
	Cross-platform event system with wrappers for commonly used events like Mouse and Keyboard.
	This class contains utility functions for the system.
**/
class Event
{
	/** Global EventGroups container **/
	static private var groups : IntHash<EventGroup>;
	
	/** Current event being broadcast. Null when no broadcast in progress. **/
	static public var current : Null< Dispatcher<Dynamic> >;
	
	/** Debug tool: Where is this event called? Null when the caller hasn't used source() before dispatching **/
	static public var callPos : Null< haxe.PosInfos >;
	
	/** Access global Event dispatcher for the specified an EventGroup class **/
	static public function global< EG >( eventGroup : Class<EG> ) : EG
	{
		var g : EventGroup = untyped eventGroup.global;
		if(g != null) return cast g;
		
		var id	: Int = untyped eventGroup._gid;
		if( groups == null ) groups = new IntHash();
		
		if( id > 0 )
			g = cast groups.get(id);
		
		if(g == null) // Make a new global instance
		{
			g = cast Type.createInstance(eventGroup, []);
			if(!Std.is(g, EventGroup)) throw NonEventGroupArg(eventGroup);
			id = untyped eventGroup._gid = BasicEventGroup.groupID++;
			untyped eventGroup.global = g;
			groups.set(id, g);
		}
		
		if( g == null ) throw Null;
		return cast g;
	}
	
	/** Removes all bindings to ANY global event for the given listener.
		When also a handler is passed, only the matching handler is removed instead.
		
		If the listener implements EventHandlers<...>, it Uses Reflect.fields() to get the handler bindings 
		and unbinds them. So yes this is just a lazy "destroy all bindings in my handlers object" function :-)
		
		By default, all global Event dispatcher objects are searched, you can skip searching (and thus removal) of global dispatchers
		by setting skipGlobalDispatchers to true.
	**/
	static public function unbind( listener : Dynamic, ?handler : Dynamic, ?skipGlobalDispatchers : Bool )
	{
		if( #if js untyped __js__("listener instanceof event.EventHandlers") #else Util.is(listener,EventHandlers) #end )
		{
			var h = listener.handlers,
				b : Binding;
			for(f in Reflect.fields(h)) {
				b = Reflect.field(h, f);
				if(b.boundTo(listener, handler)) b.unbind();
			}
		}
		
		if(!skipGlobalDispatchers) {
			var l = groups.get;
			for(id in groups.keys()) {
				l(id).unbind(listener, handler);
			}
		}
	}
	
	//private function new();
}

/** Event dispatcher and manager class. **/
class Dispatcher<HandlerSig> extends HandlerList, implements Unbindable<HandlerSig> // No Function support yet :( #if flash9 , implements haxe.rtti.Generic #end 
{
	public function bubbleTo( event : Dispatcher<HandlerSig> ) : Void
	{
		this.nextBubble = event;
	}
	
	public function stopPropagation()
	{
		if(Event.current != null) throw StopPropagation.Now;
	}
	
	public function stopPropagationThenBubble()
	{
		if(Event.current != null) throw StopPropagation.ThenBubble;
	}
	
	// --------------------------
	//	Event  dispatcher system
	// --------------------------
	// private var parent : EventGroup;
	
	/** Which dispatcher to pass the event on, after all handlers are called. **/
	var nextBubble	: Dispatcher<HandlerSig>;
	
	/** Call / Broadcast / Dispatch / Whatever(tm) this event! **/
	public var call(default, null) : HandlerSig;
	
	/** New dispatcher instance. Usually only called by EventGroup. **/
	public function new()
	{
		super();
	#if flash9
		call = untyped dispatchCall;
	#end
	}
	
	/** Identify where the event is called (nice for debugging) **/
	public function source(?pos:haxe.PosInfos)
	{
		Event.callPos = pos;
		return this;
	}

	// --- Event custom Linked list
	
	/** Subscribe / AddEventListener / Bind / Whatever(tm) a handler to this event. **/
	public function bind( listener : Dynamic, handler : HandlerSig ) : Binding
	{
		return new Link( this, listener, handler );
	}
	
	/** Unbind all handlers for the given listener object. 
		If a handler is specified only this handler is unbound instead. **/
	public function unbind( listener : Dynamic, ?handler : HandlerSig ) : Bool
	{
		if(l == null) return false;
		var p, b = l, found = false;
		
		while(b != null) {
			p = b.p;
			if( b.boundTo(listener, handler) ) {
				b.unbind(false);
				found = true;
			}
			b = p;
		}
		return found;
	}

#if flash9
	private function dispatchCall( __arguments__ )
#else
	static function __init__() {
		untyped Event.prototype.call = 
		#if neko 
			__dollar__varargs( function( args )
		#else
			function()
		#end
#end
	{
		if(this.f != null)
		{
			Event.current = this;
			
		#if neko
			var b:Dynamic = this.f;
		#else
			var b:Link = this.f;
		#end	
			try while(b != null) {
				#if neko b = b.r; #end
				if (
				#if neko
					__dollar__call(b[0],b[1],args)
				#elseif js
					b.h.apply(b.l, untyped arguments)
				#elseif flash
					b.h.apply(b.l, untyped __arguments__)
				#end
				// If the handler returns true, stop propagation
					/*=== true*/) break;
				
				#if neko
				b = b[2]; // Next node
				#else
				b = b.n; // Next node
				#end
			} catch( e : StopPropagation ) {
				switch(e)
				{
					case Now:
						return;
					case ThenBubble:
						
				}
			}
		}
		if(this.nextBubble != null) untyped
		#if neko
			__dollar__call(this.nextBubble.call,this.nextBubble,args)
		#elseif js
			this.nextBubble.call.apply(this.nextBubble, untyped arguments)
		#elseif flash
			this.nextBubble.call.apply(this.nextBubble, untyped __arguments__)
		#end
		;
		
		Event.callPos = null;
		Event.current = null;
#if !flash9
	}
#if neko
	);
#end #end
	}
}

class ProxiedDispatcher<HandlerSig> extends Dispatcher<HandlerSig>
{
	public var proxy_data:Dynamic;
	public var proxy_preBind:Dynamic;
	public var proxy_AllUnbound:Dynamic;
	
	public function new(preBind:Dynamic, allUnbound:Dynamic)
	{
		super();
		this.proxy_preBind = preBind;
		this.proxy_AllUnbound = allUnbound;
	}
	
	override public function bind( listener : Dynamic, handler : HandlerSig ) : Binding
	{
		if (this.f == null) proxy_preBind(this);
		return super.bind(listener,handler);
	}
	
	override public function unbind( listener : Dynamic, ?handler : HandlerSig ) : Bool
	{
		var r = super.unbind(listener,handler);
		if (r && this.f == null && this.l == null) proxy_AllUnbound(this);
		return r;
	}
}

/**	Extend this to create a group of event dispatchers that are somehow related.
	For syntax sugar, EventGroup uses haxe.Public
**/
class BasicEventGroup implements EventGroup, implements haxe.Public
{
	/** Number of unique EventGroups that are instantiated in the application. Used for indexing. **/
	static public var groupID = 1;
	
	//private function new();
	
	/** ...Under discussion... ** /
 	public function bind( cl : Dynamic )
	{
		
	}
	*/

	public function unbind( listener : Dynamic, ?handler : Dynamic )
	{
		var f, found = false;
		for(field in Type.getInstanceFields(Type.getClass(this))) {
			f = Reflect.field(this, field);
			if( #if js untyped __js__("f instanceof event.Unbindable") #else Util.is(f,Unbindable) #end 
				#if flash9 || Util.is(f, EventGroup) #end )
				found = f.unbind(listener, handler);
		}
		return found;
	}
	
	public function bubbleTo( group:EventGroup )
	{
		var f, bf;
		for(field in Type.getInstanceFields(Type.getClass(this)))
		{
			f = Reflect.field(this, field);
			
			if( #if js untyped __js__("f instanceof event.EventGroup") #else Util.is(f,EventGroup) #end )
			{
				bf = Reflect.field(group, field);
				f.bubbleTo(bf);
			}
			else if( #if js untyped __js__("f instanceof event.Dispatcher") #else Util.is(f,Dispatcher) #end )
				f.nextBubble = Reflect.field(group, field);
		}
	}
	
	public function dontBubble()
	{
		var f;
		for(field in Type.getInstanceFields(Type.getClass(this))) {
			f = Reflect.field(this, field);
			
			if( #if js untyped __js__("f instanceof event.EventGroup") #else Util.is(f,EventGroup) #end )
				f.dontBubble();
			else if( #if js untyped __js__("f instanceof event.Dispatcher") #else Util.is(f,Dispatcher) #end )
				f.nextBubble = null;
		}
	}
}

private class HandlerList {
	/** First link in list. Event dispatchers use this as starting point. **/
	public var f : Link;
	/** Last link, used to walk through the Link.parent path in Event.unbind(), in order to remove a handler binding. **/
	public var l : Link;
	
	public function new() {
		this.f = null; this.l = null;
	}
}

#if neko
private class Link implements Binding
{
	/** Is this Bubble active? **/
	public var a : Bool;
	/** l = [ -Handler- , -Listener- , -NextNode- ]; **/
	public var r : Array<Dynamic>;
	
	/** Object referencing the first and last Link in the Chain **/
	private var _ : HandlerList;
	/** Parent Link in the chain **/
	public var p : Link;
	
	public function new( c:HandlerList, listener:Dynamic, handler:Dynamic )
	{
		a = true;
		r = untyped __dollar__array(handler,listener,c.f);
		_ = c;
		
		if( c.l == null )
			c.l = this; 	// First created link is also the last in the chain
		
		if( c.f != null )
			c.f.p = this;	// this link becomes it's parent
		
		c.f = this; // This link is now first
	}
	
	/** Disable propagation for the handler this link belongs too. Usefull to quickly (syntax and performance wise) temporarily disable a handler.
		Adviced to use in classes which "in the usual way" would add and remove listeners alot. **/
	public function disable()
	{
		if(!a) return;
		a = false;
		
		if(this.p == null) { // This node is the very first Bubble
			_.f = r[2];
			return;
		}
		
		// Search parents for the first active node
		var x = this.p;
		while( x != null && !x.a ) x = x.p;
		if( x != null )
			x.r[2] = this.r[2];
		else // Null, we've reached the first bubble...
			_.f = r[2];
	}
	
	/** Enable propagation for the handler this link belongs too. **/
	public function enable()
	{
		if(a || r[1] == null) return; // Prevent re-enable removed link (just in case)
		a = true;
		
		var x;
		if(this.p == null) {
			// This link is the very first link
			r[2] = _.f;
			_.f = this;
			return;
		}
		
		// Find previous link
		x = this.p;
		while( x != null && !x.a ) x = x.p;
		
		if(x == null) {
			r[2] = _.f;
			_.f = this;
		}
		else {
			r[2] = x.r[2];
			x.r[2] = this;
		}
	}
	
	/** Unlinks / removes a link. After this, the link can not be re-enabled.
		If the listener class this handler belongs to implements EventHandlers<...>, 
		the coresponding instance will automatically be set null aswell. **/ 
	public function unbind( ?skipSelfDestruction : Bool )
	{
		if(_ == null) return;
		disable();
		
		// If this is the very last Bubble, set the parent one as last
		if(this == _.l) _.l = p;
		// If this is the very first Bubble (this.p == null), set the next one as the very first by forcing its parent to null 
		// Otherwise this is a node in the middle  (this.p != null), make sure the next Link gets a new Parent (instead of this)
		else 
		{
			// Maybe the next node is allready the one we're looking for?
			if( r[2] != null && r[2].p == this) r[2].p = this.p;
			
			// Nope, do a search backwards for it
			else {
				var x:Link = _.l;
				while( x != null && x.p != this ) x = x.p;
				if(x != null) x.p = this.p;
			}
		}
		
		// Std.is is reaaally slow, it takes about 100 ms in the 5000 listeners basic speedtest
		// Directly using instanceof takes like 10-20 ms instead !! :-/
		if(!skipSelfDestruction && Std.is(r[2], EventHandlers)) {
			// Make sure the event bubble instance is set null as well,
			// for listener classes which implement EventHandlers<...>
			var _h = r[2].handlers;
			for(f in Reflect.fields(_h))
				if( Reflect.field(_h, f) == this ) Reflect.setField(_h, f, null);
		}
		
		// Cleanup all connections
		untyped _ = r = p = null;
	}
	
	/** For speed, the link holds the actual function and target object (listener) without closure.
		So for method comparison to work, you need this :-) Probably only works with functions compiled by haXe! **/
	public function boundTo( listener : Dynamic, ?handler : Dynamic )
	{
		if( r[1] != listener ) return false;
		if(handler == null) return true;
		
		return Reflect.compareMethods(handler, r[0]);
	}
}

#else
private class Link implements Binding
{
	/** Is this Bubble active? **/
	private var a : Bool;
	/** Object referencing the first and last Link in the Chain **/
	private var _ : HandlerList;
	/** Listener object **/
	public var l : Dynamic;
	/** Handler function **/
	public var h : Dynamic;
	/** Next active Link object **/
	public var n : Link;
	/** Parent Link in the chain **/
	public var p : Link;
	
	public function new( c:HandlerList, listener:Dynamic, handler:Dynamic )
	{
		a = true;
		l = listener;
	#if flash
		h = untyped handler;					// Closure removal trick breaks flash8 :(
	#elseif js
		h = untyped handler.method || handler;	// But works in JS :)
	#error
	#end
		_ = c;
		
		if(c.l == null)
			c.l = this; 	// First created link is also the last in the chain
		
		if(c.f != null) {
			n = c.f;		// Current first link becomes next,
			c.f.p = this;	// this link becomes it's parent
		}
		c.f = this; // This link is now first
	}
	
	/** Disable propagation for the handler this link belongs too. Usefull to quickly (syntax and performance wise) temporarily disable a handler.
		Adviced to use in classes which "in the usual way" would add and remove listeners alot. **/
	public function disable()
	{
		if(!a) return;
		a = false;
		
		if(this.p == null) { // This node is the very first Bubble
			_.f = n;
			return;
		}
		
		// Search parents for the first active node
		var x = this.p;
		while( x != null && !x.a ) x = x.p;
		if( x != null )
			x.n = this.n;
		else // Null, we've reached the first bubble...
			_.f = n;
	}
	
	/** Enable propagation for the handler this link belongs too. **/
	public function enable()
	{
		if(a || l == null) return; // Prevent re-enable removed link (just in case)
		a = true;
		
		var x;
		if(this.p == null) {
			// This link is the very first link
			n = _.f;
			_.f = this;
			return;
		}
		
		// Find previous link
		x = this.p;
		while( x != null && !x.a ) x = x.p;
		
		if(x == null) {
			n = _.f;
			_.f = this;
		}
		else {
			n = x.n;
			x.n = this;
		}
	}
	
	/** Unlinks / removes a link. After this, the link can not be re-enabled.
		If the listener class this handler belongs to implements EventHandlers<...>, 
		the coresponding instance will automatically be set null aswell. **/ 
	public function unbind( ?skipSelfDestruction : Bool )
	{
		if(_ == null) return;
		disable();
		
		// If this is the very last Bubble, set the parent one as last
		if(this == _.l) _.l = p;
		// If this is the very first Bubble (this.p == null), set the next one as the very first by forcing its parent to null 
		// Otherwise this is a node in the middle  (this.p != null), make sure the next Link gets a new Parent (instead of this)
		else 
		{
			// Maybe the next node is allready the one we're looking for?
			if( n != null && n.p == this) n.p = this.p;
			
			// Nope, do a search backwards for it
			else {
				var x:Link = _.l;
				while( x != null && x.p != this ) x = x.p;
				if(x != null) x.p = this.p;
			}
		}
		
		if( !skipSelfDestruction && #if js untyped __js__("this.l instanceof event.EventHandlers") #else Util.is(l,EventHandlers) #end )
		{
			// Make sure the event bubble instance is set null as well,
			// for listener classes which implement EventHandlers<...>
			var _h = l.handlers;
			for(f in Reflect.fields(_h))
				if( Reflect.field(_h, f) == this ) Reflect.setField(_h, f, null);
		}
		
		// Cleanup all connections
		_ = l = h = n = p = null;
	}
	
	/** For speed, the link holds the actual function and target object (listener) without closure.
		So for method comparison to work, you need this :-) Probably only works with functions compiled by haXe! **/
	public function boundTo( listener : Dynamic, ?handler : Dynamic )
	{
		if( this.l != listener ) return false;
		if(handler == null) return true;
		
	#if flash9
		return (h == handler);
	#elseif flash
		return (l == handler.o && h == handler.f);
	#elseif js
		return (l == handler.scope && h == handler.method);
	#end
	}
}
#end

