package composure.injectors;

import composure.core.ComposeItem;
import composure.traits.ITrait;


interface IInjector
{

	@:isVar public var siblings(default, null):Bool;
	@:isVar public var ascendants(default, null):Bool;
	@:isVar public var descendants(default, null):Bool;
	@:isVar public var universal(default, null):Bool;
	@:isVar public var acceptOwnerTrait(default, null):Bool;

	public var ownerTrait:Dynamic;
	public var ownerTraitTyped:ITrait;

	function injectorAdded(traitPair:TraitPair<Dynamic>):Void;
	function injectorRemoved(traitPair:TraitPair<Dynamic>):Void;

	function shouldDescend(item:ComposeItem):Bool;
	function shouldAscend(item:ComposeItem):Bool;

	function isInterestedIn(item:ComposeItem, trait:Dynamic):Bool;
}