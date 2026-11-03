class_name EnemySystem
extends RefCounted

const SEPARATION_STRENGTH := 420.0
const KNOCKBACK_DECAY := 9.0


static func step(sim: Simulation, dt: float) -> void:
	var enemies := sim.world.enemies
	for e in enemies:
		if e.spawn_left > 0.0:
			e.spawn_left -= dt
			continue
		if e.hp <= 0.0:
			continue
		var def := Content.enemy_by_index(e.def_index)
		def.behavior.tick(sim, e, def, dt)
		var separation := _separation(sim, e)
		e.pos = WaveSystem.clamp_to_arena(e.pos + (e.vel + separation + e.knockback) * dt, e.radius)
		e.knockback = e.knockback.lerp(Vector2.ZERO, clampf(KNOCKBACK_DECAY * dt, 0.0, 1.0))
		_touch_players(sim, e, def)
	_remove_dead(sim)


static func _separation(sim: Simulation, e: EnemyState) -> Vector2:
	var push := Vector2.ZERO
	var checked := 0
	for other in sim.enemies_near(e.pos, e.radius + 40.0):
		if other == e or not other.is_active():
			continue
		var offset := e.pos - other.pos
		var limit := e.radius + other.radius
		var distance_squared := offset.length_squared()
		if distance_squared >= limit * limit or distance_squared < 0.01:
			continue
		var distance := sqrt(distance_squared)
		push += offset / distance * (1.0 - distance / limit)
		checked += 1
		if checked >= 6:
			break
	return push * SEPARATION_STRENGTH


static func _touch_players(sim: Simulation, e: EnemyState, def: EnemyDef) -> void:
	for p in sim.world.players:
		if not p.alive:
			continue
		var limit := e.radius + PlayerSystem.BODY_RADIUS * 0.75
		if e.pos.distance_squared_to(p.pos) < limit * limit:
			CombatSystem.damage_player(sim, p, def.contact_damage * e.damage_scale)


static func _remove_dead(sim: Simulation) -> void:
	var enemies := sim.world.enemies
	var write := 0
	for read in enemies.size():
		if enemies[read].hp > 0.0:
			enemies[write] = enemies[read]
			write += 1
	enemies.resize(write)
