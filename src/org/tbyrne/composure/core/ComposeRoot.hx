package org.tbyrne.composure.core;
import org.tbyrne.composure.traits.ITrait;

class ComposeRoot extends ComposeGroup
{
	public function new(initTraits:Array<ITrait>=null){
		super(initTraits);
		setRoot(this);
	}
}