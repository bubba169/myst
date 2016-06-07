package geoff.platform.desktop;
import geoff.platform.desktop.externs.GeoffRenderer;
import geoff.renderer.IRenderContext;
import geoff.renderer.RenderBatch;
import geoff.renderer.Shader;
import geoff.renderer.Texture;
import geoff.utils.Color;
import haxe.io.UInt8Array;

/**
 * ...
 * @author Simon
 */

class DesktopRenderer implements IRenderContext
{

	public var _internalRenderer : cpp.Pointer<GeoffRenderer>;
	
	public function new() 
	{
		
	}
	
	public function init() : Void 
	{
		untyped __cpp__("_internalRenderer = new GeoffRenderer()");
	}
	
	public function destroy() 
	{
		untyped __cpp__("delete _internalRenderer");
	}

	
	public function clear( clearColor : Color ) : Void
	{
		_internalRenderer.get_ref().clear( clearColor.r / 255, clearColor.g / 255, clearColor.b / 255, clearColor.a );
	}
	
	
	/**
	 * Shader
	 */
	
	public function uploadShader( shader : Shader ) : Void
	{
		shader.program = _internalRenderer.get_ref().compileShader( cpp.Pointer.addressOf( shader.vertexSource ), cpp.Pointer.addressOf( shader.fragmentSource ) );
	}	
	
	
	/**
	 * Render
	 */
	
	public function beginRender( width : Int, height : Int ) : Void
	{
		_internalRenderer.get_ref().beginRender( width, height );
	}
	
	public function renderBatch( batch : RenderBatch ) : Void
	{
		_internalRenderer.get_ref().renderBatch( batch );
	}
	
	public function endRender( ) : Void
	{
	}
	
	public function getError() : Int
	{
		return _internalRenderer.get_ref().getError();
	}
	
	
	/**
	 * Framebuffer
	 */
	
	public function pushRenderTarget( target : Texture ) : Void 
	{
	}
	
	public function popRenderTarget( ) : Void
	{
	}
	
	
	/**
	 * Texture
	 */
	
	public function createTextureFromAsset( path : String ) : Texture 
	{
		var texture : Texture = new Texture( path );
		_internalRenderer.get_ref().createTexture( cpp.Pointer.addressOf(path), texture );
		return texture;
	}
	
	public function createTextureFromPixels( id : String, width : Int, height : Int, pixels : UInt8Array ) : Texture
	{
		var texture : Texture = new Texture( id );
		_internalRenderer.get_ref().createTexture( cpp.Pointer.addressOf(path), texture );
		return texture;
	}
	
	
	
	
}