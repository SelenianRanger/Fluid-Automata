extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_size = Settings.Game.GridSize * 8
	var ratio = float(Settings.Game.GridSize.y) / Settings.Game.GridSize.x
	if(window_size.x < 800):
		window_size = Vector2(1, ratio) * 800
	if(window_size.y > 900):
		window_size = Vector2i(1.0 / ratio, 1) * 900
	window_size += Vector2i(0, 45)
	get_window().size = window_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
