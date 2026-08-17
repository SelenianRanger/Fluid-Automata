extends Node

func get_packed_index(size : Vector2i, x, y) -> int:
	return (x * size.y) + y

func get_packed_coords(size : Vector2i, index : int) -> Vector2i:
	return Vector2i(index / size.y, index % size.y)
