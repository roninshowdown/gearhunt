extends Node
## Autoload `Save`. Versioned JSON profile with atomic writes: the old file is
## only replaced once the new one is complete, so a crash cannot corrupt it.

signal changed

const PATH := "user://profile.json"
const SAVE_VERSION := 1

var data: Dictionary = _defaults()
var path := PATH


func _enter_tree() -> void:
	load_profile()


func load_profile() -> void:
	data = _defaults()
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary:
		data.merge(parsed, true)
	else:
		push_warning("Profile unreadable, starting fresh.")
	_migrate()
	_apply_settings()


func store() -> void:
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write profile: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if DirAccess.rename_absolute(temp, path) != OK:
		DirAccess.remove_absolute(path)
		DirAccess.rename_absolute(temp, path)
	changed.emit()


func soul_dust() -> int:
	return int(data["soul_dust"])


func is_unlocked(character: CharacterDef) -> bool:
	return character.unlock_cost <= 0 or data["unlocked"].has(character.id)


func unlock(character: CharacterDef) -> bool:
	if is_unlocked(character) or soul_dust() < character.unlock_cost:
		return false
	data["soul_dust"] = soul_dust() - character.unlock_cost
	data["unlocked"].append(character.id)
	store()
	return true


func upgrade_rank(upgrade: MetaUpgradeDef) -> int:
	return int(data["upgrades"].get(upgrade.id, 0))


func buy_upgrade(upgrade: MetaUpgradeDef) -> bool:
	var rank := upgrade_rank(upgrade)
	var cost := upgrade.cost_for_rank(rank)
	if rank >= upgrade.max_rank or soul_dust() < cost:
		return false
	data["soul_dust"] = soul_dust() - cost
	data["upgrades"][upgrade.id] = rank + 1
	store()
	return true


## Sum of all purchased permanent bonuses, applied at run start.
func meta_stats() -> Dictionary:
	var result := {}
	for upgrade: MetaUpgradeDef in Content.meta_upgrades.values():
		var rank := upgrade_rank(upgrade)
		if rank > 0:
			result[upgrade.stat] = float(result.get(upgrade.stat, 0.0)) + upgrade.per_rank * rank
	return result


func award_soul_dust(amount: int) -> void:
	data["soul_dust"] = soul_dust() + maxi(amount, 0)
	data["runs"] = int(data["runs"]) + 1
	store()


func set_setting(key: String, value: Variant) -> void:
	data["settings"][key] = value
	_apply_settings()
	store()


func setting(key: String) -> Variant:
	return data["settings"].get(key)


func _apply_settings() -> void:
	var settings: Dictionary = data["settings"]
	if String(settings["language"]) != "":
		TranslationServer.set_locale(String(settings["language"]))
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(mode)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(float(settings["volume"]), 0.0001)))


func _migrate() -> void:
	# Future format changes: `if data["version"] < 2: ...`
	data["version"] = SAVE_VERSION


static func _defaults() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"soul_dust": 0,
		"runs": 0,
		"unlocked": [],
		"upgrades": {},
		"settings": {"language": "", "fullscreen": false, "volume": 0.8},
	}
