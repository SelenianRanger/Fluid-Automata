extends TileMapLayer
	
func _on_grid_updated() -> void:
	for sub_i in range(Settings.Game.SectionGridSize.x):
		for sub_j in range(Settings.Game.SectionGridSize.y):
			var index = GridUtils.GetPackedIndex(Settings.Game.SectionGridSize, Vector2i(sub_i, sub_j))
			if((GameState.SectionGrid[index] & GameState.DRAW) == 0):
				continue
			var i1 = max(1, sub_i * Settings.Game.SectionSize.x)
			var i2 = min(Settings.Game.GridSize.x - 1, i1 + Settings.Game.SectionSize.x)
			var j1 = max(1, sub_j * Settings.Game.SectionSize.y)
			var j2 = min(Settings.Game.GridSize.y - 1, j1 + Settings.Game.SectionSize.y)
			for i in range(i1, i2):
				for j in range(j1, j2):
					index = GridUtils.GetPackedIndex(Settings.Game.GridSize, Vector2i(i, j))
					set_cell(Vector2i(i-1, j-1), 0, Vector2i(GameState.Grid[index], 0))
