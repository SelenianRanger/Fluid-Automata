extends Node

var grid : Array[Array] = []
var neighbors : Array[Array] = []

func init() -> void:
	grid = get_parent().grid
	neighbors.resize(grid.size())
	for i in range(neighbors.size()):
		neighbors[i] = []
		neighbors[i].resize(grid[i].size())
		neighbors[i].fill(0)

func on_grid_updated() -> void:
	for i in range(neighbors.size()):
		neighbors[i].fill(0)
	for x in range(1, grid.size() - 1):
		for y in range(1, grid[x].size() - 1):
			for i in range(-1, 2):
				for j in range(-1, 2):
					if( i == 0 and j == 0 ):
						continue
					neighbors[x + i][y + j] += grid[x][y]

func underpopulation(x, y) -> void:
	if( neighbors[x][y] < 2):
		grid[x][y] = 0
	
func overpopulation(x, y) -> void:
	if( neighbors[x][y] > 3):
		grid[x][y] = 0
	
func reproduction(x, y) -> void:
	if( neighbors[x][y] == 3):
		grid[x][y] = 1

var rules : Array[Callable] = [
	underpopulation,
	overpopulation,
	reproduction
]
