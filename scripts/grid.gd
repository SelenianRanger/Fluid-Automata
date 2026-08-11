extends Node

signal grid_updated()

var grid : Array[Array] = []
var section_grid: Array[Array] = []

var is_paused = false

func update_tile(x, y) -> int:
	for rule : Callable in $Rules.rules:
		if(rule.call(x, y)):
			mark_subsection(x, y)
			return 1
	return 0

func set_tile(x, y, type):
	if(grid[x][y] == type):
		return
	grid[x][y] = type
	mark_subsection(x, y)

func mark_subsection(x, y):
	var section_grid_size = Vector2i(section_grid.size(), section_grid[0].size())
	var sub_i = x / Globals.section_size[0]
	var sub_j = y / Globals.section_size[1]
	section_grid[sub_i][sub_j] = 1
	
	if( x == sub_i * Globals.section_size[0] ):
		if( section_grid[max(0, sub_i - 1)][sub_j] != 1 ):
			section_grid[max(0, sub_i - 1)][sub_j] = 2
		if( y == sub_j * Globals.section_size[1] ) :
			if( section_grid[max(0, sub_i - 1)][max(0, sub_j - 1)] != 1 ):
				section_grid[max(0, sub_i - 1)][max(0, sub_j - 1)] = 2
		if( y == (sub_j + 1) * Globals.section_size[1] - 1 ):
			if( section_grid[max(0, sub_i - 1)][min(section_grid_size[1] - 1, sub_j + 1)] != 1 ):
				section_grid[max(0, sub_i - 1)][min(section_grid_size[1] - 1, sub_j + 1)] = 2
	if( x == (sub_i + 1) * Globals.section_size[0] - 1 ):
		if( section_grid[min(section_grid_size[0] - 1, sub_i + 1)][sub_j] != 1 ):
			section_grid[min(section_grid_size[0] - 1, sub_i + 1)][sub_j] = 2
		if( y == sub_j * Globals.section_size[1] ):
			if( section_grid[min(section_grid_size[0] - 1, sub_i + 1)][max(0, sub_j - 1)] != 1 ):
				section_grid[min(section_grid_size[0] - 1, sub_i + 1)][max(0, sub_j - 1)] = 2
		if( y == (sub_j + 1) * Globals.section_size[1] - 1 ):
			if( section_grid[min(section_grid_size[0] - 1, sub_i + 1)][min(section_grid_size[1] - 1, sub_j + 1)] != 1 ):
				section_grid[min(section_grid_size[0] - 1, sub_i + 1)][min(section_grid_size[1] - 1, sub_j + 1)] = 2
	if( y == sub_j * Globals.section_size[1] ):
		if( section_grid[sub_i][max(0, sub_j - 1)] != 1 ):
			section_grid[sub_i][max(0, sub_j - 1)] = 2
	if( y == (sub_j + 1) * Globals.section_size[1] - 1 ):
		if( section_grid[sub_i][min(section_grid_size[1] - 1, sub_j + 1)] != 1 ):
			section_grid[sub_i][min(section_grid_size[1] - 1, sub_j + 1)] = 2

func reset_grid() -> void:
	for i in range(grid.size()):
		grid[i].fill(0)
	for i in range(section_grid.size()):
		section_grid[i].fill(1)
	emit_signal("grid_updated")

func _init() -> void:
	grid = Globals.grid
	section_grid = Globals.section_grid
	grid.resize(Globals.grid_size[0])
	section_grid.resize(ceil(float(grid.size()) / Globals.section_size[0]))
	for i in range(grid.size()):
		grid[i] = []
		grid[i].resize(Globals.grid_size[1])
		grid[i].fill(0)
	for i in range(section_grid.size()):
		section_grid[i] = []
		section_grid[i].resize(ceil(float(grid[i].size()) / Globals.section_size[1]))
		section_grid[i].fill(1)

func _ready() -> void:
	$Timer.wait_time = 1.0 / Globals.update_speed
	emit_signal("grid_updated")

func _on_timer_timeout() -> void:
	if(get_parent().is_paused):
		return
	$Rules.update_neighbors()
	for sub_i in range(section_grid.size()):
		for sub_j in range(section_grid[sub_i].size()):
			if(section_grid[sub_i][sub_j] == 0):
				continue
			var tiles_changed = 0
			var i1 = max(1, sub_i * Globals.section_size[0])
			var i2 = min(Globals.grid_size[0] - 1, i1 + Globals.section_size[0])
			var j1 = max(1, sub_j * Globals.section_size[1])
			var j2 = min(Globals.grid_size[1] - 1, j1 + Globals.section_size[1])
			for i in range(i1, i2):
				for j in range(j1, j2):
					tiles_changed += update_tile(i, j)
			if( tiles_changed == 0 ):
				section_grid[sub_i][sub_j] = 0
	emit_signal("grid_updated")
	
