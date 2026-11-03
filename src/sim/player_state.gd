class_name PlayerState
extends RefCounted

var id: int
var peer_id: int
var character_id: String
var pos: Vector2
var vel: Vector2
var aim: Vector2 = Vector2.RIGHT
var attacking := false
var hp: float
var regen_buffer: float = 0.0
var invulnerable: float = 0.0
var alive := true
var connected := true

# Slowly changing state; replicated reliably, see SnapshotCodec.
var materials: int = 0
var kills: int = 0
var weapons: Array[WeaponInstance] = []
var items: Array[String] = []
var meta_stats: Dictionary = {}
var stats: Dictionary = {}
var offers: Array[Dictionary] = [] ## {id, kind, price, sold}
var rerolls: int = 0
var ready := false


func stat(key: String) -> float:
	return float(stats.get(key, 0.0))


func max_hp() -> float:
	return maxf(1.0, stat(Stats.MAX_HP))


## All weapon mount points sit on a ring around the player, as in Brotato.
func weapon_mount(index: int) -> Vector2:
	var count := maxi(1, weapons.size())
	return pos + Vector2.from_angle(aim.angle() + TAU * index / count) * 46.0
