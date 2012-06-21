package org.tbyrne.composure.core;
import org.tbyrne.composure.traits.ITrait;

//import org.tbyrne.composure.ComposeNamespace;

//
//#use namespace ComposeNamespace;
//using away3d.namespace.ComposeNamespace;

class ComposeRoot extends ComposeGroup
{
	public function new(initTraits:Array<ITrait>=null){
		super(initTraits);
		setRoot(this);
	}
}