extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Settings.Game.SectionSize

func _on_overlays_updated() -> void:
	for i in range(Settings.Game.SectionGridSize.x):
		for j in range(Settings.Game.SectionGridSize.y):
			var index = GridUtils.GetPackedIndex(Settings.Game.SectionGridSize, Vector2i(i, j))
			set_cell(Vector2i(i, j), 0, Vector2i(GameState.SectionGrid[index], 0))
			
