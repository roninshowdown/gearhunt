class_name PlayerSystem
extends RefCounted

const ACCELERATION := 14.0
const BODY_RADIUS := 30.0


static func step(sim: Simulation, dt: float, intents: Dictionary) -> void:
	for p in sim.world.players:
		if not p.alive:
			continue
		var intent: PlayerIntent = intents.get(p.id)
		var wish := Vector2.ZERO
		if intent != null:
			var clean := intent.sanitized()
			wish = clean.move * p.stat(Stats.MOVE_SPEED)
			p.aim = clean.aim
			p.attacking = clean.attacking
		else:
			p.attacking = false
		p.vel = p.vel.lerp(wish, clampf(ACCELERATION * dt, 0.0, 1.0))
		p.pos = WaveSystem.clamp_to_arena(p.pos + p.vel * dt, BODY_RADIUS)
		p.invulnerable = maxf(0.0, p.invulnerable - dt)
		_regenerate(p, dt)


static func _regenerate(p: PlayerState, dt: float) -> void:
	var regen := p.stat(Stats.HP_REGEN)
	if regen <= 0.0 or p.hp >= p.max_hp():
		return
	p.regen_buffer += regen * 0.2 * dt
	if p.regen_buffer >= 1.0:
		p.hp = minf(p.hp + 1.0, p.max_hp())
		p.regen_buffer -= 1.0
