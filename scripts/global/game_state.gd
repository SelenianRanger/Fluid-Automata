extends Node

var brush := PackedByteArray()
var grid := PackedByteArray()
var neighbors := PackedByteArray()
var section_grid := PackedByteArray()
var section_grid_neighbors : Array[Array] = []

var is_paused := false
@onready var update_speed := Settings.game.update_speed
