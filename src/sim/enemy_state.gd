class_name EnemyState
extends RefCounted

var id: int
var def_index: int
var pos: Vector2
var vel: Vector2
var aim: Vector2 = Vector2.RIGHT
var knockback: Vector2
var radius: float
var hp: float
var max_hp: float
var damage_scale: float = 1.0
var spawn_left: float = 0.0
var state: int = 0
var timer: float = 0.0


func is_active() -> bool:
	return spawn_left <= 0.0
