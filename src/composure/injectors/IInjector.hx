package composure.injectors;

import composure.core.ComposeItem;
import composure.traits.ITrait;


interface IInjector
{

	public var siblings(default, null):Bool;
	public var ascendants(default, null):Bool;
	public var descendants(default, null):Bool;
	public var universal(default, null):Bool;
	public var acceptOwnerTrait(default, null):Bool;

	public var ownerTrait:Dynamic;
	public var ownerTraitTyped:ITrait;

	function injectorAdded(traitPair:TraitPair<Dynamic>):Void;
	function injectorRemoved(traitPair:TraitPair<Dynamic>):Void;

	function shouldDescend(item:ComposeItem):Bool;
	function shouldAscend(item:ComposeItem):Bool;

	function isInterestedIn(item:ComposeItem, trait:Dynamic):Bool;
}