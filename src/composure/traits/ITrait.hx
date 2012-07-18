package composure.traits;

import composure.injectors.IInjector;
import composure.core.ComposeGroup;
import composure.core.ComposeItem;


/**
 * ITrait can be implemented by traits to give them access to the item
 * to which they are added. It also allows traits to return a list of 
 * injectors, which describe other traits (sibling, ascendant or descendant)
 * which this trait should gain access to.
 * 
 * @author		Tom Byrne
 */
interface ITrait
{
	/**
	 * The item which this trait is added to. Do not set this manually,
	 * the ComposeItem class sets this property automatically when the 
	 * trait is added to it.
	 */
	public var item(default,set_item):ComposeItem;
	/**
	 * The group to which this item is added. This is a method of convenience,
	 * and should return the 'item' property cast as a ComposeGroup.
	 */
	public var group(default, null):ComposeGroup;
	
	/**
	 * This provides a way for this trait to gain access to other traits in the
	 * application.
	 * @return A list of IInjectors, each one describing which traits it is concerned with.
	 */
	public function getInjectors():Array<IInjector>;
}