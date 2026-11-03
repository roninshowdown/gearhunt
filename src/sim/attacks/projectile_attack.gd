class_name ProjectileAttack
extends AttackPattern

@export var speed: float = 900.0
@export var range_px: float = 700.0
@export var radius: float = 10.0
@export var count: int = 1
@export_range(0.0, 90.0) var spread_degrees: float = 0.0
@export var pierce: int = 0
@export var explosion_radius: float = 0.0
@export var knockback: float = 80.0
@export var visual: ProjectileState.Visual = ProjectileState.Visual.ARROW


func execute(sim: Simulation, player: PlayerState, _weapon: WeaponDef, origin: Vector2, direction: Vector2, damage: float) -> void:
	for i in count:
		var t := 0.0 if count == 1 else float(i) / (count - 1) - 0.5
		var dir := direction.rotated(deg_to_rad(spread_degrees) * t)
		var p := ProjectileState.new()
		p.id = sim.next_id()
		p.team = ProjectileState.Team.PLAYERS
		p.owner_id = player.id
		p.pos = origin
		p.vel = dir * speed
		p.damage = damage
		p.radius = radius
		p.life = range_px / speed
		p.pierce = pierce
		p.explosion_radius = explosion_radius
		p.knockback = knockback
		p.visual = visual
		sim.world.projectiles.append(p)
	sim.emit_event(GameEvent.Type.SHOT, origin, player.id, 0.0)
