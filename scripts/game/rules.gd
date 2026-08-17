class_name Rules
extends RefCounted

var grid := Globals.grid
var neighbors := Globals.neighbors

func underpopulation(x, y) -> bool:
	var index = Globals.getPackedIndex(Globals.grid_size, x, y)
	if( grid[index] == 0 ):
		return false
	if( neighbors[index] < 2 ):
		grid[index] = 0
		return true
	return false
	
func overpopulation(x, y) -> bool:
	var index = Globals.getPackedIndex(Globals.grid_size, x, y)
	if( grid[index] == 0 ):
		return false
	if( neighbors[index] > 3 ):
		grid[index] = 0
		return true
	return false
	
func reproduction(x, y) -> bool:
	var index = Globals.getPackedIndex(Globals.grid_size, x, y)
	if( grid[index] == 1 ):
		return false
	if( neighbors[index] == 3 ):
		grid[index] = 1
		return true
	return false

var rules : Array[Callable] = [
	underpopulation,
	overpopulation,
	reproduction
]
