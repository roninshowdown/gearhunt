class_name AttackPattern
extends Resource
## Strategy: what a weapon does when it fires. Add a new subclass for a new
## kind of weapon; nothing else in the simulation has to change.


func execute(_sim: Simulation, _player: PlayerState, _weapon: WeaponDef, _origin: Vector2, _direction: Vector2, _damage: float) -> void:
	push_error("AttackPattern.execute not implemented")
