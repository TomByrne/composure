package org.tbyrne.composure.restrictions;

/**
 * ...
 * @author Tom Byrne
 */

import haxe.io.Error;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.restrictions.ITraitRestriction;
import org.tbyrne.composure.traits.ITrait;

class SingularTraitRestriction implements ITraitRestriction
{
	public static function getInheritedRestrictor():SingularTraitRestriction {
		if (_inheritedRestrictor == null) {
			_inheritedRestrictor = new SingularTraitRestriction(true);
		}
		return _inheritedRestrictor;
	}
	public static function getNonInheritedRestrictor():SingularTraitRestriction {
		if (_nonInheritedRestrictor == null) {
			_nonInheritedRestrictor = new SingularTraitRestriction(false);
		}
		return _nonInheritedRestrictor;
	}
	private static var _inheritedRestrictor:SingularTraitRestriction;
	private static var _nonInheritedRestrictor:SingularTraitRestriction;
	
	
	public var restrictSubclasses:Bool;
	
	private var lastOwner:ITrait;
	private var lastClass:Class<Dynamic>;
	
	private function new(restrictSubclasses:Bool) {
		this.restrictSubclasses = restrictSubclasses;
	}
	public function allowNewSibling(owner:Dynamic, item:ComposeItem, newTrait:Dynamic):Bool {
		validateForOwner(owner);
		if (restrictSubclasses) {
			return !Std.is(newTrait, lastClass);
		}else{
			return (Type.getClass(newTrait) != lastClass);
		}
	}
	public function allowAddTo(owner:Dynamic, item:ComposeItem):Bool {
		validateForOwner(owner);
		var traits:Array<Dynamic> = item.getTraits(lastClass);
		if (restrictSubclasses) {
			return false;
		}else{
			for (trait in traits) {
				if (Type.getClass(trait) == lastClass) {
					return false;
				}
			}
		}
		return true;
	}
	
	private function validateForOwner(owner:ITrait):Void {
		if (lastOwner != owner) {
			lastOwner = owner;
			lastClass = Type.getClass(owner);
		}
	}
}