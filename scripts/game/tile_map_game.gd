extends TileMapLayer
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_grid_updated() -> void:
	var grid = Globals.grid
	var section_grid = Globals.section_grid
	var section_grid_size = Globals.grid_size / Globals.section_size
	for sub_i in range(section_grid_size.x):
		for sub_j in range(section_grid_size.y):
			var index = Globals.getPackedIndex(section_grid_size, sub_i, sub_j)
			if(section_grid[index] == 0):
				continue
			if(section_grid[index] > 1):
				section_grid[index] = 1
				continue
			var i1 = max(1, sub_i * Globals.section_size[0])
			var i2 = min(Globals.grid_size[0] - 1, i1 + Globals.section_size[0])
			var j1 = max(1, sub_j * Globals.section_size[1])
			var j2 = min(Globals.grid_size[1] - 1, j1 + Globals.section_size[1])
			for i in range(i1, i2):
				for j in range(j1, j2):
					index = Globals.getPackedIndex(Globals.grid_size, i, j)
					set_cell(Vector2i(i-1, j-1), 0, Vector2i(grid[index], 0))
