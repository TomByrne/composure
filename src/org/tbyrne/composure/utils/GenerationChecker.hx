package org.tbyrne.composure.utils;
import haxe.Log;
import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.injectors.Injector;
import org.tbyrne.logging.LogMsg;

/**
 * @author Tom Byrne
 */

class GenerationChecker 
{

	public static function createTraitCheck(maxGenerations:Int=-1, relatedItem:ItemType):ComposeItem->Injector->Bool {
		return function(item:ComposeItem, from:Injector):Bool {
			var compare:ComposeItem;
			switch(relatedItem) {
				case specific(other): compare = other;
				case injectorItem: compare = from.ownerTrait.item;
				case root: compare = item.root;
			}
			return false;
		}
	}
	
}

enum ItemType {
	specific(ItemType:ComposeItem);
	injectorItem;
	root;
}