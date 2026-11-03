extends Node
## Autoload `Content`. Loads every definition below res://content, so adding
## content means adding a .tres file and nothing else.

const ROOT := "res://content/"

var characters: Dictionary = {}
var weapons: Dictionary = {}
var items: Dictionary = {}
var enemies: Dictionary = {}
var biomes: Dictionary = {}
var meta_upgrades: Dictionary = {}

var _enemy_order: Array[EnemyDef] = []
var _enemy_indices: Dictionary = {}


func _enter_tree() -> void:
	characters = _load_folder("characters")
	weapons = _load_folder("weapons")
	items = _load_folder("items")
	enemies = _load_folder("enemies")
	biomes = _load_folder("biomes")
	meta_upgrades = _load_folder("meta")
	# Sorted ids give host and client identical indices for compact snapshots.
	var ids: Array = enemies.keys()
	ids.sort()
	for id: String in ids:
		_enemy_indices[id] = _enemy_order.size()
		_enemy_order.append(enemies[id])


func character(id: String) -> CharacterDef:
	return characters[id]


func weapon(id: String) -> WeaponDef:
	return weapons[id]


func item(id: String) -> ItemDef:
	return items[id]


func enemy(id: String) -> EnemyDef:
	return enemies[id]


func biome(id: String) -> BiomeDef:
	return biomes[id]


func enemy_index(id: String) -> int:
	return _enemy_indices[id]


func enemy_by_index(index: int) -> EnemyDef:
	return _enemy_order[index]


func enemy_count() -> int:
	return _enemy_order.size()


func sorted_ids(table: Dictionary) -> Array:
	var ids: Array = table.keys()
	ids.sort()
	return ids


func _load_folder(folder: String) -> Dictionary:
	var result := {}
	var path := ROOT + folder + "/"
	# list_directory also works in exported builds, where files are remapped.
	for file_name in ResourceLoader.list_directory(path):
		if file_name.ends_with("/"):
			continue
		var def := load(path + file_name) as ContentDef
		if def == null:
			push_error("Not a ContentDef: %s%s" % [path, file_name])
			continue
		result[def.id] = def
	return result
