package states;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

/**
 * ...
 * @author Darksider
 */
class GameCell extends FlxSprite
{
	private var _pos:FlxPoint;
	public var row(get, default):Int;
	public var col(get, default):Int;
	
	public function new(x:Float, y:Float, pos:FlxPoint) 
	{
		super(x, y);
		_pos = pos;
		loadGraphic(AssetPaths.Cell__png, false, 100, 100);
	}
	
	public function get_row():Int
	{
		return Std.int(_pos.x);
	}
	
	public function get_col():Int
	{
		return Std.int(_pos.y);
	}
}