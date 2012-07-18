package composure.core;
import composure.traits.ITrait;

/**
 * ComposeRoot is the root item for the Composure library.
 * When using Composure, one top-level ComposeRoot object should be
 * created. All other objects should then be added to this object or one
 * of it's descendants.<br/>
 * It is recommended that you do not add traits directly to the root object.
 * Adding them to some 'stage' or 'controller' item instead will allow your app
 * to coexist and interrelate with other Composure apps in future.<br/>
 * The only functional change ComposeRoot adds to ComposeGroup is that it's
 * 'root' property is a reference to itself.
 * @author		Tom Byrne
 */
class ComposeRoot extends ComposeGroup
{
	public function new(initTraits:Array<ITrait>=null){
		super(initTraits);
		setRoot(this);
	}
}