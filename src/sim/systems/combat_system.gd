class_name CombatSystem
extends RefCounted
## All damage flows through here so future effects (crits, thorns, shields)
## have exactly one place to hook into.

const ARMOR_CONSTANT := 15.0


static func damage_enemy(sim: Simulation, enemy: EnemyState, amount: float, knockback: Vector2, source_player_id: int) -> void:
	if enemy.hp <= 0.0 or not enemy.is_active():
		return
	enemy.hp -= amount
	var def := Content.enemy_by_index(enemy.def_index)
	if not def.is_boss:
		enemy.knockback += knockback
	sim.emit_event(GameEvent.Type.HIT, enemy.pos, enemy.id, amount)
	if enemy.hp <= 0.0:
		_on_enemy_killed(sim, enemy, def, source_player_id)


static func damage_player(sim: Simulation, p: PlayerState, amount: float) -> void:
	if not p.alive or p.invulnerable > 0.0:
		return
	var armor := p.stat(Stats.ARMOR)
	var taken := maxf(1.0, amount * (ARMOR_CONSTANT / (ARMOR_CONSTANT + maxf(armor, 0.0))))
	p.hp -= taken
	p.invulnerable = GameConfig.INVULN_AFTER_HIT
	sim.emit_event(GameEvent.Type.PLAYER_HURT, p.pos, p.id, taken)
	if p.hp <= 0.0:
		p.hp = 0.0
		p.alive = false
		p.attacking = false
		sim.emit_event(GameEvent.Type.PLAYER_DOWN, p.pos, p.id)
		sim.mark_economy_dirty()


static func explode(sim: Simulation, pos: Vector2, radius: float, damage: float, source_player_id: int) -> void:
	sim.emit_event(GameEvent.Type.EXPLOSION, pos, 0, radius)
	for enemy in sim.enemies_near(pos, radius + 48.0):
		if enemy.is_active() and enemy.pos.distance_to(pos) <= radius + enemy.radius:
			CombatSystem.damage_enemy(sim, enemy, damage, pos.direction_to(enemy.pos) * 180.0, source_player_id)


static func _on_enemy_killed(sim: Simulation, enemy: EnemyState, def: EnemyDef, source_player_id: int) -> void:
	sim.emit_event(GameEvent.Type.DEATH, enemy.pos, enemy.id, enemy.def_index, enemy.radius)
	for i in def.material_drop:
		sim.spawn_material(enemy.pos, 1)
	var killer := sim.world.player(source_player_id)
	if killer != null:
		killer.kills += 1
