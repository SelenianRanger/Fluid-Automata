extends Node

signal grid_updated()

var grid := GameState.grid
var neighbors := GameState.neighbors
var section_grid := GameState.section_grid
var section_grid_neighbors := GameState.section_grid_neighbors

var rules := Rules.new()

func update_tile(x, y) -> int:
	for rule in rules.rules:
		if(rule.call(x, y)):
			mark_subsection(x, y)
			return 1
	return 0

func set_tile(x, y, type):
	var index = Helpers.get_packed_index(Settings.game.grid_size, x, y)
	if(grid[index] == type):
		return
	grid[index] = type
	mark_subsection(x, y)

func mark_subsection(x, y):
	var section_grid_size = Settings.game.grid_size / Settings.game.section_size
	var sub_i = x / Settings.game.section_size[0]
	var sub_j = y / Settings.game.section_size[1]
	section_grid[Helpers.get_packed_index(section_grid_size, sub_i, sub_j)] = 1
	
	for index in section_grid_neighbors[x][y]:
		if(section_grid[Helpers.get_packed_index(section_grid_size, index.x, index.y)] != 1):
			section_grid[Helpers.get_packed_index(section_grid_size, index.x, index.y)] = 2

func reset_grid(fill : PackedByteArray = []) -> void:
	if(fill.size() == 0):
		grid.fill(0)
	else:
		for i in range(grid.size()):
			grid[i] = fill[i]
	section_grid.fill(1)
	emit_signal("grid_updated")

func _init() -> void:
	var section_grid_size = Settings.game.grid_size / Settings.game.section_size
	grid.resize(Settings.game.grid_size.x * Settings.game.grid_size.y)
	neighbors.resize(grid.size())
	section_grid.resize(section_grid_size.x * section_grid_size.y)
	grid.fill(0)
	neighbors.fill(0)
	section_grid.fill(1)
	
	section_grid_neighbors.resize(Settings.game.grid_size.x)
	for i in section_grid_neighbors.size():
		section_grid_neighbors[i].resize(Settings.game.grid_size.y)
		var sub_i = i / Settings.game.section_size.x
		for j in section_grid_neighbors[i].size():
			var sub_j = j / Settings.game.section_size.y
			section_grid_neighbors[i][j] = []
			if( sub_i > 0 && i == sub_i * Settings.game.section_size.x ):
				section_grid_neighbors[i][j].append(Vector2i(sub_i - 1, sub_j))
				if( sub_j > 0 && j == sub_j * Settings.game.section_size.y ) :
					section_grid_neighbors[i][j].append(Vector2i(sub_i - 1, sub_j - 1))
				elif( sub_j < section_grid_size.y - 1 && j == (sub_j + 1) * Settings.game.section_size.y - 1 ):
					section_grid_neighbors[i][j].append(Vector2i(sub_i - 1, sub_j + 1))
			elif( sub_i < section_grid_size.x - 1 && i == (sub_i + 1) * Settings.game.section_size.x - 1 ):
				section_grid_neighbors[i][j].append(Vector2i(sub_i + 1, sub_j))
				if( sub_j > 0 && j == sub_j * Settings.game.section_size.y ) :
					section_grid_neighbors[i][j].append(Vector2i(sub_i + 1, sub_j - 1))
				elif( sub_j < section_grid_size.y - 1 && j == (sub_j + 1) * Settings.game.section_size.y - 1 ):
					section_grid_neighbors[i][j].append(Vector2i(sub_i + 1, sub_j + 1))
			if( sub_j > 0 && j == sub_j * Settings.game.section_size.y ) :
				section_grid_neighbors[i][j].append(Vector2i(sub_i, sub_j - 1))
			elif( sub_j < section_grid_size.y - 1 && j == (sub_j + 1) * Settings.game.section_size.y - 1 ):
				section_grid_neighbors[i][j].append(Vector2i(sub_i, sub_j + 1))

func _ready() -> void:
	$Timer.wait_time = 1.0 / GameState.update_speed
	emit_signal("grid_updated")
	$Timer.start()

func update_section_neighbors(section_id) -> void:
	var section_grid_size = Settings.game.grid_size / Settings.game.section_size
	var sub_i = section_id / section_grid_size.y
	var sub_j = section_id % section_grid_size.y
	var index = Helpers.get_packed_index(section_grid_size, sub_i, sub_j)
	if(section_grid[index] != 1):
		return
	var i1 = max(1, sub_i * Settings.game.section_size[0])
	var i2 = min(Settings.game.grid_size[0] - 1, i1 + Settings.game.section_size[0])
	var j1 = max(1, sub_j * Settings.game.section_size[1])
	var j2 = min(Settings.game.grid_size[1] - 1, j1 + Settings.game.section_size[1])
	for x in range(i1, i2):
		for y in range(j1, j2):
			index = Helpers.get_packed_index(Settings.game.grid_size, x, y)
			neighbors[index] = 0
			for i in range(-1, 2):
				for j in range(-1, 2):
					if( i == 0 and j == 0 ):
						continue
					var index2 = Helpers.get_packed_index(Settings.game.grid_size, x + i, y + j)
					neighbors[index] += grid[index2]

func update_section(section_id) -> void:
	var section_grid_size = Settings.game.grid_size / Settings.game.section_size
	var sub_i = section_id / section_grid_size.y
	var sub_j = section_id % section_grid_size.y
	var index = Helpers.get_packed_index(section_grid_size, sub_i, sub_j)
	if(section_grid[index] != 1):
		return
	var tiles_changed = 0
	var i1 = max(1, sub_i * Settings.game.section_size[0])
	var i2 = min(Settings.game.grid_size[0] - 1, i1 + Settings.game.section_size[0])
	var j1 = max(1, sub_j * Settings.game.section_size[1])
	var j2 = min(Settings.game.grid_size[1] - 1, j1 + Settings.game.section_size[1])
	for i in range(i1, i2):
		for j in range(j1, j2):
			tiles_changed += update_tile(i, j)
	if( tiles_changed == 0 && section_grid[index] == 1):
		section_grid[index] = 0

func update_neighbors() -> void:
	var section_grid_size = Settings.game.grid_size / Settings.game.section_size
	var task_id = WorkerThreadPool.add_group_task(update_section_neighbors, section_grid_size.x * section_grid_size.y)
	WorkerThreadPool.wait_for_group_task_completion(task_id)
	
func update_grid():
	var section_grid_size = Settings.game.grid_size / Settings.game.section_size
	var task_id = WorkerThreadPool.add_group_task(update_section, section_grid_size.x * section_grid_size.y)
	WorkerThreadPool.wait_for_group_task_completion(task_id)

func _on_timer_timeout() -> void:
	if(GameState.is_paused):
		return
	update_neighbors()
	update_grid()
	emit_signal("grid_updated")
	
