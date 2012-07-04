package org.tbyrne.composure.injectors;

/**
 * ...
 * @author Tom Byrne
 */

class PropInjector extends Injector
{
	private var subject:Dynamic;
	private var prop:String;
	private var writeOnly:Bool;
	private var isSet:Bool;
	private var setTrait:Dynamic;

	public function new(interestedTraitType:Class<Dynamic>, subject:Dynamic, prop:String, siblings:Bool = true, descendants:Bool = false, ascendants:Bool = false, writeOnly:Bool=false) {
		this.subject = subject;
		this.prop = prop;
		this.writeOnly = writeOnly;
		super(interestedTraitType, addProp, removeProp, siblings, descendants, ascendants);
		
	}
	
	private function addProp(trait:Dynamic):Void {
		if (isSet) return;
		if (!writeOnly) {
			if (Reflect.getProperty(subject, prop) != null) {
				// this means the value has been manually set into the target
				isSet = true;
				return;
			}
		}
		isSet = true;
		setTrait = trait;
		Reflect.setProperty(subject, prop, trait);
	}
	
	private function removeProp(trait:Dynamic):Void {
		if(isSet && trait==setTrait){
			setTrait = null;
			if (Reflect.getProperty(subject, prop) != null) {
				// this means the value has been manually set into the target
				isSet = true;
				return;
			}else{
				isSet = false;
				Reflect.setProperty(subject, prop, null);
			}
		}
	}
}