class_name ProjectileSystem
extends RefCounted


static func step(sim: Simulation, dt: float) -> void:
	var projectiles := sim.world.projectiles
	var write := 0
	for read in projectiles.size():
		var p := projectiles[read]
		p.pos += p.vel * dt
		p.life -= dt
		var finished := p.life <= 0.0 or _outside_arena(p.pos)
		if not finished:
			finished = _hit_players(sim, p) if p.team == ProjectileState.Team.ENEMIES else _hit_enemies(sim, p)
		if finished:
			if p.explosion_radius > 0.0:
				CombatSystem.explode(sim, p.pos, p.explosion_radius, p.damage * 0.6, p.owner_id)
			continue
		projectiles[write] = p
		write += 1
	projectiles.resize(write)


static func _outside_arena(pos: Vector2) -> bool:
	return absf(pos.x) > GameConfig.ARENA_HALF.x + 30.0 or absf(pos.y) > GameConfig.ARENA_HALF.y + 30.0


static func _hit_players(sim: Simulation, projectile: ProjectileState) -> bool:
	for p in sim.world.players:
		if p.alive and p.pos.distance_to(projectile.pos) < projectile.radius + PlayerSystem.BODY_RADIUS * 0.7:
			CombatSystem.damage_player(sim, p, projectile.damage)
			return true
	return false


static func _hit_enemies(sim: Simulation, projectile: ProjectileState) -> bool:
	for enemy in sim.enemies_near(projectile.pos, projectile.radius + 96.0):
		if not enemy.is_active() or enemy.hp <= 0.0 or projectile.already_hit.has(enemy.id):
			continue
		if enemy.pos.distance_to(projectile.pos) > enemy.radius + projectile.radius:
			continue
		projectile.already_hit[enemy.id] = true
		var knock := projectile.vel.normalized() * projectile.knockback
		CombatSystem.damage_enemy(sim, enemy, projectile.damage, knock, projectile.owner_id)
		if projectile.pierce <= 0:
			return true
		projectile.pierce -= 1
	return false
