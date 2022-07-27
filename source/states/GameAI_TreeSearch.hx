package states;
import openfl.utils.Object;

/**
 * ...
 * @author Darksider
 */
class GameAI_TreeSearch 
{
	public var divin_deep:Int = 200;
	
	public function new() 
	{
		
	}
	
	public function getMove(gameBoard:GameBoard):String
	{
		gameBoard.copy(gameBoard.saveData, gameBoard.boardData);
		var bestScore:Float = 0; 
		var bestMove:Int = -1;
		
		for (i in 0...4) {
			var res:Object = calcRun(gameBoard, i);
			var score = res.score;
			var moves = res.moves;
			if (score >= bestScore) {
				bestScore = score;
				bestMove = i;
			}
			gameBoard.copy(gameBoard.boardData, gameBoard.saveData);
			trace(moveName(i) + " best score " + score + " moves : " + moves);
		}
		
		return moveName(bestMove);
	}
	
	private function calcRun(gameBoard:GameBoard, move:Int):Object
	{
		var total:Float = 0;
		var total_moves:Int = 0;
		
		for (i in 0...divin_deep) {
			var res:Object = nextMove(gameBoard, move);
			total += res.score;
			total_moves += res.moves;
			gameBoard.copy(gameBoard.boardData, gameBoard.saveData);
		}
		gameBoard.copy(gameBoard.boardData, gameBoard.saveData);
		return {score:total / divin_deep, moves:total_moves / divin_deep};
	}
	
	private function nextMove(gameBoard:GameBoard, move:Int):Object
	{
		var score:Float = 0;
		var res:Object = gameBoard.divinNextGenMove(moveName(move));
		score += res.score;
		gameBoard.divinAddRandomTile();
		
		var moves:Int = 1;
		while (true) {
			if (gameBoard.availableCells().length<1) 
			{
				break;
			}
			var res:Object = gameBoard.divinNextGenMove(moveName(Std.int(Math.random() * 4)));
			
			score += res.score;
			gameBoard.divinAddRandomTile();
			moves ++;
		}
		
		return {score:score, moves:moves};
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