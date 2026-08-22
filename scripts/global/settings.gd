extends Node

@export var game : GameSettings

func _init() -> void:
	if(OS.has_feature("web_android") || OS.has_feature("web_ios")):
		game = preload("res://settings/mobile.tres")
	else:
		game = preload("res://settings/default.tres")
