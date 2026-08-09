extends TileMapLayer
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_grid_updated(grid_delta) -> void:
	for i in range(1, grid_delta.size() - 1):
		for j in range(1, grid_delta[i].size() - 1):
			if(grid_delta[i][j] == -1):
				continue
			set_cell(Vector2i(i-1, j-1), 0, Vector2i(grid_delta[i][j], 0))
