extends Node2D

@export var grid_size : Vector2i = Vector2i(20, 20)

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
		mouse_coords[0] >= grid_size[0] || \
		mouse_coords[1] < 0 || \
		mouse_coords[1] >= grid_size[1]):
			return
	mouse_coords += Vector2i.ONE
	if(Input.is_action_just_released("toggle_cell")):
		paint_mode = -1	
		$Grid/Rules.on_grid_updated()
	if(Input.is_action_just_pressed("toggle_cell")):
		paint_mode = 1 - $Grid.grid[mouse_coords[0]][mouse_coords[1]]
	if(Input.is_action_pressed("toggle_cell")):
		$Grid.set_tile(mouse_coords[0], mouse_coords[1], paint_mode)
		
