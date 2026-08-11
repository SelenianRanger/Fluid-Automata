extends Node2D

var is_paused = false
var paint_mode = -1
	
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("restart")):
		$Grid.reset_grid()
		return
	
	if(Input.is_action_just_pressed("pause")):
		is_paused = !is_paused
		$CanvasModulate.visible = is_paused
	
	if(!is_paused):
		return
	
	var mouse_coords = $TileMapLayer.local_to_map(get_local_mouse_position())
	if( mouse_coords[0] < 0 || \
		mouse_coords[0] >= Globals.grid_size[0] - 2 || \
		mouse_coords[1] < 0 || \
		mouse_coords[1] >= Globals.grid_size[1] - 2):
			return
	mouse_coords += Vector2i.ONE
	if(Input.is_action_just_released("toggle_cell")):
		paint_mode = -1	
		$Grid/Rules.update_neighbors()
	if(Input.is_action_just_pressed("toggle_cell")):
		paint_mode = 1 - Globals.grid[mouse_coords[0]][mouse_coords[1]]
	if(Input.is_action_pressed("toggle_cell")):
		$Grid.set_tile(mouse_coords[0], mouse_coords[1], paint_mode)
		$TileMapLayer.set_cell(mouse_coords - Vector2i.ONE, 0, Vector2i(paint_mode, 0))
		
