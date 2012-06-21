package org.tbyrne.composure.utils;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.ITrait;
import org.tbyrne.composure.concerns.Concern;

/**
 * ...
 * @author Tom Byrne
 */

class TraitChecker 
{

	public static function createTraitCheck(types:Array<Dynamic>, ?useOrCheck:Bool):ComposeItem->Concern->Bool {
		if (useOrCheck) {
			return function(item:ComposeItem, from:Concern):Bool {
				for (type in types) {
					if (item.getTrait(type) != null) {
						return true;
					}
				}
				return false;
			}
		}else {
			return function(item:ComposeItem, from:Concern):Bool {
				for (type in types) {
					if (item.getTrait(type) == null) {
						return false;
					}
				}
				return true;
			}
		}
	}
	
}