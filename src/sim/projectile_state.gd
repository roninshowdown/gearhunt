class_name ProjectileState
extends RefCounted

enum Team { PLAYERS, ENEMIES }
enum Visual { ARROW, MAGIC, ENEMY_ORB }

var id: int
var team: Team
var owner_id: int
var pos: Vector2
var vel: Vector2
var damage: float
var radius: float
var life: float
var pierce: int
var explosion_radius: float
var knockback: float
var visual: Visual
var already_hit: Dictionary = {}
