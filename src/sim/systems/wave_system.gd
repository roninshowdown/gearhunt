class_name WaveSystem
extends RefCounted

const BOSS_WAVE := GameConfig.TOTAL_WAVES


class Difficulty:
	var hp: float
	var damage: float


static func wave_duration(wave: int) -> float:
	return minf(20.0 + 5.0 * (wave - 1), 60.0)


static func difficulty(sim: Simulation) -> Difficulty:
	var result := Difficulty.new()
	var wave := float(sim.world.wave - 1)
	var extra_players := float(maxi(sim.world.players.size() - 1, 0))
	result.hp = (1.0 + wave * 0.28) * (1.0 + extra_players * 0.6)
	result.damage = 1.0 + wave * 0.14
	return result


static func begin_wave(sim: Simulation) -> void:
	var world := sim.world
	world.phase = WorldState.Phase.WAVE
	world.time_left = wave_duration(world.wave)
	world.enemies.clear()
	world.projectiles.clear()
	sim.spawn_budget = 3.0
	for p in world.players:
		p.ready = false
		p.offers.clear()
		p.rerolls = 0
		if p.connected and not p.alive:
			p.alive = true
			p.hp = ceilf(p.max_hp() * 0.5)
		elif p.connected:
			p.hp = p.max_hp()
		p.pos = p.pos.limit_length(200.0)
		p.vel = Vector2.ZERO
	if world.wave == BOSS_WAVE and sim.biome.boss != null:
		sim.spawn_enemy(sim.biome.boss, Vector2(0.0, -300.0))
	sim.emit_event(GameEvent.Type.WAVE_START, Vector2.ZERO, 0, world.wave)
	sim.mark_economy_dirty()


static func step(sim: Simulation, dt: float) -> void:
	var world := sim.world
	world.time_left -= dt
	if world.time_left <= 0.0 or _boss_defeated(sim):
		_end_wave(sim)
		return
	var players := float(maxi(sim.living_players().size(), 1))
	var rate := (1.1 + 0.32 * (world.wave - 1)) * (1.0 + (players - 1.0) * 0.6)
	sim.spawn_budget += rate * dt
	while sim.spawn_budget >= 1.0 and world.enemies.size() < GameConfig.MAX_ENEMIES:
		sim.spawn_budget -= 1.0
		var def := _pick_enemy(sim)
		if def != null:
			sim.spawn_enemy(def, _spawn_position(sim))


## Called after the shop closes.
static func advance(sim: Simulation) -> void:
	sim.world.wave += 1
	begin_wave(sim)


static func clamp_to_arena(pos: Vector2, margin: float) -> Vector2:
	var half := GameConfig.ARENA_HALF - Vector2(margin, margin)
	return pos.clamp(-half, half)


static func _boss_defeated(sim: Simulation) -> bool:
	if sim.world.wave != BOSS_WAVE or sim.biome.boss == null:
		return false
	for e in sim.world.enemies:
		if Content.enemy_by_index(e.def_index).is_boss:
			return false
	return true


static func _end_wave(sim: Simulation) -> void:
	var world := sim.world
	world.enemies.clear()
	world.projectiles.clear()
	PickupSystem.collect_all(sim)
	if world.wave >= GameConfig.TOTAL_WAVES:
		world.phase = WorldState.Phase.VICTORY
		sim.mark_economy_dirty()
		return
	world.phase = WorldState.Phase.SHOP
	for p in world.players:
		p.ready = not p.connected
		ShopSystem.roll_offers(sim, p)
	sim.mark_economy_dirty()


static func _pick_enemy(sim: Simulation) -> EnemyDef:
	var total := 0.0
	var eligible: Array[SpawnEntry] = []
	for entry in sim.biome.spawns:
		if sim.world.wave >= entry.first_wave:
			eligible.append(entry)
			total += entry.weight
	var roll := sim.rng.randf() * total
	for entry in eligible:
		roll -= entry.weight
		if roll <= 0.0:
			return entry.enemy
	return null if eligible.is_empty() else eligible[-1].enemy


static func _spawn_position(sim: Simulation) -> Vector2:
	var half := GameConfig.ARENA_HALF - Vector2(50.0, 50.0)
	for _attempt in 8:
		var pos := Vector2(sim.rng.randf_range(-half.x, half.x), sim.rng.randf_range(-half.y, half.y))
		var nearest := sim.nearest_living_player(pos)
		if nearest == null or nearest.pos.distance_to(pos) > 280.0:
			return pos
	return Vector2(half.x, half.y)
