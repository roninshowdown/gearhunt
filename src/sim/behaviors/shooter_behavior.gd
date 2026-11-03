class_name ShooterBehavior
extends EnemyBehavior

@export var preferred_range: float = 480.0
@export var fire_interval: float = 2.2
@export var projectile_speed: float = 340.0
@export var projectile_damage: float = 3.0
@export var count: int = 1
@export_range(0.0, 360.0) var spread_degrees: float = 0.0
@export var also_summons: EnemyDef ## Optional: spawned next to the shooter on each volley.


func tick(sim: Simulation, enemy: EnemyState, def: EnemyDef, dt: float) -> void:
	var target := sim.nearest_living_player(enemy.pos)
	if target == null:
		steer(enemy, Vector2.ZERO, dt)
		return
	var distance := enemy.pos.distance_to(target.pos)
	var dir := enemy.pos.direction_to(target.pos)
	var wish := Vector2.ZERO
	if distance > preferred_range * 1.1:
		wish = dir
	elif distance < preferred_range * 0.8:
		wish = -dir
	steer(enemy, wish * def.speed, dt, 5.0)

	enemy.timer -= dt
	if enemy.timer > 0.0:
		return
	enemy.timer = fire_interval * sim.rng.randf_range(0.9, 1.1)
	for i in count:
		var t := 0.0 if count == 1 else float(i) / count - 0.5
		sim.spawn_enemy_projectile(enemy.pos, dir.rotated(deg_to_rad(spread_degrees) * t) * projectile_speed, projectile_damage * enemy.damage_scale)
	if also_summons != null:
		sim.spawn_enemy(also_summons, enemy.pos + Vector2.from_angle(sim.rng.randf() * TAU) * 90.0)
