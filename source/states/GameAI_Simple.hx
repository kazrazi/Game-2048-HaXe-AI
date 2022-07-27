package states;
import flixel.FlxG;
import openfl.geom.Point;
import openfl.utils.Object;
/**
 * ...
 * @author Darksider
 */
class GameAI_Simple 
{
	private var _max:Int = 2;
	
	private var cluster:Array<Array<Int>> = 
	[
		[15, 14, 13, 12], 
		[8, 9, 10, 11],
		[7, 6, 5, 4],
		[0, 1, 2, 3]
	];
	
	public function new() 
	{
		
	}
	
	public function getMove(gameBoard:GameBoard):String
	{
		var bestScore:Int = 0;
		var bestMove:String = GameBoard.MOVE_UP;
		_max = getMaxValue(gameBoard.boardData);
		for (i in 0...4)
		{
			var moveScore:Int = 0;
			var divinLength:Int = emptyLength(gameBoard.boardData);
			for (j in 0...divinLength)
			{
				gameBoard.copy(gameBoard.saveData, gameBoard.boardData);
				var score:Int = calcGoffyScore(gameBoard.divinMove(moveName(i)));
				gameBoard.copy(gameBoard.boardData, gameBoard.saveData);
				if (score > moveScore){
					moveScore = score;
				}
			}
			
			if (moveScore > bestScore){
				bestScore =  moveScore;
				bestMove = moveName(i);
			}
			
		}
		
		return bestMove;
	}
	
	private function calcGoffyScore(data:Array<Array<Int>>):Int
	{
		var value:Int = 0;
		if (emptyLength(data)==0){
			return value;
		}
		if (data[0][0] == _max)
		{
			value += 4000 * _max;
		}
		
		for (i in 0...GameBoard.BOARD_SIZE)
		{
			for (j in 0...GameBoard.BOARD_SIZE)
			{
				if (data[i][j] == 0)
				{
					value += 2000*_max;
				}
				else
				{
					value += data[i][j] * cluster[i][j] * _max;
				}
			}
		}
		
		value += getNeighbourScore(data)*_max*4;
		
		return value;
	}
	
	private function getNeighbourScore(data:Array<Array<Int>>):Int
	{
		var value:Int = 0;
		for (i in 1...GameBoard.BOARD_SIZE-1)
		{
			for (j in 1...GameBoard.BOARD_SIZE-1)
			{
				if (data[i][j] == data[i][j + 1])
				{
					value += data[i][j];
				}
				if (data[i][j] == data[i][j - 1])
				{
					value += data[i][j];
				}
				if (data[i][j] == data[i + 1][j])
				{
					value += data[i][j];
				}
				if (data[i][j] == data[i - 1][j])
				{
					value += data[i][j];
				}
			}
		}
		return value;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////
	
	private function emptyLength(data:Array<Array<Int>>):Int
	{
		var value:Int = 0;
		for (i in 0...GameBoard.BOARD_SIZE)
		{
			for (j in 0...GameBoard.BOARD_SIZE)
			{
				if (data[i][j] == 0){
					value++;
				}
				
			}
		}
		return value;
	}
	
	private function getEmptyTiles(data:Array<Array<Int>>):Array<Point>
	{
		var result:Array<Point> = [];
		for (i in 0...GameBoard.BOARD_SIZE)
		{
			for (j in 0...GameBoard.BOARD_SIZE)
			{
				if (data[i][j] == 0){
					result.push(new Point(i, j));
				}
				
			}
		}
		return result;
	}
	
	private function getMaxValue(data:Array<Array<Int>>):Int
	{
		var value:Int = 2;
		for (i in 0...GameBoard.BOARD_SIZE)
		{
			for (j in 0...GameBoard.BOARD_SIZE)
			{
				if (data[i][j] > value)
				{
					value = data[i][j];
				}
			}
		}
		return value;
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
	
	public function getRandomMove(gameBoard:GameBoard):String
	{
		var rand:Int = Std.int(Math.random() * 4);
		var result:String = GameBoard.MOVE_LEFT;
		switch (rand) {
			case 0:
				return GameBoard.MOVE_UP;
			case 1:
				return GameBoard.MOVE_RIGHT;
			case 2:
				return GameBoard.MOVE_DOWN;
			case 3:
				return GameBoard.MOVE_LEFT;
		}
		return result;
	}
	
}