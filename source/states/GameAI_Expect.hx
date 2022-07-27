package states;
import flixel.math.FlxMath;
import openfl.utils.Object;

/**
 * ...
 * @author Darksider
 */
class GameAI_Expect 
{

	public static var ENEMY:Int = 1;
	public static var PLAYER:Int = 0;
	
	public var divin_deep:Int = 6;
	
	public function new()
	{
		
	}
	
	public function getMove(gameBoard:GameBoard):String
	{
		var score:Float = FlxMath.MIN_VALUE_FLOAT;
		var bestMove:Int = 0;
		
		/*if (gameBoard.availableCells().length < 5){
			divin_deep = 6;
		}else
		{
			divin_deep = 4;
		}*/
		
		gameBoard.copy(gameBoard.saveData, gameBoard.boardData);
		for (i in 0...4)
		{
			var res:Object = gameBoard.divinNextGenMove(moveName(i));
			if (res.moved == false)
			{
				continue;
			}

			var moveScore:Float = expectimax(gameBoard, divin_deep, ENEMY);
			
			if (moveScore > score)
			{
				bestMove = i;
				score = moveScore;
			}
			gameBoard.copy(gameBoard.boardData, gameBoard.saveData);
		}

		return moveName(bestMove);
	}
	
	public function expectimax(gameBoard:GameBoard, depth:Int, agent:Int):Float
	{
		if (depth == 0)
		{
			return gameBoard.getScore();
		}
		else 
		if (agent == PLAYER) 
		{
			var score:Float = FlxMath.MIN_VALUE_FLOAT;
			
			var tmp:Array<Array<Int>> = [];
			tmp = gameBoard.copy(tmp, gameBoard.boardData);
			
			for (i in 0...4)
			{
				var res:Object = gameBoard.divinNextGenMove(moveName(i));
				if (res.moved == false) {
					continue;
				}
				
				var moveScore:Float = expectimax(gameBoard, depth - 1, ENEMY);
				
				if (moveScore > score)
				{
					score = moveScore;
				}
				gameBoard.copy(gameBoard.boardData, tmp);
			}
			return score;
		}
		else 
		if (agent == ENEMY)
		{
			var score:Float = 0;
			var tmp:Array<Array<Int>> = [];
			tmp = gameBoard.copy(tmp, gameBoard.boardData);
			
			var cells:Array<GameCell> = gameBoard.availableCells();
			
			for (i in 0...cells.length)
			{
				var cell:GameCell = cells[i];
				gameBoard.boardData[cell.col][cell.row] = 4;
				
				var enemyScore = expectimax(gameBoard, depth - 1, PLAYER);
				if (enemyScore != FlxMath.MIN_VALUE_FLOAT)
				{
					score += (0.1 * enemyScore);
				}
				gameBoard.copy(gameBoard.boardData, tmp);
				
				gameBoard.boardData[cell.col][cell.row] = 2;
				enemyScore = expectimax(gameBoard, depth - 1, PLAYER);
				if (enemyScore != FlxMath.MIN_VALUE_FLOAT)
				{
					score += (0.9 * enemyScore);
				}
				gameBoard.copy(gameBoard.boardData, tmp);
			}
			
			return score / cells.length;
		}
		return 0;
	}
	
	private function moveName(value:Int):String
	{
		switch(value){
			case 0:
				return GameBoard.MOVE_UP;
			case 1:
				return GameBoard.MOVE_RIGHT;
			case 2:
				return GameBoard.MOVE_DOWN;
			case 3:
				return GameBoard.MOVE_LEFT;
		}
		return GameBoard.MOVE_UP;
	}
	
}