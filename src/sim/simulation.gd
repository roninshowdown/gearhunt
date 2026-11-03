class_name Simulation
extends RefCounted
## Authoritative game rules. Runs only on the host (or offline), has no scene
## tree or rendering dependencies, and can be stepped headless in tests.

var world := WorldState.new()
var rng := RandomNumberGenerator.new()
var biome: BiomeDef
var grid := SpatialHash.new()
var spawn_budget := 0.0

var _next_id := 1


func _init(config: MatchConfig) -> void:
	rng.seed = config.seed_value
	biome = Content.biome(config.biome_id)
	world.biome_id = config.biome_id
	var count := config.loadouts.size()
	for i in count:
		_add_player(config.loadouts[i], i, count)
	WaveSystem.begin_wave(self)


func _add_player(loadout: Dictionary, index: int, total: int) -> void:
	var p := PlayerState.new()
	p.id = int(loadout["player_id"])
	p.peer_id = int(loadout["peer_id"])
	p.character_id = String(loadout["character_id"])
	p.meta_stats = loadout.get("meta_stats", {})
	p.pos = Vector2.from_angle(TAU * index / maxi(total, 1)) * (0.0 if total == 1 else 110.0)
	var character := Content.character(p.character_id)
	p.weapons.append(WeaponInstance.new(character.starting_weapon.id))
	StatSystem.recompute(p)
	p.hp = p.max_hp()
	world.players.append(p)


func next_id() -> int:
	_next_id += 1
	return _next_id


func emit_event(type: GameEvent.Type, pos: Vector2, target: int = 0, a: float = 0.0, b: float = 0.0, c: float = 0.0) -> void:
	world.events.append(GameEvent.make(type, pos, target, a, b, c))


func mark_economy_dirty() -> void:
	world.economy_version += 1


## Advances the world by one fixed tick. `intents` maps player id to PlayerIntent.
func step(dt: float, intents: Dictionary) -> void:
	world.tick += 1
	match world.phase:
		WorldState.Phase.WAVE:
			grid.rebuild(world.enemies)
			PlayerSystem.step(self, dt, intents)
			WeaponSystem.step(self, dt)
			WaveSystem.step(self, dt)
			EnemySystem.step(self, dt)
			ProjectileSystem.step(self, dt)
			PickupSystem.step(self, dt)
			_check_defeat()
		WorldState.Phase.SHOP:
			if ShopSystem.everyone_ready(self):
				WaveSystem.advance(self)


## Discrete, reliable player action. Everything is validated here because the
## command may come from a remote client.
func apply_command(player_id: int, command: Dictionary) -> void:
	var p := world.player(player_id)
	if p == null:
		return
	if world.phase == WorldState.Phase.SHOP:
		ShopSystem.apply(self, p, command)


func disconnect_peer(peer_id: int) -> void:
	for p in world.players:
		if p.peer_id == peer_id:
			p.connected = false
			p.alive = false
			p.ready = true
	mark_economy_dirty()


func living_players() -> Array[PlayerState]:
	var result: Array[PlayerState] = []
	for p in world.players:
		if p.alive:
			result.append(p)
	return result


func nearest_living_player(pos: Vector2) -> PlayerState:
	var best: PlayerState = null
	var best_distance := INF
	for p in world.players:
		if not p.alive:
			continue
		var d := p.pos.distance_squared_to(pos)
		if d < best_distance:
			best_distance = d
			best = p
	return best


func enemies_near(pos: Vector2, radius: float) -> Array[EnemyState]:
	return grid.query(pos, radius)


func spawn_enemy(def: EnemyDef, pos: Vector2) -> EnemyState:
	var e := EnemyState.new()
	var scale := WaveSystem.difficulty(self)
	e.id = next_id()
	e.def_index = Content.enemy_index(def.id)
	e.pos = WaveSystem.clamp_to_arena(pos, def.radius)
	e.radius = def.radius
	e.max_hp = def.max_hp * scale.hp
	e.hp = e.max_hp
	e.damage_scale = scale.damage
	e.spawn_left = GameConfig.SPAWN_TELEGRAPH
	world.enemies.append(e)
	return e


func spawn_enemy_projectile(pos: Vector2, velocity: Vector2, damage: float) -> void:
	var p := ProjectileState.new()
	p.id = next_id()
	p.team = ProjectileState.Team.ENEMIES
	p.pos = pos
	p.vel = velocity
	p.damage = damage
	p.radius = 14.0
	p.life = 6.0
	p.visual = ProjectileState.Visual.ENEMY_ORB
	world.projectiles.append(p)


func spawn_material(pos: Vector2, value: int) -> void:
	var p := PickupState.new()
	p.id = next_id()
	p.pos = pos + Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(0.0, 24.0)
	p.value = value
	world.pickups.append(p)


func _check_defeat() -> void:
	if living_players().is_empty():
		world.phase = WorldState.Phase.DEFEAT
		mark_economy_dirty()
