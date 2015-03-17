package composureTest;
import composure.core.ComposeGroup;
import composure.core.ComposeItem;
import composure.core.ComposeRoot;
import composure.traits.AbstractTrait;
import composure.macro.Prebuild;

class PrebuildItems
{
	public static var PLAYER:String = "Player";
	
	static function main(){
        var root:ComposeRoot = new ComposeRoot();
		
		// Define a prebuilt ComposeItem
		Prebuild.define(PLAYER, [PlayerController, EntityPosition, UserInput], ComposeItem );
		
		// These two lines will now do the same thing
        var item:ComposeItem = Prebuild.get(PLAYER);
        //item = Prebuild.make([PlayerController, EntityPosition, UserInput], ComposeItem);
		
        root.addChild(item);
    }
	
}

class UserInput {

	public function new() {
		
	}
}

class EntityPosition{

	public function new() {
		
	}
}


class PlayerController extends AbstractTrait{

	@:inject
	private var input:UserInput;

	@:inject
	private var position:EntityPosition;

	public function new(){
		super();
	}
	
	@promise("input", "position")
	function init( met:Bool ):Void {
		trace("Both input and position have been injected");
	}
	
	
	@:injectAdd
	public function addTrait(trait:EntityPosition):Void{
		trace("EntityPosition method has been called");
	}
}