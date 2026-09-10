extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.TimelineUpdated.connect(_update_text)
	_update_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _update_text() -> void:
	text = "%04d" % (GameState.CurrentFrame)
