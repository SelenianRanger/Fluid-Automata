extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size = get_viewport_rect().size
	var grid_size = (get_parent().grid_size - 2 * Vector2i.ONE) * 16
	offset = grid_size / 2
	
	var zoom_x = viewport_size.x / grid_size.x
	var zoom_y = viewport_size.y / grid_size.y
	zoom = Vector2.ONE * min(zoom_x, zoom_y)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
