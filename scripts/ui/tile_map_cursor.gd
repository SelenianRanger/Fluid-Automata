extends TileMapLayer

var cursor := Globals.cursor

var paint_mode = -1

func _ready() -> void:
	cursor.resize(25)
	for i in range(5):
		for j in range(5):
			var index = Globals.getPackedIndex(Vector2i(5, 5), i, j)
			cursor[index] = get_cell_atlas_coords(Vector2i(i, j)).x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var mouse_coords = local_to_map(get_local_mouse_position())
	if( mouse_coords[0] < 0 || \
		mouse_coords[0] >= 5 || \
		mouse_coords[1] < 0 || \
		mouse_coords[1] >= 5):
			return
	var index = Globals.getPackedIndex(Vector2i(5, 5), mouse_coords.x, mouse_coords.y)
	if(Input.is_action_just_released("cell_paint")):
		paint_mode = -1	
	if(Input.is_action_just_pressed("cell_paint")):
		paint_mode = 1 - cursor[index]
	if(Input.is_action_pressed("cell_paint")):
		set_cell(mouse_coords, 0, Vector2i(paint_mode, 0))
		cursor[index] = paint_mode
	elif(Input.is_action_pressed("cell_erase")):
		set_cell(mouse_coords, 0, Vector2i(0, 0))
		cursor[index] = 0
