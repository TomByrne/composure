package org.tbyrne.composure.traits;

import org.tbyrne.composure.concerns.IConcern;
import org.tbyrne.composure.core.ComposeGroup;
import org.tbyrne.composure.core.ComposeItem;

interface ITrait
{
	public var item(default,set_item):ComposeItem;
	public var group(default, null):ComposeGroup;
	public var concerns(get_concerns, null):Array<IConcern>;
}