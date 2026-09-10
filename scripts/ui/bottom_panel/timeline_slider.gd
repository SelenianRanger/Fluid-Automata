extends HSlider

signal timeline_seeked(value: int)

var _last_value = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.TimelineUpdated.connect(_on_timeline_changed)
	max_value = Settings.Game.UndoCount


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timeline_changed() -> void:
	set_value_no_signal(GameState.CurrentIndex)
	pass


func _on_value_changed(new_value: float) -> void:
	var clamped_value = clamp(new_value, 0, GameState.Timeline.Count - 2)
	set_value_no_signal(clamped_value)
	if(clamped_value != _last_value):
		emit_signal("timeline_seeked", clamped_value)
		_last_value = clamped_value
