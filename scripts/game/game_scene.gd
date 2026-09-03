extends Node2D

signal pause_changed()
signal undo_changed()

enum DrawingStatus {
	IDLE,
	DRAWING,
	ERASING
}

var _draw_state = DrawingStatus.IDLE
	
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("restart")):
		$Grid.ResetGrid()
		return
	
	if(Input.is_action_just_pressed("pause")):
		set_paused(!GameState.IsPaused)
	
	if(!GameState.IsPaused):
		return
	
	var mouse_coords = $GameGrid.local_to_map(get_local_mouse_position())
	if( mouse_coords[0] < 0 || \
		mouse_coords[0] >= Settings.Game.GridSize.x - 2 || \
		mouse_coords[1] < 0 || \
		mouse_coords[1] >= Settings.Game.GridSize.y - 2):
			return
	mouse_coords += Vector2i.ONE
	
	if(_draw_state == DrawingStatus.IDLE):
		if (Input.is_action_just_pressed("cell_paint")):
			_draw_state = DrawingStatus.DRAWING
			$Grid.OnPaintStart()
		elif (Input.is_action_just_pressed("cell_erase")):
			_draw_state = DrawingStatus.ERASING
			$Grid.OnPaintStart()
	match _draw_state:
		DrawingStatus.DRAWING:
			if (Input.is_action_just_released("cell_paint")):
				_draw_state = DrawingStatus.IDLE
				$Grid.OnPaintEnd()
				emit_signal("undo_changed")
			elif(Input.is_action_pressed("cell_paint")):
				paint_grid(mouse_coords, 1, Input.is_action_pressed("shift_modifier"))
		DrawingStatus.ERASING:
			if (Input.is_action_just_released("cell_erase")):
				_draw_state = DrawingStatus.IDLE
				$Grid.OnPaintEnd()
				emit_signal("undo_changed")
			elif(Input.is_action_pressed("cell_erase")):
				paint_grid(mouse_coords, 0, Input.is_action_pressed("shift_modifier"))

func set_paused(state : bool):
	if(GameState.IsPaused == state):
		return
	GameState.IsPaused = state
	$PauseOverlay.visible = state
	emit_signal("pause_changed")
	
func paint_grid(pos, color, single_mode = false):
	if(single_mode):
		$Grid.SetTile(pos, color)
		$GameGrid.set_cell(pos - Vector2i.ONE, 0, Vector2i(color, 0))
	else:
		apply_brush(pos, color)

func apply_brush(pos, color):
	for i in range(-2, 3):
			var x = pos.x + i
			if(x < 1 || x > Settings.Game.GridSize.x - 2):
				continue
			for j in range(-2, 3):
				var y = pos.y + j
				if(y < 1 || y > Settings.Game.GridSize.y - 2):
					continue
				var index = GridUtils.GetPackedIndex(Vector2i(5, 5), Vector2i(i + 2, j + 2))
				if(GameState.Brush[index] == 0):
					continue
				$Grid.SetTile(Vector2i(x, y), color)
				$GameGrid.set_cell(Vector2i(x, y) - Vector2i.ONE, 0, Vector2i(color, 0))

func update_camera() -> void:
	$Camera2D.update_camera()

func _on_viewport_resized() -> void:
	call_deferred("update_camera")

func _on_pause_toggled(toggled_on: bool) -> void:
	set_paused(toggled_on)

func _on_next_frame_pressed() -> void:
	$Grid.UpdateTick()
	emit_signal("undo_changed")

func _on_undo_pressed() -> void:
	$Grid.Undo()
	emit_signal("undo_changed")

func _on_speed_changed(value: float) -> void:
	GameState.UpdateSpeed = value
	$Grid/Timer.wait_time = 1.0 / GameState.UpdateSpeed

func _on_overlay_toggled(toggled_on: bool) -> void:
	$SectionOverlay.visible = toggled_on

func _on_reset_pressed() -> void:
	$Grid.ResetGrid()
	emit_signal("undo_changed")

func load_map() -> void:
	set_paused(true)
	$LoadMapDialog.popup_file_dialog()

func save_map() -> void:
	set_paused(true)
	$SaveMapDialog.popup_file_dialog()

func _on_load_map_from_file(path: String) -> void:
	var data = FileAccess.get_file_as_bytes(path)
	if(data.size() != GameState.Grid.size()):
		return
	$Grid.ResetGrid(data)
	emit_signal("undo_changed")

func _on_save_map_to_file(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(GameState.Current.Grid)
	file.close()
