class_name MatchController
extends Node
## Runs one match. On the host it steps the Simulation, on clients it mirrors
## snapshots. UI and view talk only to this class, so they work identically
## offline, as host and as client.

signal events_ready(events: Array[GameEvent])
signal phase_changed(phase: WorldState.Phase)
signal economy_changed

var world: WorldState
var simulation: Simulation ## Null on clients.
var paused := false
var mouse_world := Vector2.ZERO
var scripted_intents: Dictionary = {} ## Replaces device input; for tests and future bots.

var _remote_intents: Dictionary = {}
var _event_outbox: Array[GameEvent] = []
var _last_phase: int = -1
var _sent_economy_version := -1
var _seen_economy_version := -1


func setup(config: MatchConfig) -> void:
	if Net.is_host():
		simulation = Simulation.new(config)
		world = simulation.world
		Net.intent_received.connect(_on_intent)
		Net.command_received.connect(_on_command)
		Net.peer_left.connect(simulation.disconnect_peer)
	else:
		world = _make_client_world(config)
		Net.snapshot_received.connect(_on_snapshot)
		Net.economy_received.connect(_on_economy)


func send_command(player_id: int, command: Dictionary) -> void:
	if simulation != null:
		simulation.apply_command(player_id, command)
	else:
		Net.send_command(player_id, command)


func _physics_process(_delta: float) -> void:
	if world == null:
		return
	var intents := _collect_local_intents()
	if simulation != null:
		if not paused:
			_step_host(intents)
	else:
		for player_id: int in intents:
			Net.send_intent(player_id, intents[player_id])
	_notify_changes()


func _collect_local_intents() -> Dictionary:
	var intents := {}
	for slot in Session.slots:
		var player := world.player(slot.player_id)
		if player != null:
			intents[slot.player_id] = Inputs.read_intent(slot, player.pos, mouse_world)
	intents.merge(scripted_intents, true)
	return intents


func _step_host(local_intents: Dictionary) -> void:
	local_intents.merge(_remote_intents)
	simulation.step(GameConfig.TICK_DT, local_intents)
	var events: Array[GameEvent] = world.events.duplicate()
	world.events.clear()
	if not events.is_empty():
		events_ready.emit(events)
	if not Net.is_online():
		return
	_event_outbox.append_array(events)
	if world.economy_version != _sent_economy_version:
		_sent_economy_version = world.economy_version
		Net.broadcast_economy(SnapshotCodec.encode_economy(world))
	if world.tick % GameConfig.SNAPSHOT_INTERVAL_TICKS == 0:
		Net.broadcast_snapshot(SnapshotCodec.encode_snapshot(world, _event_outbox))
		_event_outbox.clear()


func _notify_changes() -> void:
	if world.phase != _last_phase:
		_last_phase = world.phase
		phase_changed.emit(world.phase)
	if world.economy_version != _seen_economy_version:
		_seen_economy_version = world.economy_version
		economy_changed.emit()


func _make_client_world(config: MatchConfig) -> WorldState:
	var mirror := WorldState.new()
	mirror.biome_id = config.biome_id
	for loadout in config.loadouts:
		var p := PlayerState.new()
		p.id = int(loadout["player_id"])
		p.peer_id = int(loadout["peer_id"])
		p.character_id = String(loadout["character_id"])
		p.meta_stats = loadout.get("meta_stats", {})
		StatSystem.recompute(p)
		p.hp = p.max_hp()
		mirror.players.append(p)
	return mirror


func _on_intent(peer_id: int, player_id: int, intent: PlayerIntent) -> void:
	if _owns(peer_id, player_id):
		_remote_intents[player_id] = intent


func _on_command(peer_id: int, player_id: int, command: Dictionary) -> void:
	if _owns(peer_id, player_id):
		simulation.apply_command(player_id, command)


func _owns(peer_id: int, player_id: int) -> bool:
	var p := world.player(player_id)
	return p != null and p.peer_id == peer_id


func _on_snapshot(bytes: PackedByteArray) -> void:
	var events := SnapshotCodec.apply_snapshot(world, bytes)
	if not events.is_empty():
		events_ready.emit(events)


func _on_economy(data: Dictionary) -> void:
	SnapshotCodec.apply_economy(world, data)
