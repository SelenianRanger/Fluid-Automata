extends SubViewportContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_camera()
	
func update_camera() -> void:
	$SubViewport.size = size
	$SubViewport/GameScn.update_camera()

func _on_resized() -> void:
	update_camera()
