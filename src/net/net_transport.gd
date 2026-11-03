class_name NetTransport
extends RefCounted
## Creates the MultiplayerPeer. Everything above this class is independent of
## how packets travel, so a Steam relay transport can replace ENet later by
## adding one subclass (see docs/ROADMAP.md).


func create_host(_port: int, _max_clients: int) -> MultiplayerPeer:
	return null


func create_client(_address: String, _port: int) -> MultiplayerPeer:
	return null
