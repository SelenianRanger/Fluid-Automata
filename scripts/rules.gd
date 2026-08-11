extends Node

var grid : Array[Array] = []
var section_grid: Array[Array] = []
var neighbors : Array[Array] = []

func _init() -> void:
	neighbors.resize(Globals.grid_size[0])
	for i in range(neighbors.size()):
		neighbors[i] = []
		neighbors[i].resize(Globals.grid_size[1])
		neighbors[i].fill(0)
		
func _ready() -> void:
	grid = Globals.grid
	section_grid = Globals.section_grid

func update_neighbors() -> void:
	for sub_i in range(section_grid.size()):
		for sub_j in range(section_grid[sub_i].size()):
			if(section_grid[sub_i][sub_j] == 0):
				continue
			var i1 = max(1, sub_i * Globals.section_size[0])
			var i2 = min(Globals.grid_size[0] - 1, i1 + Globals.section_size[0])
			var j1 = max(1, sub_j * Globals.section_size[1])
			var j2 = min(Globals.grid_size[1] - 1, j1 + Globals.section_size[1])
			for x in range(i1, i2):
				for y in range(j1, j2):
					neighbors[x][y] = 0
					for i in range(-1, 2):
						for j in range(-1, 2):
							if( i == 0 and j == 0 ):
								continue
							neighbors[x][y] += grid[x + i][y + j]

func underpopulation(x, y) -> bool:
	if( grid[x][y] == 0 ):
		return false
	if( neighbors[x][y] < 2 ):
		grid[x][y] = 0
		return true
	return false
	
func overpopulation(x, y) -> bool:
	if( grid[x][y] == 0 ):
		return false
	if( neighbors[x][y] > 3 ):
		grid[x][y] = 0
		return true
	return false
	
func reproduction(x, y) -> bool:
	if( grid[x][y] == 1 ):
		return false
	if( neighbors[x][y] == 3 ):
		grid[x][y] = 1
		return true
	return false

var rules : Array[Callable] = [
	underpopulation,
	overpopulation,
	reproduction
]
