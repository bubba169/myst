package pkg;

import geoff.AppDelegate;
import geoff.event.PointerEvent.PointerButton;
import geoff.renderer.IRenderContext;
import geoff.renderer.RenderBatch;

/**
 * ...
 * @author ...
 */
class AppEngine extends AppDelegate
{
	var shader : Int;
	var batch:RenderBatch;
	
	var _width : Int = 640;
	var _height : Int = 480;

	public function new() 
	{
		super();
	}
	
	override public function init( renderer : IRenderContext ) 
	{
				
	}
	
	override public function update( renderer : IRenderContext ) 
	{
		renderer.clear();
	}
	
	override public function resize(width:Int, height:Int) 
	{
		_width = width;
		_height = height;
	}
	
	override public function onPointerDown(pointerId:Int, button : PointerButton, x:Int, y:Int):Void 
	{
		
	}
	
	
	
}