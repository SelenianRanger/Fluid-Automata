extends Node

signal grid_updated(grid : Array[Array])

var grid : Array[Array] = []
var grid_delta : Array[Array] = []
var is_paused = false

func set_tile(x, y, type):
	if(grid[x][y] == type):
		return
	grid[x][y] = type
	emit_signal("grid_updated", grid)

func update_tile(x, y) -> void:
	for rule : Callable in $Rules.rules:
		rule.call(x, y)

func reset_grid() -> void:
	for i in range(grid.size()):
		grid[i].fill(0)
	emit_signal("grid_updated", grid)

func _ready() -> void:
	grid.resize(get_parent().grid_size[0])
	grid_delta.resize(get_parent().grid_size[0])
	for i in range(grid.size()):
		grid[i] = []
		grid[i].resize(get_parent().grid_size[1])
		grid[i].fill(0)
		grid_delta[i] = []
		grid_delta[i].resize(get_parent().grid_size[1])
		grid_delta[i].fill(0)
	$Rules.init()
	emit_signal("grid_updated", grid)

func _on_timer_timeout() -> void:
	if(get_parent().is_paused):
		return
	$Rules.on_grid_updated()
	for i in range(1, grid.size() - 1):
		for j in range(1, grid[i].size() - 1):
			grid_delta[i][j] = grid[i][j]
			update_tile(i, j)
			if( grid_delta[i][j] != grid[i][j] ):
				grid_delta[i][j] = grid[i][j]
			else:
				grid_delta[i][j] = -1
	emit_signal("grid_updated", grid_delta)
	
