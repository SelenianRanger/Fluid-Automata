extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_size = Settings.Game.GridSize * 8
	var ratio = float(Settings.Game.GridSize.x) / Settings.Game.GridSize.y
	window_size = Vector2i(ratio, 1) * 800
	window_size += Vector2i(0, 90)
	get_window().size = window_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
