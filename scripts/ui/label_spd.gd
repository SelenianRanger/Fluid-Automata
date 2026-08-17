extends Label

func _on_h_slider_value_changed(value: float) -> void:
	text = "%.1f/s" % value
