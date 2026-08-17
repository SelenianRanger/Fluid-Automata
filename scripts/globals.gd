extends Node

@export var grid_size : Vector2i = Vector2i(60, 60)
@export var section_size: Vector2i = Vector2i(20, 20)
@export var update_speed : float = 10

var cursor := PackedByteArray()
var grid := PackedByteArray()
var neighbors := PackedByteArray()
var section_grid := PackedByteArray()
var section_grid_neighbors : Array[Array] = []

var is_paused = false

func getPackedIndex(size : Vector2i, x, y) -> int:
	return (x * size.y) + y
