package composureTest;
import composure.core.ComposeGroup;
import composure.core.ComposeRoot;
import composure.traits.AbstractTrait;


class HelloWorld 
{
    static function main(){
        var root:ComposeRoot = new ComposeRoot();
	
        var item:ComposeGroup = new ComposeGroup();
        item.addTrait(new MessageTrait("Hello World"));
        item.addTrait(new LogTrait());

        root.addChild(item);
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
	private var msgProvider(default, set):MessageTrait;
	private function set_msgProvider(value:MessageTrait):MessageTrait{
		this.msgProvider = value;
		trace(value.msg);
		return value;
	}

	public function new(){
          super();
     }
}