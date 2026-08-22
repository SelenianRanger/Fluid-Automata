extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_size = Settings.game.grid_size * 8
	if(window_size.x < 800):
		var ratio = float(window_size.y) / window_size.x
		window_size = Vector2(1, ratio) * 800
	get_window().size = window_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
