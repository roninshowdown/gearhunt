class_name ChargeBehavior
extends EnemyBehavior

enum State { APPROACH, WINDUP, DASH }

@export var trigger_range: float = 460.0
@export var windup: float = 0.65
@export var dash_time: float = 0.5
@export var dash_speed: float = 820.0
@export var rest: float = 1.0


func tick(sim: Simulation, enemy: EnemyState, def: EnemyDef, dt: float) -> void:
	var target := sim.nearest_living_player(enemy.pos)
	enemy.timer -= dt
	match enemy.state:
		State.APPROACH:
			if target == null:
				steer(enemy, Vector2.ZERO, dt)
				return
			steer(enemy, enemy.pos.direction_to(target.pos) * def.speed, dt)
			if enemy.timer <= 0.0 and enemy.pos.distance_to(target.pos) < trigger_range:
				enemy.state = State.WINDUP
				enemy.timer = windup
				enemy.aim = enemy.pos.direction_to(target.pos)
				sim.emit_event(GameEvent.Type.TELEGRAPH, enemy.pos, enemy.id, enemy.aim.angle())
		State.WINDUP:
			steer(enemy, Vector2.ZERO, dt, 14.0)
			if enemy.timer <= 0.0:
				enemy.state = State.DASH
				enemy.timer = dash_time
		State.DASH:
			enemy.vel = enemy.aim * dash_speed
			if enemy.timer <= 0.0:
				enemy.state = State.APPROACH
				enemy.timer = rest
