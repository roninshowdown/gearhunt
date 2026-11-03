class_name SpatialHash
extends RefCounted
## Uniform grid used for all broad-phase queries against enemies.

var cell_size: float
var _cells: Dictionary = {}


func _init(p_cell_size: float = 96.0) -> void:
	cell_size = p_cell_size


func rebuild(enemies: Array[EnemyState]) -> void:
	_cells.clear()
	for e in enemies:
		var key := _key(int(floor(e.pos.x / cell_size)), int(floor(e.pos.y / cell_size)))
		if _cells.has(key):
			_cells[key].append(e)
		else:
			_cells[key] = [e]


func query(center: Vector2, radius: float) -> Array[EnemyState]:
	var result: Array[EnemyState] = []
	var min_x := int(floor((center.x - radius) / cell_size))
	var max_x := int(floor((center.x + radius) / cell_size))
	var min_y := int(floor((center.y - radius) / cell_size))
	var max_y := int(floor((center.y + radius) / cell_size))
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var key := _key(x, y)
			if _cells.has(key):
				result.append_array(_cells[key])
	return result


static func _key(x: int, y: int) -> int:
	return (x + 32768) * 65536 + (y + 32768)
