package states;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class PlayState extends FlxState
{
	private var _gameAI_Simple:GameAI_Simple;
	private var _gameAI_Expect:GameAI_Expect;
	private var _gameAI_TreeSearch:GameAI_TreeSearch;
	private var _gameBoard:GameBoard;
	private var _restartBtn:FlxButton;
	private var _autoBtn:FlxButton;
	private var _scoreTxt:FlxText;
	private var _scoreBestTxt:FlxText;
	private var _gameWinsTxt:FlxText;
	
	private var _score:Int = 0;
	private var _scoreBest:Int = 0;
	private var _gameWins:Int = 0;
	
	private var _auto:Bool = false;
	private var _cooldown:Float = 0;
	
	public var score(get, default):Int;
	
	override public function create():Void
	{
		super.create();
		_gameAI_Simple = new GameAI_Simple();
		_gameAI_Expect = new GameAI_Expect();
		_gameAI_TreeSearch = new GameAI_TreeSearch();
		
		_restartBtn = new FlxButton(350, 25, "RESTART", restartGame);
		add(_restartBtn);
		
		_autoBtn = new FlxButton(350, 75, "AUTO", autoMove);
		add(_autoBtn);
		
		_scoreTxt = new FlxText(500, 25);
		_scoreTxt.text = "score: " + Std.string(_score);
		_scoreTxt.size = 15;
		add(_scoreTxt);
		
		_scoreBestTxt = new FlxText(500, 75);
		_scoreBestTxt.text = "best: " + Std.string(_scoreBest);
		_scoreBestTxt.size = 15;
		add(_scoreBestTxt);
		
		_gameWinsTxt = new FlxText(450, 550);
		_gameWinsTxt.text = "wins: " + Std.string(_gameWins);
		_gameWinsTxt.size = 15;
		add(_gameWinsTxt);
		
		_gameBoard = new GameBoard();
		add(_gameBoard);
		_gameBoard.startGame();
	}
	
	public function get_score():Int
	{
		return _score;
	}
	
	public function autoMove():Void
	{
		_auto = !_auto;
		_auto?_autoBtn.text = "STOP":_autoBtn.text = "AUTO";
	}
	
	public function appendWins():Void
	{
		_gameWins++;
		_gameWinsTxt.text = "wins: " + Std.string(_gameWins);
	}
	
	public function appendScore(value:Int):Void
	{
		_score += value;
		if (_score > _scoreBest) _scoreBest = _score;
		_scoreTxt.text = "score: " + Std.string(_score);
		_scoreBestTxt.text = "best: " + Std.string(_scoreBest);
	}
	
	public function restartGame():Void
	{
		_score = 0;
		_scoreTxt.text = "score: " + Std.string(_score);
		
		remove(_gameBoard);
		_gameBoard = new GameBoard();
		add(_gameBoard);
		_gameBoard.startGame();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (_auto)
		{
			_cooldown += elapsed;
			if (_cooldown > 0.3)
			{
				//_gameBoard.moveTiles(_gameAI_Expect.getMove(_gameBoard));
				_gameBoard.moveTiles(_gameAI_TreeSearch.getMove(_gameBoard));
				//_gameBoard.moveTiles(_gameAI_Simple.getMove(_gameBoard));
				_cooldown = 0;
			}
		}
		else
		{
			playerControll();
		}
	}
	
	private function playerControll():Void
	{
		if (FlxG.keys.anyJustPressed([LEFT, A]))
		{
			_gameBoard.moveTiles(GameBoard.MOVE_LEFT);
			//_gameBoard.divinNextGenMove(GameBoard.MOVE_LEFT);
		}
		
		if (FlxG.keys.anyJustPressed([RIGHT, D]))
		{
			_gameBoard.moveTiles(GameBoard.MOVE_RIGHT);
			//_gameBoard.divinNextGenMove(GameBoard.MOVE_RIGHT);
		}
		
		if (FlxG.keys.anyJustPressed([UP, W]))
		{
			_gameBoard.moveTiles(GameBoard.MOVE_UP);
			//_gameBoard.divinNextGenMove(GameBoard.MOVE_UP);
		}
		
		if (FlxG.keys.anyJustPressed([DOWN, S]))
		{
			_gameBoard.moveTiles(GameBoard.MOVE_DOWN);
			//_gameBoard.divinNextGenMove(GameBoard.MOVE_DOWN);
		}
	}
}