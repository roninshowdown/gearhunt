class_name ChaseBehavior
extends EnemyBehavior


func tick(sim: Simulation, enemy: EnemyState, def: EnemyDef, dt: float) -> void:
	var target := sim.nearest_living_player(enemy.pos)
	if target == null:
		steer(enemy, Vector2.ZERO, dt)
		return
	steer(enemy, enemy.pos.direction_to(target.pos) * def.speed, dt)
