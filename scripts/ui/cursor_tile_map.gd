extends TileMapLayer

var cursor := Globals.cursor
var cursor_default : PackedByteArray

var paint_mode = -1

func reset_cursor() -> void:
	for i in range(cursor.size()):
		var coords = Globals.get_packed_coords(Vector2i(5, 5), i)
		cursor[i] = cursor_default[i]
		set_cell(coords, 0, Vector2i(cursor[i], 0))

func _ready() -> void:
	cursor.resize(25)
	for i in range(5):
		for j in range(5):
			var index = Globals.get_packed_index(Vector2i(5, 5), i, j)
			cursor[index] = get_cell_atlas_coords(Vector2i(i, j)).x
	cursor_default = cursor.duplicate()

func _input(event: InputEvent) -> void:
	var mouse_coords = local_to_map(get_local_mouse_position())
	if( mouse_coords[0] < 0 || \
		mouse_coords[0] >= 5 || \
		mouse_coords[1] < 0 || \
		mouse_coords[1] >= 5):
			return
	var index = Globals.get_packed_index(Vector2i(5, 5), mouse_coords.x, mouse_coords.y)
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

func load_cursor() -> void:
	$LoadCursorDialog.popup_file_dialog()

func save_cursor() -> void:
	$SaveCursorDialog.popup_file_dialog()

func _on_load_cursor_from_file(path: String) -> void:
	var data = FileAccess.get_file_as_bytes(path)
	if(data.size() != 25):
		return
	for i in range(cursor.size()):
		var coords = Globals.get_packed_coords(Vector2i(5, 5), i)
		cursor[i] = data[i]
		set_cell(coords, 0, Vector2i(cursor[i], 0))

func _on_save_cursor_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(cursor)
	file.close()
