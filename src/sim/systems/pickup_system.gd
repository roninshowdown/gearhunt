class_name PickupSystem
extends RefCounted

const COLLECT_DISTANCE := 34.0
const ATTRACT_SPEED := 720.0


static func step(sim: Simulation, dt: float) -> void:
	var pickups := sim.world.pickups
	var write := 0
	for read in pickups.size():
		var pickup := pickups[read]
		var collector := sim.nearest_living_player(pickup.pos)
		if collector != null:
			var distance := pickup.pos.distance_to(collector.pos)
			if distance < COLLECT_DISTANCE:
				_collect(sim, collector, pickup)
				continue
			if pickup.attracted_to >= 0 or distance < collector.stat(Stats.PICKUP_RANGE):
				pickup.attracted_to = collector.id
				pickup.pos = pickup.pos.move_toward(collector.pos, ATTRACT_SPEED * dt)
		pickups[write] = pickup
		write += 1
	pickups.resize(write)


## Pays out everything left on the floor when a wave ends.
static func collect_all(sim: Simulation) -> void:
	var players := sim.world.players
	if players.is_empty():
		return
	for pickup in sim.world.pickups:
		var collector := sim.nearest_living_player(pickup.pos)
		if collector == null:
			collector = players[0]
		collector.materials += pickup.value
	sim.world.pickups.clear()
	sim.mark_economy_dirty()


static func _collect(sim: Simulation, p: PlayerState, pickup: PickupState) -> void:
	p.materials += pickup.value
	sim.emit_event(GameEvent.Type.PICKUP, pickup.pos, p.id)
	sim.mark_economy_dirty()
