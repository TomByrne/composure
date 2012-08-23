package composure.core;
import composure.injectors.IInjector;
import composure.injectors.InjectorMarrier;
import composure.traits.ITrait;
import composure.traits.TraitCollection;

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
	private var _universalMarrier:InjectorMarrier;
	
	public function new(initTraits:Array<ITrait>=null){
		super(initTraits);
		_universalMarrier = new InjectorMarrier(_descendantTraits);
		setRoot(this);
	}
	public function getAllTraits():TraitCollection {
		return _descendantTraits;
	}
	
	/**
	 * @private
	 */
	public function addUniversalInjector(injector:IInjector):Void {
		_universalMarrier.addInjector(injector);
	}
	
	/**
	 * @private
	 */
	public function removeUniversalInjector(injector:IInjector):Void {
		_universalMarrier.removeInjector(injector);
	}
}