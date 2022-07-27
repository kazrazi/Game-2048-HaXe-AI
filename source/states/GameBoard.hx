package states;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import openfl.geom.Point;
import openfl.utils.Object;
/**
 * ...
 * @author Darksider
 */
class GameBoard extends FlxSpriteGroup
{
	private var _cluster:Array<Array<Int>> = 
						   [[ 6,  5,  4,  1],
							[ 5,  4,  1,  0],
							[ 4,  1,  0, -1],
							[ 1,  0, -1, -2]];
	
	
	public static inline var WIN_VALUE:Int = 4096;
	
	public static inline var BOARD_SIZE:Int = 4;
	
	public static inline var MOVE_UP:String = "up";
	public static inline var MOVE_DOWN:String = "down";
	public static inline var MOVE_LEFT:String = "left";
	public static inline var MOVE_RIGHT:String = "right";
	
	public var boardData(get, set):Array<Array<Int>>;
	public var saveData(get, set):Array<Array<Int>>;
	public var gameTiles(get, set):Array<GameTile>;
	public var saveTiles(get, set):Array<GameTile>;
	public var maxTileValue(get, default):Int;
	
	private var _back:FlxSprite;
	
	private var _gameCells:Array<GameCell> = [];
	private var _gameTiles:Array<GameTile> = [];
	private var _saveTiles:Array<GameTile> = [];
	
	private var _boardData:Array<Array<Int>> = [];
	private var _saveData:Array<Array<Int>> = [];
	
	private var _gameOver:Bool = false;
	
	private var _maxTileValue:Int = 2;
	
	public function new() 
	{
		super(0, 0);
		_back = new FlxSprite();
		_back.loadGraphic(AssetPaths.Board__png, false, 100, 100);
		_back.setGraphicSize(100 * BOARD_SIZE, 100 * BOARD_SIZE);
		add(_back);
		
		_back.x = (camera.width - _back.graphic.width) / 2;
		_back.y = (camera.height - _back.graphic.height) / 2;
		initCells();
	}
	
	public function startGame():Void
	{
		addRandomTile();
		addRandomTile();
	}
	
	private function eval(gameBoard:GameBoard):Float{
		var emptyCells:Int = gameBoard.availableCells().length;

		var smoothWeight:Float = 0.1;
		var monoWeight:Float   = 1.0;
		var emptyWeight:Float  = 2.7;
		var maxWeight:Float   = 1.0;

		return gameBoard.smoothness() * smoothWeight
			+ gameBoard.monotonicity() * monoWeight
			+ Math.log(emptyCells) * emptyWeight
			+ gameBoard.maxValue() * maxWeight;
	};
	
	/////////////////////////// EXPECTIMAX BEGIN ///////////////////////////////////////
	
	public function getScore():Float 
	{
		var score = 0;
		
		for (i in 0...BOARD_SIZE)
		{
			for (j in 0...BOARD_SIZE)
			{
				score += _cluster[i][j] * _boardData[i][j] * _boardData[i][j];
			}
		}
		var penalty:Float = getNeighbourScore(_boardData);
		return score - penalty;
	}
	
	public function getNeighbourScore(data:Array<Array<Int>>):Float
	{
		var value:Float = 0;
		var direct:Array<Array<Int>> = [[1, 0], [0, 1], [-1, 0], [0, -1]];
		for (i in 0...GameBoard.BOARD_SIZE)
		{
			for (j in 0...GameBoard.BOARD_SIZE)
			{
				if (data[i][j] != 0)
				{
					for (k in 0...4)
					{
						var pos:Object = {"x" : i + direct[k][0], "y" : j + direct[k][1]};
						if (withinBounds(pos))
						{
							var neighbour = data[pos.x][pos.y];
							if (neighbour != 0)
							{
								value += (Math.abs(neighbour - _boardData[i][j]) * 1);
							}
						}
					}
				}
			}
		}
		return value;
	}
	
	public function withinBounds(pos:Object):Bool {
		var value:Bool = false;
		if ((pos.x >= 0) && (pos.x < BOARD_SIZE) &&
			(pos.y >= 0) && (pos.y < BOARD_SIZE))
			{
					value = true;
			}
		return value;
	};
	
	/////////////////////////// EXPECTIMAX BEGIN ///////////////////////////////////////
	
	/////////////////////////// NEXT GEN BEGIN ///////////////////////////////////////
	
	public function divinNextGenMove(vector:String):Object
	{
		var score:Float = 0;
		var movePos:FlxPoint = new FlxPoint(0, 0);
		var moved:Bool = false;
		var isWin:Bool = false;
		
		switch (vector) {
			case MOVE_UP:
				movePos.x = 1;
			case MOVE_DOWN:
				movePos.x = -1;
			case MOVE_LEFT:
				movePos.y = 1;
			case MOVE_RIGHT:
				movePos.y = -1;
		}
		
		for (i in 0...BOARD_SIZE)
		{
			if (movePos.y != 0)
			{
				var col:Array<Object> = getColData(i, movePos.y);
				for (k in 0...4)
				{
					for (j in 0...col.length)
					{
						var curr:Object = col[j];
						var next:Object = col[j - 1];
						if (next != null)
						{
							if (next.value == 0)
							{
								next.value = curr.value;
								_boardData[curr.x][curr.y] = 0;
								_boardData[next.x][next.y] = next.value;
								curr.value = 0;
								moved = true;
							}
							else
							if ((next.value == curr.value)&&(next.merged==false)&&(curr.merged==false))
							{
								next.value = curr.value * 2;
								next.merged = true;
								_boardData[curr.x][curr.y] = 0;
								_boardData[next.x][next.y] = next.value;
								curr.value = 0;
								score += next.value;
								moved = true;
								if (next.value == WIN_VALUE)
								{
									isWin = true;
								}
							}
						}
					}
				}
			}
			
			if (movePos.x != 0)
			{
				var row:Array<Object> = getRowData(i, movePos.x);
				for (k in 0...4)
				{
					for (j in 0...row.length)
					{
						var curr:Object = row[j];
						var next:Object = row[j - 1];
						if (next != null)
						{
							if (next.value == 0)
							{
								next.value = curr.value;
								_boardData[curr.x][curr.y] = 0;
								_boardData[next.x][next.y] = next.value;
								curr.value = 0;
								moved = true;
							}
							else
							if ((next.value == curr.value)&&(next.merged==false)&&(curr.merged==false))
							{
								next.value = curr.value * 2;
								next.merged = true;
								_boardData[curr.x][curr.y] = 0;
								_boardData[next.x][next.y] = next.value;
								curr.value = 0;
								score += next.value;
								moved = true;
								if (next.value == WIN_VALUE)
								{
									isWin = true;
								}
							}
						}
					}
				}
			}
		}
		
		return {score:score, moved:moved, isWin:isWin};
	}
	
	public function divinAddRandomTile():Void
	{
		var cell:GameCell = getRandomCell();
		if (cell != null){
			var value:Int = 2;
			Math.random() > 0.9?value = 4:value = 2;
			_boardData[cell.col][cell.row] = value;
		}
	}
	
	public function movesAvailable():Bool
	{
		if (getRandomCell() != null)
		{
			return true;
		}
		
		if (tileMatchesAvailable())
		{
			return true;
		}
		return false;
	}
	
	private function tileMatchesAvailable():Bool
	{
		for (i in 0...4)
		{
			for (j in 0...4)
			{
				for (k in 0...4) {
						var movePos:Point = new Point(0, 0);
						switch (moveName(k)) {
							case MOVE_UP:
								movePos.x = -1;
							case MOVE_DOWN:
								movePos.x = 1;
							case MOVE_LEFT:
								movePos.y = -1;
							case MOVE_RIGHT:
								movePos.y = 1;
						}
						
						if ((i == 0) && (movePos.x < 0))
						{
							break;
						}
						if ((i == 3) && (movePos.x > 0))
						{
							break;
						}
						if ((j == 0) && (movePos.y < 0))
						{
							break;
						}
						if ((j == 3) && (movePos.y > 0))
						{
							break;
						}
							
						var tile = _boardData[i][j];
						var next = _boardData[i + Std.int(movePos.x)][j + Std.int(movePos.y)];
						if ((next != null)&&(tile==next)&&(tile!=0))
						{
							return true;
						}
				}
			}
		}
		return false;
	}
	
	public function availableCells():Array<GameCell>
	{
		var cells:Array<GameCell> = [];
		for (i in 0...BOARD_SIZE)
		{
			for (j in 0...BOARD_SIZE)
			{
				if (_boardData[i][j] == 0)
				{
					cells.push(getCell(i, j));
				}
			}
		}
		return cells;
	}
	
	public function maxValue():Float
	{
		var max:Int = 0;
		for (i in 0...BOARD_SIZE)
		{
			for (j in 0...BOARD_SIZE)
			{
				if (_boardData[i][j] > max)
				{
					max = _boardData[i][j];
				}
			}
		}
		return Math.log(max) / Math.log(2);
	}
	
	public function monotonicity():Float {
		var totals:Array<Float> = [0, 0, 0, 0];
		
		for (x in 0...4) {
			var current:Int = 0;
			var next:Int = current+1;
			while (next < 4) {
				while ((next<4) && (_boardData[x][next]!=0)) {
					next++;
				}
				if (next >= 4) 
				{
					next--; 
				}
			
				var currentValue:Float = 0;
				if ((_boardData[x][current] != null) && (_boardData[x][current] != 0))
				{
					currentValue = Math.log(_boardData[x][current]) / Math.log(2);
				}
				var nextValue:Float = 0; 
				if ((_boardData[x][next]!= null) && (_boardData[x][next] != 0)) 
				{
					nextValue = Math.log(_boardData[x][next]) / Math.log(2);
				}
				
				if (currentValue > nextValue) {
					totals[0] += nextValue - currentValue;
				} else if (nextValue > currentValue) {
					totals[1] += currentValue - nextValue;
				}
				current = next;
				next++;
			}
		}
	  
		for (y in 0...4) {
			var current:Int = 0;
			var next:Int = current+1;
			while (next < 4) {
				while ((next<4) && (_boardData[next][y]!=0)) {
					next++;
				}
				if (next >= 4) 
				{
					next--; 
				}
			
				var currentValue:Float = 0;
				if ((_boardData[current][y] != null) && (_boardData[current][y] != 0))
				{
					currentValue = Math.log(_boardData[current][y]) / Math.log(2);
				}
				var nextValue:Float = 0; 
				if ((_boardData[next][y]!= null) && (_boardData[next][y] != 0)) 
				{
					nextValue = Math.log(_boardData[next][y]) / Math.log(2);
				}
				
				if (currentValue > nextValue) {
					totals[0] += nextValue - currentValue;
				} else if (nextValue > currentValue) {
					totals[1] += currentValue - nextValue;
				}
				current = next;
				next++;
			}
		}

		return Math.max(totals[0], totals[1]) + Math.max(totals[2], totals[3]);
	}
	
	public function smoothness():Float{
		var smoothness:Float = 0;
		for (i in 0...BOARD_SIZE) {
			for (j in 0...BOARD_SIZE) {
				if (_boardData[i][j] != 0)
				{
					var value:Float = Math.log(_boardData[i][j] / Math.log(2));
					for (k in 1...2)
					{
						var movePos:FlxPoint = new FlxPoint(0, 0);
						switch (moveName(k)) {
							case MOVE_UP:
								movePos.x = -1;
							case MOVE_DOWN:
								movePos.x = 1;
							case MOVE_LEFT:
								movePos.y = -1;
							case MOVE_RIGHT:
								movePos.y = 1;
						}
						var tile:GameTile = getTile(i, j);
						if (tile != null)
						{
							var targetCell:GameCell = findFarthestPosition(tile, movePos);
							var targetValue = _boardData[targetCell.col][targetCell.row];
							if (targetValue != 0)
							{
								var smoothValue:Float = Math.log(targetValue) / Math.log(2);
								smoothness -= Math.abs(value - smoothValue);
							}
						}
					}
				}
			}
		}
		return smoothness;
	}
	
	private function findFarthestPosition(tile:GameTile, movePos:FlxPoint):GameCell{
		var tileCol:Int = tile.col;
		var tileRow:Int = tile.row;
		
		for (i in 0...BOARD_SIZE)
		{
			var nextCol:Int = tileCol + Std.int(movePos.x);
			var nextRow:Int = tileRow + Std.int(movePos.y);
			
			if (nextCol < 0)
			{
				break;
			}
			if (nextCol > BOARD_SIZE-1)
			{
				break;
			}
			if (nextRow < 0)
			{
				break;
			}
			if (nextRow > BOARD_SIZE-1)
			{
				break;
			}
			
			if (_boardData[nextCol][nextRow] == 0){
				tileCol += Std.int(movePos.x);
				tileRow += Std.int(movePos.y);
			}
			
			if (_boardData[nextCol][nextRow] == tile.value){
				tileCol += Std.int(movePos.x);
				tileRow += Std.int(movePos.y);
			}
		}
		
		return getCell(tileCol, tileRow);
	}
	
	/////////////////////////// NEXT GEN END ///////////////////////////////////////
	
	public function divinMove(vector:String):Array<Array<Int>>
	{
		moveTiles(vector, true);
		return _boardData;
	}
	
	public function moveTiles(vector:String, divin:Bool = false):Void
	{
		if (_gameOver) return;
		
		var movePos:FlxPoint = new FlxPoint(0, 0);
		switch (vector) {
			case MOVE_UP:
				movePos.x = -1;
			case MOVE_DOWN:
				movePos.x = 1;
			case MOVE_LEFT:
				movePos.y = -1;
			case MOVE_RIGHT:
				movePos.y = 1;
		}
		
		for (i in 0...BOARD_SIZE)
		{
			if (movePos.y != 0)
			{
				var tiles:Array<GameTile> = getCol(i, movePos.y);
				for (j in 0...tiles.length)
				{
					var tile:GameTile = tiles[j];
					var cell:GameCell = getNextCell(tile, movePos);
					moveTile(tile, cell, movePos, divin);
				}
			}
			if (movePos.x != 0)
			{
				var tiles:Array<GameTile> = getRow(i, movePos.x);
				for (j in 0...tiles.length)
				{
					var tile:GameTile = tiles[j];
					var cell:GameCell = getNextCell(tile, movePos);
					moveTile(tile, cell, movePos, divin);
				}
			}
		}
		
		addRandomTile(divin);
		resetMerge();
	}
	
	private function resetMerge():Void
	{
		for (i in 0..._gameTiles.length)
		{
			_gameTiles[i].merged = false;
		}
	}
	
	private function moveTile(tile:GameTile, cell:GameCell, movePos:FlxPoint, divin:Bool = false):Void
	{
		_boardData[tile.col][tile.row] = 0;
		_boardData[cell.col][cell.row] = tile.value;
		if (!divin)
		{
			tile.moveTo(cell.getPosition());
			tile.setCord(cell.col, cell.row);
		}
		
		var nextCol:Int = cell.col + Std.int(movePos.x);
		var nextRow:Int = cell.row + Std.int(movePos.y);
		var nextTile:GameTile = getTile(nextCol, nextRow);
		if (nextTile != null)
		{
			if ((nextTile.value == tile.value)&&(!nextTile.merged)){
				_boardData[nextTile.col][nextTile.row] = tile.value;
				_boardData[tile.col][tile.row] = 0;
				if (divin){
					return;
				}
				
				nextTile.value = tile.value * 2;
				nextTile.merged = true;
				
				_gameTiles.splice(_gameTiles.indexOf(tile), 1);
				tile.moveTo(cell.getPosition(), true);
				
				var state:PlayState = cast FlxG.state;
				state.appendScore(nextTile.value);
				if (nextTile.value > _maxTileValue)
				{
					_maxTileValue = nextTile.value;
				}
				if (nextTile.value == WIN_VALUE)
				{
					state.appendWins();
					state.restartGame();
				}
			}
		}
	}
	
	private function getNextCell(tile:GameTile, movePos:FlxPoint):GameCell{
		var tileCol:Int = tile.col;
		var tileRow:Int = tile.row;
		
		for (i in 0...BOARD_SIZE)
		{
			var nextCol:Int = tileCol + Std.int(movePos.x);
			var nextRow:Int = tileRow + Std.int(movePos.y);
			
			if (nextCol < 0)
			{
				break;
			}
			if (nextCol > BOARD_SIZE-1)
			{
				break;
			}
			if (nextRow < 0)
			{
				break;
			}
			if (nextRow > BOARD_SIZE-1)
			{
				break;
			}
			
			if (_boardData[nextCol][nextRow] == 0){
				tileCol += Std.int(movePos.x);
				tileRow += Std.int(movePos.y);
			}
		}
		
		return getCell(tileCol, tileRow);
	}
	
	private function initCells():Void
	{
		for (i in 0...BOARD_SIZE)
		{
			_boardData[i] = new Array();
			for (j in 0...BOARD_SIZE)
			{
				var cell:GameCell = new GameCell(100 * i + _back.x - 150, 100 * j + _back.y - 150, new FlxPoint(i, j));
				_gameCells.push(cell);
				add(cell);
				_boardData[i][j] = 0;
			}
		}
	}
	
	private function addTile(value:Int, col:Int, row:Int)
	{
		var cell:GameCell = getCell(col, row);
		var tile:GameTile = new GameTile(cell.x, cell.y);
		tile.setCord(cell.col, cell.row);
		_gameTiles.push(tile);
		add(tile);
		tile.value = value;
		_boardData[cell.col][cell.row] = tile.value;
	}
	
	public function addRandomTile(divin:Bool = false):Void
	{
		var cell:GameCell = getRandomCell();
		if (cell == null){
			if (divin){
				return;
			}
			var gameOver:FlxText = new FlxText();
			gameOver.text = "GAME OVER";
			gameOver.size = 100;
			gameOver.x = (camera.width - gameOver.width) / 2;
			gameOver.y = (camera.height - gameOver.height) / 2;
			add(gameOver);
			_gameOver = true;
			return;
		}
		
		var tile:GameTile = new GameTile(cell.x, cell.y);
		tile.setCord(cell.col, cell.row);
		_boardData[cell.col][cell.row] = tile.value;
		if (divin)
		{
			return;
		}
		_gameTiles.push(tile);
		add(tile);
	}
	
	public function get_maxTileValue():Int
	{
		return _maxTileValue;
	}
	
	private function getRandomCell():GameCell
	{
		var emptyCells:Array<GameCell> = [];
		for (i in 0...BOARD_SIZE)
		{
			for (j in 0...BOARD_SIZE)
			{
				if (_boardData[i][j] == 0){
					emptyCells.push(getCell(i, j));
				}
			}
		}
		
		if (emptyCells.length == 0){
			return null;
		}
		
		var rand:Int = Std.int(Math.random() * emptyCells.length);
		return emptyCells[rand];
	}
	
	private function getRowData(id:Int, movePos:Float):Array<Object>
	{
		var value:Array<Object> = [];
		for (i in 0...BOARD_SIZE)
		{
			var obj:Object = {value:boardData[i][id],x:i,y:id,merged:false}
			value.push(obj);
		}
		if (movePos ==-1)
		{
			value.reverse();
		}
		return value;
	}
	
	private function getColData(id:Int, movePos:Float):Array<Object>
	{
		var value:Array<Object> = [];
		for (i in 0...BOARD_SIZE)
		{
			var obj:Object = {value:boardData[id][i],x:id,y:i,merged:false}
			value.push(obj);
		}
		if (movePos ==-1)
		{
			value.reverse();
		}
		return value;
	}
	
	private function getRow(id:Int, movePos:Float):Array<GameTile>
	{
		var value:Array<GameTile> = [];
		for (i in 0...BOARD_SIZE)
		{
			var tile:GameTile = getTile(i, id);
			if (tile != null){
				value.push(getTile(i, id));
			}
		}
		if (movePos ==1)
		{
			value.reverse();
		}
		return value;
	}
	
	private function getCol(id:Int, movePos:Float):Array<GameTile>
	{
		var value:Array<GameTile> = [];
		for (i in 0...BOARD_SIZE)
		{
			var tile:GameTile = getTile(id, i);
			if (tile != null){
				value.push(getTile(id, i));
			}
		}
		if (movePos ==1)
		{
			value.reverse();
		}
		return value;
	}
	
	private function getCell(col:Int, row:Int):GameCell
	{
		for (i in 0..._gameCells.length)
		{
			var cell:GameCell = _gameCells[i];
			if ((cell.col == col) && (cell.row == row)){
				return cell;
			}
		}
		return null;
	}
	
	private function getTile(col:Int, row:Int):GameTile
	{
		for (i in 0..._gameTiles.length)
		{
			var tile:GameTile = _gameTiles[i];
			if ((tile.col == col) && (tile.row == row)){
				return tile;
			}
		}
		return null;
	}
	
	public function get_saveData():Array<Array<Int>>
	{
		return _saveData;
	}
	
	public function set_saveData(value:Array<Array<Int>>):Array<Array<Int>>
	{
		_saveData = value;
		return value;
	}
	
	public function get_boardData():Array<Array<Int>>
	{
		return _boardData;
	}
	
	public function set_boardData(value:Array<Array<Int>>):Array<Array<Int>>
	{
		_boardData = value;
		return value;
	}
	
	public function get_gameTiles():Array<GameTile>
	{
		return _gameTiles;
	}
	
	public function set_gameTiles(value:Array<GameTile>):Array<GameTile>
	{
		_gameTiles = value;
		return _gameTiles;
	}
	
	public function get_saveTiles():Array<GameTile>
	{
		return _saveTiles;
	}
	
	public function set_saveTiles(value:Array<GameTile>):Array<GameTile>
	{
		_saveTiles = value;
		return _saveTiles;
	}
	
	public function traceBoardData():Void
	{
		trace("____________________________");
		for (i in 0...BOARD_SIZE)
		{
			trace(_boardData[i]);
		}
	}
	
	public function copyTiles(target:Array<GameTile>, from:Array<GameTile>):Void
	{
		for (i in 0...from.length)
		{
			target[i] = from[i];
		}
	}
	
	public function copy(target:Array<Array<Int>>, from:Array<Array<Int>>):Array<Array<Int>>
	{
		for (i in 0...BOARD_SIZE)
		{
			target[i] = new Array();
			for (j in 0...BOARD_SIZE)
			{
				target[i][j] = from[i][j];
			}
		}
		return target;
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