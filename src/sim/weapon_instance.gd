class_name WeaponInstance
extends RefCounted

var weapon_id: String
var cooldown: float = 0.0


func _init(p_weapon_id: String = "") -> void:
	weapon_id = p_weapon_id
