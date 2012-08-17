package composureTest;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;
import composure.core.ComposeGroup;
import composure.core.ComposeRoot;
import composure.traits.AbstractTrait;

/**
 * ...
 * @author Tom Byrne
 */

class DependencyInjectionMetadata extends Sprite
{

    static function main() {
        var root:ComposeRoot = new ComposeRoot();
	
        var stage:ComposeGroup = new ComposeGroup();
        stage.addTrait(new FrameUpdater(200)); // 5fps
        root.addChild(stage);
	
        var circle:ComposeGroup = new ComposeGroup();
        circle.addTrait(new CircleTrait(flash.Lib.current));
        circle.addTrait(new PositionTrait(100,100));
        stage.addChild(circle);
	
        var fpsDisplay:ComposeGroup = new ComposeGroup();
        fpsDisplay.addTrait(new FPSTrait(flash.Lib.current));
        stage.addChild(fpsDisplay);
    }
	
}
class PositionTrait
{
	public var x:Float;
	public var y:Float;

	public function new(x:Float=0, y:Float=0) 
	{
		this.x = x;
		this.y = y;
	}
}
class CircleTrait extends AbstractTrait, implements IUpdateOnFrameTrait
{
	@inject
	public var position:PositionTrait;

	private var circle:Shape;

	public function new(parent:MovieClip) 
	{
		super();
		
		circle = new Shape();
		circle.graphics.beginFill(0xff0000);
		circle.graphics.drawCircle(0, 0, 20);
		parent.addChild(circle);
	}
	
	public function update():Void {
		circle.x = position.x;
		circle.y = position.y;
	}
}
class FrameUpdater extends AbstractTrait
{
	private var timer:Timer;
	private var interval_ms:Int;
	private var updateTraits:Array<IUpdateOnFrameTrait>;

	public function new(interval_ms:Int) 
	{
		super();
		
		this.interval_ms = interval_ms;
		updateTraits = [];
		
		timer = new Timer(interval_ms);
		timer.addEventListener(TimerEvent.TIMER, update);
		timer.start();
	}
	
	@injectAdd({desc:true,sibl:false})
	public function addUpdateTrait(trait:IUpdateOnFrameTrait):Void{
		updateTraits.push(trait);
	}
	
	@injectRemove
	public function removeUpdateTrait(trait:IUpdateOnFrameTrait):Void{
		updateTraits.remove(trait);
	}
	
	private function update(e:TimerEvent):Void{
		for(trait in updateTraits){
			trait.update();
		}
	}
	
	public function getFPS():Int {
		return Std.int(1000/interval_ms);
	}
}
interface IUpdateOnFrameTrait {
	function update():Void;
}
class FPSTrait extends AbstractTrait, implements IUpdateOnFrameTrait
{
	@inject({sibl:false,asc:true})
	private var frameUpdater:FrameUpdater;
	private var textDisplay:TextField;

	public function new(parent:MovieClip) 
	{
		super();

		textDisplay = new TextField();
		parent.addChild(textDisplay);
	}
	
	public function update():Void{
		textDisplay.text = "FPS: "+frameUpdater.getFPS();
	}
}