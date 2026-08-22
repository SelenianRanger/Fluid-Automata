extends Camera2D

func _ready() -> void:
	update_camera()

func update_camera() -> void:
	if(!is_inside_tree()):
		return
	
	var viewport_size = get_viewport_rect().size
	var grid_size = Vector2((Settings.game.grid_size - 2 * Vector2i.ONE) * 16)
	offset = grid_size / 2
	
	var z = viewport_size / grid_size
	zoom = Vector2.ONE * min(z.x, z.y)
