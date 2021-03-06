package geoff.androidnative;

import android.opengl.GLSurfaceView;
import android.content.Context;
import android.view.MotionEvent;
import android.view.KeyEvent;
import android.util.Log;
import android.view.inputmethod.InputMethodManager;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.EditorInfo;
import java.lang.Runnable;

import geoff.App;

public class GeoffGLView extends GLSurfaceView
{
	private GeoffGLRenderer renderer;

	public GeoffGLView( Context context )
	{
		super( context );

		this.setFocusable(true);
		this.setFocusableInTouchMode(true);
	}

	public void init( )
	{

		setEGLContextClientVersion(2);
		
		renderer = new GeoffGLRenderer( );
		setRenderer( renderer );

		runGameLoop();

		Log.v("Thread", "Thread is running");

	}

	public void runGameLoop()
	{
		(new Thread() 
		{

			@Override public void run() 
			{
				// Indefinite update loop
				while ( true )
				{
					if ( renderer.hasInit && !renderer.isRendering && !renderer.hasFrameWaiting ) {
						App.current.update();
						renderer.hasFrameWaiting = true;
					} 
				}

			}

		}).start();
	}
	
	public boolean onTouchEvent( MotionEvent originalEvent )
	{

		final MotionEvent event = originalEvent;
		final int pointerId = event.getActionIndex();
		final int action = event.getActionMasked();
		
		switch( action )
		{
			case MotionEvent.ACTION_DOWN:
			case MotionEvent.ACTION_POINTER_DOWN:
				App.current.eventManager.sendEventInt( "PointerDown", new int[] {pointerId, 0, (int)event.getX( pointerId ), (int)event.getY( pointerId )}, "Update" );
				break;
				
			case MotionEvent.ACTION_UP:
			case MotionEvent.ACTION_POINTER_UP:
				App.current.eventManager.sendEventInt( "PointerUp", new int[] {pointerId, 0, (int)event.getX( pointerId ), (int)event.getY( pointerId )}, "Update" ); 
				break;
				
			case MotionEvent.ACTION_MOVE:
				for ( int i = 0; i < event.getPointerCount(); ++i ) {
					App.current.eventManager.sendEventInt( "PointerMove", new int[] { event.getPointerId( i ), (int)event.getX( i ), (int)event.getY( i )}, "Update" );
				}
				break;
		}
		
		return true;
	}

	public boolean onKeyDown( int keyCode, KeyEvent event )
	{
		
		if ( 
			keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
			keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
			keyCode == KeyEvent.KEYCODE_VOLUME_MUTE
		){
			return false;
		}

		App.current.eventManager.sendEventInt( "KeyDown", new int[] { keyCode, 0 }, "Update" );

		return true;
	}

	public boolean onKeyUp( int keyCode, KeyEvent event )
	{

		if ( 
			keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
			keyCode == KeyEvent.KEYCODE_VOLUME_DOWN ||
			keyCode == KeyEvent.KEYCODE_VOLUME_MUTE
		){
			return false;
		}
		
		App.current.eventManager.sendEventInt( "KeyUp", new int[] { keyCode, 0 }, "Update" );

		int uchar = event.getUnicodeChar();
		if ( uchar != 0 ) 
		{
			App.current.eventManager.sendEventInt( "TextEntry", new int[] { uchar }, "Update" );
		}
				
		return true;
	}

	@Override
  	public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
    	InputConnection conn = super.onCreateInputConnection(outAttrs);
   		outAttrs.imeOptions = EditorInfo.IME_FLAG_NO_FULLSCREEN;
   		return conn;
	}
	
	
}