package org.tbyrne.composureTest;
import org.tbyrne.composure.core.ComposeGroup;
import org.tbyrne.composure.core.ComposeRoot;
import org.tbyrne.composure.traits.AbstractTrait;

/**
 * @author Tom Byrne
 */

class HelloWorld 
{
    static function main(){
        var root:ComposeRoot = new ComposeRoot();
	
        var item:ComposeGroup = new ComposeGroup();
        item.addTrait(new MessageTrait("Hello World"));
        item.addTrait(new LogTrait());

        root.addItem(item);
    }
	
}

class MessageTrait{

	public var msg:String;

	public function new(msg:String){
		this.msg = msg;
	}
}


class LogTrait extends AbstractTrait{

	@inject
	public var msgProvider(default, set_msgProvider):MessageTrait;
	private function set_msgProvider(value:MessageTrait):MessageTrait{
		this.msgProvider = value;
		trace(value.msg);
		return value;
	}

	public function new(){
          super();
     }
}