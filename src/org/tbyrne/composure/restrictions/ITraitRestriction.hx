package org.tbyrne.composure.restrictions;

import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.ITrait;
/**
 * ...
 * @author Tom Byrne
 */

interface ITraitRestriction 
{
	function allowNewSibling(owner:ITrait, item:ComposeItem, newTrait:Dynamic):Bool;
	function allowAddTo(owner:ITrait, item:ComposeItem):Bool;
}