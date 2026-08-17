extends Node

signal grid_updated()

var grid := Globals.grid
var neighbors := Globals.neighbors
var section_grid := Globals.section_grid
var section_grid_neighbors := Globals.section_grid_neighbors

var rules := Rules.new()

var is_paused = false

func update_tile(x, y) -> int:
	for rule in rules.rules:
		if(rule.call(x, y)):
			mark_subsection(x, y)
			return 1
	return 0

func set_tile(x, y, type):
	var index = Globals.getPackedIndex(Globals.grid_size, x, y)
	if(grid[index] == type):
		return
	grid[index] = type
	mark_subsection(x, y)

func mark_subsection(x, y):
	var section_grid_size = Globals.grid_size / Globals.section_size
	var sub_i = x / Globals.section_size[0]
	var sub_j = y / Globals.section_size[1]
	section_grid[Globals.getPackedIndex(section_grid_size, sub_i, sub_j)] = 1
	
	for index in section_grid_neighbors[x][y]:
		if(section_grid[Globals.getPackedIndex(section_grid_size, index.x, index.y)] != 1):
			section_grid[Globals.getPackedIndex(section_grid_size, index.x, index.y)] = 2

func reset_grid() -> void:
	grid.fill(0)
	section_grid.fill(1)
	emit_signal("grid_updated")

func _init() -> void:
	var section_grid_size = Globals.grid_size / Globals.section_size
	grid.resize(Globals.grid_size.x * Globals.grid_size.y)
	neighbors.resize(grid.size())
	section_grid.resize(section_grid_size.x * section_grid_size.y)
	grid.fill(0)
	neighbors.fill(0)
	section_grid.fill(1)
	
	section_grid_neighbors.resize(Globals.grid_size.x)
	for i in section_grid_neighbors.size():
		section_grid_neighbors[i].resize(Globals.grid_size.y)
		var sub_i = i / Globals.section_size.x
		for j in section_grid_neighbors[i].size():
			var sub_j = j / Globals.section_size.y
			section_grid_neighbors[i][j] = []
			if( sub_i > 0 && i == sub_i * Globals.section_size.x ):
				section_grid_neighbors[i][j].append(Vector2i(sub_i - 1, sub_j))
				if( sub_j > 0 && j == sub_j * Globals.section_size.y ) :
					section_grid_neighbors[i][j].append(Vector2i(sub_i - 1, sub_j - 1))
				elif( sub_j < section_grid_size.y - 1 && j == (sub_j + 1) * Globals.section_size.y - 1 ):
					section_grid_neighbors[i][j].append(Vector2i(sub_i - 1, sub_j + 1))
			elif( sub_i < section_grid_size.x - 1 && i == (sub_i + 1) * Globals.section_size.x - 1 ):
				section_grid_neighbors[i][j].append(Vector2i(sub_i + 1, sub_j))
				if( sub_j > 0 && j == sub_j * Globals.section_size.y ) :
					section_grid_neighbors[i][j].append(Vector2i(sub_i + 1, sub_j - 1))
				elif( sub_j < section_grid_size.y - 1 && j == (sub_j + 1) * Globals.section_size.y - 1 ):
					section_grid_neighbors[i][j].append(Vector2i(sub_i + 1, sub_j + 1))
			if( sub_j > 0 && j == sub_j * Globals.section_size.y ) :
				section_grid_neighbors[i][j].append(Vector2i(sub_i, sub_j - 1))
			elif( sub_j < section_grid_size.y - 1 && j == (sub_j + 1) * Globals.section_size.y - 1 ):
				section_grid_neighbors[i][j].append(Vector2i(sub_i, sub_j + 1))

func _ready() -> void:
	$Timer.wait_time = 1.0 / Globals.update_speed
	emit_signal("grid_updated")
	$Timer.start()

func update_section_neighbors(section_id) -> void:
	var section_grid_size = Globals.grid_size / Globals.section_size
	var sub_i = section_id / section_grid_size.y
	var sub_j = section_id % section_grid_size.y
	var index = Globals.getPackedIndex(section_grid_size, sub_i, sub_j)
	if(section_grid[index] != 1):
		return
	var i1 = max(1, sub_i * Globals.section_size[0])
	var i2 = min(Globals.grid_size[0] - 1, i1 + Globals.section_size[0])
	var j1 = max(1, sub_j * Globals.section_size[1])
	var j2 = min(Globals.grid_size[1] - 1, j1 + Globals.section_size[1])
	for x in range(i1, i2):
		for y in range(j1, j2):
			index = Globals.getPackedIndex(Globals.grid_size, x, y)
			neighbors[index] = 0
			for i in range(-1, 2):
				for j in range(-1, 2):
					if( i == 0 and j == 0 ):
						continue
					var index2 = Globals.getPackedIndex(Globals.grid_size, x + i, y + j)
					neighbors[index] += grid[index2]

func update_section(section_id) -> void:
	var section_grid_size = Globals.grid_size / Globals.section_size
	var sub_i = section_id / section_grid_size.y
	var sub_j = section_id % section_grid_size.y
	var index = Globals.getPackedIndex(section_grid_size, sub_i, sub_j)
	if(section_grid[index] != 1):
		return
	var tiles_changed = 0
	var i1 = max(1, sub_i * Globals.section_size[0])
	var i2 = min(Globals.grid_size[0] - 1, i1 + Globals.section_size[0])
	var j1 = max(1, sub_j * Globals.section_size[1])
	var j2 = min(Globals.grid_size[1] - 1, j1 + Globals.section_size[1])
	for i in range(i1, i2):
		for j in range(j1, j2):
			tiles_changed += update_tile(i, j)
	if( tiles_changed == 0 && section_grid[index] == 1):
		section_grid[index] = 0

func update_neighbors() -> void:
	var section_grid_size = Globals.grid_size / Globals.section_size
	var task_id = WorkerThreadPool.add_group_task(update_section_neighbors, section_grid_size.x * section_grid_size.y)
	WorkerThreadPool.wait_for_group_task_completion(task_id)
	
func update_grid():
	var section_grid_size = Globals.grid_size / Globals.section_size
	var task_id = WorkerThreadPool.add_group_task(update_section, section_grid_size.x * section_grid_size.y)
	WorkerThreadPool.wait_for_group_task_completion(task_id)

func _on_timer_timeout() -> void:
	if(Globals.is_paused):
		return
	update_neighbors()
	update_grid()
	emit_signal("grid_updated")
	
