class_name MeleeArcAttack
extends AttackPattern

@export var reach: float = 170.0
@export_range(10.0, 360.0) var arc_degrees: float = 110.0
@export var knockback: float = 260.0


func execute(sim: Simulation, player: PlayerState, _weapon: WeaponDef, origin: Vector2, direction: Vector2, damage: float) -> void:
	var half_arc := deg_to_rad(arc_degrees) * 0.5
	var angle := direction.angle()
	for enemy: EnemyState in sim.enemies_near(origin, reach + 48.0):
		if not enemy.is_active():
			continue
		var offset := enemy.pos - origin
		var limit := reach + enemy.radius
		if offset.length_squared() > limit * limit:
			continue
		if absf(angle_difference(angle, offset.angle())) > half_arc:
			continue
		CombatSystem.damage_enemy(sim, enemy, damage, direction * knockback, player.id)
	sim.emit_event(GameEvent.Type.MELEE, origin, player.id, angle, reach, arc_degrees)
