extends Node2D

signal pause_changed()

var cursor := Globals.cursor
	
func toggle_pause():
	Globals.is_paused = !Globals.is_paused
	$CanvasModulate.visible = Globals.is_paused
	emit_signal("pause_changed")
	
func apply_cursor(pos, color):
	for i in range(-2, 3):
			var x = pos.x + i
			if(x < 1 || x > Globals.grid_size.x - 2):
				continue
			for j in range(-2, 3):
				var y = pos.y + j
				if(y < 1 || y > Globals.grid_size.y - 2):
					continue
				if(cursor[Helpers.get_packed_index(Vector2i(5, 5), i + 2, j + 2)] == 0):
					continue
				$Grid.set_tile(x, y, color)
				$TileMapLayer.set_cell(Vector2i(x, y) - Vector2i.ONE, 0, Vector2i(color, 0))
	
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("restart")):
		$Grid.reset_grid()
		return
	
	if(Input.is_action_just_pressed("pause")):
		toggle_pause()
	
	if(!Globals.is_paused):
		return
	
	var mouse_coords = $TileMapLayer.local_to_map(get_local_mouse_position())
	if( mouse_coords[0] < 0 || \
		mouse_coords[0] >= Globals.grid_size[0] - 2 || \
		mouse_coords[1] < 0 || \
		mouse_coords[1] >= Globals.grid_size[1] - 2):
			return
	mouse_coords += Vector2i.ONE
	if(Input.is_action_just_released("cell_paint") || \
	Input.is_action_just_released("cell_erase")):
		$Grid.update_neighbors()
	if(Input.is_action_pressed("cell_paint")):
		apply_cursor(mouse_coords, 1)
	elif(Input.is_action_pressed("cell_erase")):
		apply_cursor(mouse_coords, 0)

func update_camera() -> void:
	$Camera2D.update_camera()

func _on_pause_toggled(toggled_on: bool) -> void:
	toggle_pause()

func _on_speed_changed(value: float) -> void:
	Globals.update_speed = value
	$Grid/Timer.wait_time = 1.0 / Globals.update_speed

func _on_reset_pressed() -> void:
	$Grid.reset_grid()

func load_map() -> void:
	$LoadMapDialog.popup_file_dialog()

func save_map() -> void:
	$SaveMapDialog.popup_file_dialog()

func _on_load_map_from_file(path: String) -> void:
	var data = FileAccess.get_file_as_bytes(path)
	if(data.size() != Globals.grid.size()):
		return
	$Grid.reset_grid(data)

func _on_save_map_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(Globals.grid)
	file.close()
