extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.TimelineUpdated.connect(_on_timeline_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pause_changed() -> void:
	disabled = !GameState.IsPaused || GameState.AtTimelineHead()


func _on_timeline_changed() -> void:
	disabled = !GameState.IsPaused || GameState.AtTimelineHead()
