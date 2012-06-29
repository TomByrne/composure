package org.tbyrne.composure.concerns;

import org.tbyrne.composure.core.ComposeItem;
import org.tbyrne.composure.traits.ITrait;


interface IConcern
{

	public var siblings(default, null):Bool;
	public var ascendants(default, null):Bool;
	public var descendants(default, null):Bool;
	public var acceptOwnerTrait(default, null):Bool;

	public var ownerTrait:Dynamic;

	function concernAdded(trait:Dynamic, item:ComposeItem):Void;
	function concernRemoved(trait:Dynamic, item:ComposeItem):Void;

	function shouldDescend(item:ComposeItem):Bool;
	function shouldAscend(item:ComposeItem):Bool;

	function isInterestedIn(trait:Dynamic):Bool;
}