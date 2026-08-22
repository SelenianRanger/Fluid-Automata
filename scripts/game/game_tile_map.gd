extends TileMapLayer
	
func _on_grid_updated() -> void:
	var grid = GameState.grid
	var section_grid = GameState.section_grid
	var section_grid_size = Settings.game.grid_size / Settings.game.section_size
	for sub_i in range(section_grid_size.x):
		for sub_j in range(section_grid_size.y):
			var index = Helpers.get_packed_index(section_grid_size, sub_i, sub_j)
			if(section_grid[index] == 0):
				continue
			if(section_grid[index] > 1):
				section_grid[index] = 1
				continue
			var i1 = max(1, sub_i * Settings.game.section_size[0])
			var i2 = min(Settings.game.grid_size[0] - 1, i1 + Settings.game.section_size[0])
			var j1 = max(1, sub_j * Settings.game.section_size[1])
			var j2 = min(Settings.game.grid_size[1] - 1, j1 + Settings.game.section_size[1])
			for i in range(i1, i2):
				for j in range(j1, j2):
					index = Helpers.get_packed_index(Settings.game.grid_size, i, j)
					set_cell(Vector2i(i-1, j-1), 0, Vector2i(grid[index], 0))
