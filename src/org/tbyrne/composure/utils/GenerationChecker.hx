package org.tbyrne.composure.utils;
import haxe.Log;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.concerns.Concern;
import org.tbyrne.logging.LogMsg;

/**
 * ...
 * @author Tom Byrne
 */

class GenerationChecker 
{

	public static function createTraitCheck(maxGenerations:Int=-1, relatedItem:ItemType):ComposeItem->Concern->Bool {
		return function(item:ComposeItem, from:Concern):Bool {
			var compare:ComposeItem;
			switch(relatedItem) {
				case specific(other): compare = other;
				case concernItem: compare = from.ownerTrait.item;
				case root: compare = item.root;
				default: Log.trace(new LogMsg(
			}
			return false;
		}
	}
	
}

enum ItemType {
	specific(ItemType:ComposeItem);
	concernItem;
	root;
}