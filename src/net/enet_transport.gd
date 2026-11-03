class_name ENetTransport
extends NetTransport


func create_host(port: int, max_clients: int) -> MultiplayerPeer:
	var peer := ENetMultiplayerPeer.new()
	return peer if peer.create_server(port, max_clients) == OK else null


func create_client(address: String, port: int) -> MultiplayerPeer:
	var peer := ENetMultiplayerPeer.new()
	return peer if peer.create_client(address, port) == OK else null
