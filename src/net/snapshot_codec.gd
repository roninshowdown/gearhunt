class_name SnapshotCodec
extends RefCounted
## Binary encoding of WorldState.
##   snapshot: fast-changing state, sent 30x/s over an unreliable channel.
##   economy:  slowly changing state, sent reliably when it changes.
## Clients rebuild their entity arrays from every snapshot.

const POSITION_SCALE := 8.0
const VELOCITY_SCALE := 1.0
const ANGLE_SCALE := 10000.0


static func encode_snapshot(world: WorldState, events: Array[GameEvent]) -> PackedByteArray:
	var b := StreamPeerBuffer.new()
	b.put_u32(world.tick)
	b.put_u8(world.phase)
	b.put_u8(world.wave)
	b.put_float(world.time_left)

	b.put_u8(world.players.size())
	for p in world.players:
		b.put_u16(p.id)
		_put_pos(b, p.pos)
		_put_vec(b, p.vel)
		b.put_16(int(p.aim.angle() * ANGLE_SCALE))
		b.put_float(p.hp)
		b.put_u8(int(p.alive) | int(p.attacking) << 1 | int(p.invulnerable > 0.0) << 2)

	b.put_u16(world.enemies.size())
	for e in world.enemies:
		b.put_u32(e.id)
		b.put_u8(e.def_index)
		_put_pos(b, e.pos)
		_put_vec(b, e.vel)
		b.put_u8(clampi(int(e.spawn_left / GameConfig.SPAWN_TELEGRAPH * 255.0), 0, 255))
		b.put_u8(clampi(int(e.hp / maxf(e.max_hp, 0.01) * 255.0), 0, 255))

	b.put_u16(world.projectiles.size())
	for p in world.projectiles:
		b.put_u32(p.id)
		_put_pos(b, p.pos)
		_put_vec(b, p.vel)
		b.put_u8(p.team | p.visual << 2)
		b.put_u8(int(p.radius))

	b.put_u16(world.pickups.size())
	for p in world.pickups:
		b.put_u32(p.id)
		_put_pos(b, p.pos)

	b.put_u16(events.size())
	for e in events:
		b.put_u8(e.type)
		_put_pos(b, e.pos)
		b.put_u32(e.target)
		b.put_float(e.a)
		b.put_float(e.b)
		b.put_float(e.c)
	return b.data_array


## Returns decoded events; ignores data older than what is already applied.
static func apply_snapshot(world: WorldState, bytes: PackedByteArray) -> Array[GameEvent]:
	var events: Array[GameEvent] = []
	var b := StreamPeerBuffer.new()
	b.data_array = bytes
	var tick := b.get_u32()
	if tick < world.tick:
		return events
	world.tick = tick
	world.phase = b.get_u8() as WorldState.Phase
	world.wave = b.get_u8()
	world.time_left = b.get_float()

	for _i in b.get_u8():
		var player_id := b.get_u16()
		var pos := _get_pos(b)
		var vel := _get_vec(b)
		var angle := b.get_16() / ANGLE_SCALE
		var hp := b.get_float()
		var flags := b.get_u8()
		var p := world.player(player_id)
		if p != null:
			p.pos = pos
			p.vel = vel
			p.aim = Vector2.from_angle(angle)
			p.hp = hp
			p.alive = flags & 1 != 0
			p.attacking = flags & 2 != 0
			p.invulnerable = 1.0 if flags & 4 != 0 else 0.0

	world.enemies.clear()
	for _i in b.get_u16():
		var e := EnemyState.new()
		e.id = b.get_u32()
		e.def_index = b.get_u8()
		e.pos = _get_pos(b)
		e.vel = _get_vec(b)
		e.spawn_left = b.get_u8() / 255.0 * GameConfig.SPAWN_TELEGRAPH
		e.max_hp = 1.0
		e.hp = b.get_u8() / 255.0
		e.radius = Content.enemy_by_index(e.def_index).radius
		world.enemies.append(e)

	world.projectiles.clear()
	for _i in b.get_u16():
		var p := ProjectileState.new()
		p.id = b.get_u32()
		p.pos = _get_pos(b)
		p.vel = _get_vec(b)
		var packed := b.get_u8()
		p.team = (packed & 3) as ProjectileState.Team
		p.visual = (packed >> 2) as ProjectileState.Visual
		p.radius = b.get_u8()
		world.projectiles.append(p)

	world.pickups.clear()
	for _i in b.get_u16():
		var p := PickupState.new()
		p.id = b.get_u32()
		p.pos = _get_pos(b)
		world.pickups.append(p)

	for _i in b.get_u16():
		var type := b.get_u8() as GameEvent.Type
		var pos := _get_pos(b)
		var target := b.get_u32()
		var a := b.get_float()
		var bb := b.get_float()
		var c := b.get_float()
		events.append(GameEvent.make(type, pos, target, a, bb, c))
	return events


static func encode_economy(world: WorldState) -> Dictionary:
	var players := []
	for p in world.players:
		var weapons := []
		for w in p.weapons:
			weapons.append(w.weapon_id)
		players.append({
			"id": p.id, "materials": p.materials, "kills": p.kills, "weapons": weapons,
			"items": p.items, "stats": p.stats, "offers": p.offers, "rerolls": p.rerolls,
			"ready": p.ready, "connected": p.connected,
		})
	return {"version": world.economy_version, "phase": world.phase, "wave": world.wave, "players": players}


static func apply_economy(world: WorldState, data: Dictionary) -> void:
	world.economy_version = int(data["version"])
	world.phase = int(data["phase"]) as WorldState.Phase
	world.wave = int(data["wave"])
	for entry: Dictionary in data["players"]:
		var p := world.player(int(entry["id"]))
		if p == null:
			continue
		p.materials = int(entry["materials"])
		p.kills = int(entry["kills"])
		p.weapons.clear()
		for weapon_id: String in entry["weapons"]:
			p.weapons.append(WeaponInstance.new(weapon_id))
		p.items.assign(entry["items"])
		p.stats = entry["stats"]
		p.offers.assign(entry["offers"])
		p.rerolls = int(entry["rerolls"])
		p.ready = bool(entry["ready"])
		p.connected = bool(entry["connected"])


static func _put_pos(b: StreamPeerBuffer, v: Vector2) -> void:
	b.put_16(clampi(int(v.x * POSITION_SCALE), -32768, 32767))
	b.put_16(clampi(int(v.y * POSITION_SCALE), -32768, 32767))


static func _get_pos(b: StreamPeerBuffer) -> Vector2:
	var x := b.get_16() / POSITION_SCALE
	var y := b.get_16() / POSITION_SCALE
	return Vector2(x, y)


static func _put_vec(b: StreamPeerBuffer, v: Vector2) -> void:
	b.put_16(clampi(int(v.x * VELOCITY_SCALE), -32768, 32767))
	b.put_16(clampi(int(v.y * VELOCITY_SCALE), -32768, 32767))


static func _get_vec(b: StreamPeerBuffer) -> Vector2:
	var x := b.get_16() / VELOCITY_SCALE
	var y := b.get_16() / VELOCITY_SCALE
	return Vector2(x, y)
