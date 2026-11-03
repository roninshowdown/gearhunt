class_name WeaponSystem
extends RefCounted


static func step(sim: Simulation, dt: float) -> void:
	for p in sim.world.players:
		if not p.alive:
			continue
		var speed_multiplier := maxf(0.2, 1.0 + p.stat(Stats.ATTACK_SPEED_PCT) / 100.0)
		for i in p.weapons.size():
			var instance := p.weapons[i]
			instance.cooldown -= dt * speed_multiplier
			if not p.attacking or instance.cooldown > 0.0:
				continue
			var weapon := Content.weapon(instance.weapon_id)
			instance.cooldown = weapon.cooldown
			var damage := maxf(1.0, weapon.damage * (1.0 + p.stat(Stats.DAMAGE_PCT) / 100.0))
			weapon.attack.execute(sim, p, weapon, p.weapon_mount(i), p.aim, damage)
