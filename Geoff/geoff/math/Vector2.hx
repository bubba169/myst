package geoff.math;

/**
 * ...
 * @author Simon
 */
class Vector2
{

	public var x : Float;
	public var y : Float;
	
	public function new( x : Float = 0, y : Float = 0 ) 
	{
		this.x = x;
		this.y = y;
	}
	
	public function toString() : String 
	{
		return "("+x+","+y+")";
	}
	
	public function setTo(x:Float, y:Float) : Void
	{
		this.x = x;
		this.y = y;
	}
	
	public function distanceSquared() : Float 
	{
		return (x * x) + (y * y);
	}
	
	public function distance() : Float 
	{
		return Math.sqrt( distanceSquared() );
	}
	
	public function normalise( scalar : Float = 1 ) : Vector2 
	{
		var c : Float = Math.abs(x) + Math.abs(y);
		if ( c != 0 ) {
			this.setTo( (x / c) * scalar, ( y / c ) * scalar );
		}
		return this;
	}
	
	public function clone() : Vector2
	{
		return new Vector2( x, y );
	}
	
	public static function distanceBetween( a : Vector2, b : Vector2 ) : Float
	{
		return Math.sqrt(((a.x - b.x) * (a.x - b.x)) + ((a.y - b.y) * (a.y - b.y)));
	}
	
}