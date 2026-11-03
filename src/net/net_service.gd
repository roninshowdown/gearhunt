extends Node
## Autoload `Net`. Owns the connection and every RPC. The game is host
## authoritative: clients send intents and commands, the host sends state.

signal connected_to_host
signal connection_failed
signal disconnected(reason: String)
signal peer_left(peer_id: int)
signal lobby_action_received(peer_id: int, action: Dictionary)
signal roster_received(state: Dictionary)
signal match_start_received(config: Dictionary)
signal intent_received(peer_id: int, player_id: int, intent: PlayerIntent)
signal command_received(peer_id: int, player_id: int, command: Dictionary)
signal snapshot_received(bytes: PackedByteArray)
signal economy_received(data: Dictionary)

var transport: NetTransport = ENetTransport.new()


func _ready() -> void:
	multiplayer.peer_disconnected.connect(func(id: int) -> void: peer_left.emit(id))
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_failed)
	multiplayer.server_disconnected.connect(_on_server_lost)


func is_online() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer


func is_host() -> bool:
	return multiplayer.is_server()


func my_peer_id() -> int:
	return multiplayer.get_unique_id()


func host(port: int = GameConfig.DEFAULT_PORT) -> bool:
	var peer := transport.create_host(port, GameConfig.MAX_PLAYERS - 1)
	if peer == null:
		return false
	multiplayer.multiplayer_peer = peer
	return true


func join(address: String, port: int = GameConfig.DEFAULT_PORT) -> bool:
	var peer := transport.create_client(address, port)
	if peer == null:
		return false
	multiplayer.multiplayer_peer = peer
	return true


func leave() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


# --- Client to host ---------------------------------------------------------

func send_lobby_action(action: Dictionary) -> void:
	if is_host():
		lobby_action_received.emit(my_peer_id(), action)
	else:
		_rpc_lobby_action.rpc_id(1, action)


func send_intent(player_id: int, intent: PlayerIntent) -> void:
	_rpc_intent.rpc_id(1, player_id, intent.move, intent.aim, intent.attacking)


func send_command(player_id: int, command: Dictionary) -> void:
	_rpc_command.rpc_id(1, player_id, command)


# --- Host to clients --------------------------------------------------------

func broadcast_roster(state: Dictionary) -> void:
	_rpc_roster.rpc(state)


func broadcast_match_start(config: Dictionary) -> void:
	_rpc_match_start.rpc(config)


func broadcast_snapshot(bytes: PackedByteArray) -> void:
	_rpc_snapshot.rpc(bytes)


func broadcast_economy(data: Dictionary) -> void:
	_rpc_economy.rpc(data)


# --- RPC endpoints ----------------------------------------------------------

@rpc("any_peer", "call_remote", "reliable")
func _rpc_lobby_action(action: Dictionary) -> void:
	if is_host():
		lobby_action_received.emit(multiplayer.get_remote_sender_id(), action)


@rpc("any_peer", "call_remote", "unreliable_ordered")
func _rpc_intent(player_id: int, move: Vector2, aim: Vector2, attacking: bool) -> void:
	if not is_host():
		return
	var intent := PlayerIntent.new()
	intent.move = move
	intent.aim = aim
	intent.attacking = attacking
	intent_received.emit(multiplayer.get_remote_sender_id(), player_id, intent)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_command(player_id: int, command: Dictionary) -> void:
	if is_host():
		command_received.emit(multiplayer.get_remote_sender_id(), player_id, command)


@rpc("authority", "call_remote", "reliable")
func _rpc_roster(state: Dictionary) -> void:
	roster_received.emit(state)


@rpc("authority", "call_remote", "reliable")
func _rpc_match_start(config: Dictionary) -> void:
	match_start_received.emit(config)


@rpc("authority", "call_remote", "unreliable_ordered")
func _rpc_snapshot(bytes: PackedByteArray) -> void:
	snapshot_received.emit(bytes)


@rpc("authority", "call_remote", "reliable")
func _rpc_economy(data: Dictionary) -> void:
	economy_received.emit(data)


func _on_connected() -> void:
	connected_to_host.emit()


func _on_failed() -> void:
	leave()
	connection_failed.emit()


func _on_server_lost() -> void:
	leave()
	disconnected.emit("NET_HOST_LOST")
