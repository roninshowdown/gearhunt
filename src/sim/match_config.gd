class_name MatchConfig
extends RefCounted
## Immutable description of a run. Created by the host, sent to every client.

var seed_value: int = 0
var biome_id: String = ""
var loadouts: Array[Dictionary] = [] ## {player_id, peer_id, character_id, meta_stats}


func to_dict() -> Dictionary:
	return {"seed": seed_value, "biome": biome_id, "loadouts": loadouts}


static func from_dict(data: Dictionary) -> MatchConfig:
	var config := MatchConfig.new()
	config.seed_value = int(data.get("seed", 0))
	config.biome_id = String(data.get("biome", ""))
	for entry: Dictionary in data.get("loadouts", []):
		config.loadouts.append(entry)
	return config
