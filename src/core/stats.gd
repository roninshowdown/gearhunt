class_name Stats
extends RefCounted
## Canonical stat keys. Content files reference these exact strings; the test
## suite rejects any unknown key, so typos cannot silently do nothing.

const MAX_HP := "max_hp"
const HP_REGEN := "hp_regen"
const ARMOR := "armor"
const MOVE_SPEED := "move_speed"
const DAMAGE_PCT := "damage_pct"
const ATTACK_SPEED_PCT := "attack_speed_pct"
const PICKUP_RANGE := "pickup_range"

const BASE := {
	MAX_HP: 20.0,
	HP_REGEN: 0.0,
	ARMOR: 0.0,
	MOVE_SPEED: 330.0,
	DAMAGE_PCT: 0.0,
	ATTACK_SPEED_PCT: 0.0,
	PICKUP_RANGE: 130.0,
}


static func is_valid(key: String) -> bool:
	return BASE.has(key)
