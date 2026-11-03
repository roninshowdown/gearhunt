extends Node
## Autoload `Session`. Holds who plays: local slots plus, on the host, the
## shared roster. Offline play uses the same code path as online play.

signal roster_changed
signal match_ready(config: MatchConfig)

const FIRST_PLAYER_ID := 1

var slots: Array[LocalSlot] = []
var roster: Array[Dictionary] = [] ## {player_id, peer_id, local_index, character_id, meta_stats}
var biome_id := ""
var last_config: MatchConfig

var _next_player_id := FIRST_PLAYER_ID


func _ready() -> void:
	Net.lobby_action_received.connect(_on_lobby_action)
	Net.roster_received.connect(_on_roster_received)
	Net.match_start_received.connect(func(data: Dictionary) -> void: _start(MatchConfig.from_dict(data)))
	Net.peer_left.connect(_on_peer_left)


func reset() -> void:
	slots.clear()
	roster.clear()
	_next_player_id = FIRST_PLAYER_ID
	biome_id = Content.sorted_ids(Content.biomes)[0]


func slot_for_device(device: int) -> LocalSlot:
	for slot in slots:
		if slot.device == device:
			return slot
	return null


func add_local_player(device: int) -> LocalSlot:
	if slot_for_device(device) != null or slots.size() >= GameConfig.MAX_LOCAL_PLAYERS:
		return null
	var slot := LocalSlot.new()
	slot.index = slots.size()
	slot.device = device
	slot.character_id = _first_unlocked_character()
	slots.append(slot)
	Net.send_lobby_action({
		"type": "add", "local_index": slot.index, "character_id": slot.character_id,
		"meta_stats": Save.meta_stats(), "version": GameConfig.VERSION,
	})
	return slot


func remove_local_player(slot: LocalSlot) -> void:
	Net.send_lobby_action({"type": "remove", "local_index": slot.index})
	slots.erase(slot)
	for i in slots.size():
		if slots[i].index != i:
			Net.send_lobby_action({"type": "reindex", "from": slots[i].index, "to": i})
			slots[i].index = i


func set_character(slot: LocalSlot, character_id: String) -> void:
	slot.character_id = character_id
	Net.send_lobby_action({"type": "character", "local_index": slot.index, "character_id": character_id})


func set_biome(id: String) -> void:
	if Net.is_host():
		biome_id = id
		_publish_roster()


func can_start() -> bool:
	return Net.is_host() and not roster.is_empty()


func start_match() -> void:
	if not can_start():
		return
	var config := MatchConfig.new()
	config.seed_value = randi()
	config.biome_id = biome_id
	for entry in roster:
		config.loadouts.append({
			"player_id": entry["player_id"], "peer_id": entry["peer_id"],
			"character_id": entry["character_id"], "meta_stats": entry["meta_stats"],
		})
	if Net.is_online():
		Net.broadcast_match_start(config.to_dict())
	_start(config)


func _start(config: MatchConfig) -> void:
	last_config = config
	for slot in slots:
		slot.player_id = _player_id_for(Net.my_peer_id(), slot.index)
	match_ready.emit(config)


func _player_id_for(peer_id: int, local_index: int) -> int:
	for entry in roster:
		if entry["peer_id"] == peer_id and entry["local_index"] == local_index:
			return int(entry["player_id"])
	return -1


func _on_lobby_action(peer_id: int, action: Dictionary) -> void:
	match String(action.get("type", "")):
		"add":
			_add_roster_entry(peer_id, action)
		"remove":
			roster = roster.filter(func(e: Dictionary) -> bool:
				return not (e["peer_id"] == peer_id and e["local_index"] == action.get("local_index")))
		"reindex":
			for entry in roster:
				if entry["peer_id"] == peer_id and entry["local_index"] == action.get("from"):
					entry["local_index"] = action.get("to")
		"character":
			var id := String(action.get("character_id", ""))
			if Content.characters.has(id):
				for entry in roster:
					if entry["peer_id"] == peer_id and entry["local_index"] == action.get("local_index"):
						entry["character_id"] = id
	_publish_roster()


func _add_roster_entry(peer_id: int, action: Dictionary) -> void:
	var id := String(action.get("character_id", ""))
	if action.get("version") != GameConfig.VERSION or roster.size() >= GameConfig.MAX_PLAYERS or not Content.characters.has(id):
		return
	roster.append({
		"player_id": _next_player_id, "peer_id": peer_id,
		"local_index": int(action.get("local_index", 0)), "character_id": id,
		"meta_stats": action.get("meta_stats", {}),
	})
	_next_player_id += 1


func _on_peer_left(peer_id: int) -> void:
	if not Net.is_host():
		return
	roster = roster.filter(func(e: Dictionary) -> bool: return e["peer_id"] != peer_id)
	_publish_roster()


func _publish_roster() -> void:
	if Net.is_online():
		Net.broadcast_roster({"roster": roster, "biome": biome_id})
	roster_changed.emit()


func _on_roster_received(state: Dictionary) -> void:
	roster.assign(state.get("roster", []))
	biome_id = String(state.get("biome", biome_id))
	roster_changed.emit()


func _first_unlocked_character() -> String:
	for id: String in Content.sorted_ids(Content.characters):
		if Save.is_unlocked(Content.character(id)):
			return id
	return Content.sorted_ids(Content.characters)[0]
