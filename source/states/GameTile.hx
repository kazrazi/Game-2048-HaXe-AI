package states;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Constraints.Function;

/**
 * ...
 * @author Darksider
 */
class GameTile extends FlxSpriteGroup
{
	private var _text:FlxText;
	private var _moveSpeed:Float = 0.1;
	private var _back:FlxSprite;
	
	public var row(get, default):Int;
	public var col(get, default):Int;
	public var value(get, set):Int;
	public var merged(get, set):Bool;
	
	private var _value:Int = 0;
	private var _row:Int;
	private var _col:Int;
	private var _merged:Bool = false;
	
	public function new(x:Float, y:Float) 
	{
		super(x, y);
		
		_back = new FlxSprite();
		_back.loadGraphic(AssetPaths.Tile__png, false, 100, 100);
		add(_back);
		
		_text = new FlxText(0, 30, 100);
		_text.size = 20;
		_text.alignment = FlxTextAlign.CENTER;
		add(_text);
		
		Math.random() > 0.9?value = 4:value = 2;
		_back.scale = new FlxPoint(0.4, 0.4);
		var tween:FlxTween = FlxTween.tween(_back, { x: x, y: y, "scale.x": 0.95, "scale.y": 0.95}, 0.2);
		tween.start();
	}
	
	public function set_value(value:Int):Int
	{
		_value = value;
		_text.text = Std.string(value);
		_text.color = getTextColor(value);
		_back.color = getBackColor(value);
		return _value;
	}
	
	public function get_value():Int
	{
		return _value;
	}
	
	public function setCord(col:Int, row:Int):Void
	{
		_col = col;
		_row = row;
	}
	
	public function get_row():Int
	{
		return _row;
	}
	
	public function get_col():Int
	{
		return _col;
	}
	
	public function get_merged():Bool
	{
		return _merged;
	}
	
	public function set_merged(value:Bool):Bool
	{
		_merged = value;
		return _merged;
	}
	
	public function getTextColor(value:Int):FlxColor
	{
		switch (value) {
			case 2:
				return 0x776e65;
			case 4:
				return 0x776e65;
			default:
				return 0xf9f6f2;
		}
	}
	
	public function getBackColor(value:Int):FlxColor
	{
		switch (value) {
			case 2:
				return 0xeee4da;
			case 4:
				return 0xede0c8;
			case 8:
				return 0xf2b179;
			case 16:
				return 0xf59563;
			case 32:
				return 0xf67c5f;
			case 64:
				return 0xf65e3b;
			case 128:
				return 0xedcf72;
			case 256:
				return 0xedcc61;
			case 512:
				return 0xedc850;
			case 1024:
				return 0xedc53f;
			case 2048:
				return 0xedc22e;
			default:
				return 0xedc22e;
		}
	}
	
	public function moveTo(point:FlxPoint, destroy:Bool = false):Void
	{
		var tweenOption:TweenOptions = {};
		if (destroy){
			tweenOption = {onComplete:tweenDestroy.bind()};
		}
		var tween:FlxTween = FlxTween.linearMotion(this, this.x, this.y, point.x, point.y, _moveSpeed, true, tweenOption);
		tween.type = FlxTweenType.ONESHOT;
		tween.start();
	}
	
	function tweenDestroy(ft:FlxTween):Void
	{
		this.destroy();
	}
	
	
	
}