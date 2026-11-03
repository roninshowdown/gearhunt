class_name WorldState
extends RefCounted
## Everything the view needs to draw a frame. The host's Simulation writes it;
## clients fill it from snapshots. Views and UI only ever read it.

enum Phase { WAVE, SHOP, VICTORY, DEFEAT }

var tick: int = 0
var phase: Phase = Phase.WAVE
var wave: int = 1
var time_left: float = 0.0
var biome_id: String = ""
var players: Array[PlayerState] = []
var enemies: Array[EnemyState] = []
var projectiles: Array[ProjectileState] = []
var pickups: Array[PickupState] = []
var events: Array[GameEvent] = []
var economy_version: int = 0 ## Bumped when a reliable state update is needed.


func player(player_id: int) -> PlayerState:
	for p in players:
		if p.id == player_id:
			return p
	return null
