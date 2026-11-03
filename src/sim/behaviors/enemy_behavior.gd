class_name EnemyBehavior
extends Resource
## Strategy: how an enemy moves and attacks. Implementations must only change
## `enemy` and call Simulation helpers, so they stay network-safe on the host.


func tick(_sim: Simulation, _enemy: EnemyState, _def: EnemyDef, _dt: float) -> void:
	pass


static func steer(enemy: EnemyState, wish: Vector2, dt: float, response: float = 8.0) -> void:
	enemy.vel = enemy.vel.lerp(wish, clampf(response * dt, 0.0, 1.0))
