extends Node

@export var grid_size : Vector2i = Vector2i(60, 60)
@export var section_size: Vector2i = Vector2i(20, 20)

@export var update_speed : int = 10

var grid : Array[Array] = []
var section_grid: Array[Array] = []
