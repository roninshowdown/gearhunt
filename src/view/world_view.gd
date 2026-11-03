class_name WorldView
extends Node2D
## Reads WorldState and draws it. Holds no game rules; anything in here may be
## replaced freely without affecting gameplay or multiplayer.

const BACKDROP_ORIGIN := Vector2(-4000, -3000)
const BACKDROP_SIZE := Vector2(8000, 6000)
const SPLAT_CAPACITY := 400
const AMBIENT_COUNT := 90
const GLOW := preload("res://assets/shaders/glow.gdshader")
const PROJECTILE := preload("res://assets/shaders/projectile.gdshader")
const SPLAT := preload("res://assets/shaders/splat.gdshader")
const POSTFX := preload("res://assets/shaders/postfx.gdshader")
const MATERIAL_COLOR := Color(0.55, 1.0, 0.55)
const ENEMY_SHOT_COLOR := Color(1.0, 0.3, 0.42)
const MAGIC_COLOR := Color(1.0, 0.55, 0.2)
const ARROW_COLOR := Color(0.8, 1.0, 0.7)


class SmoothEntity:
	var pos: Vector2
	var facing := 0.0
	var flash := 0.0
	var phase: float
	var stamp := 0


var camera := Camera2D.new()
var vfx := VfxLayer.new()
var world: WorldState

var _biome: BiomeDef
var _enemy_batches: Array[EntityBatch] = []
var _splats: EntityBatch
var _pickups: EntityBatch
var _projectiles: EntityBatch
var _enemy_orbs: EntityBatch
var _ambient: EntityBatch
var _heroes: Dictionary = {}
var _hero_swings: Dictionary = {}
var _enemies: Dictionary = {}
var _projectile_pos: Dictionary = {}
var _pickup_pos: Dictionary = {}
var _splat_list: Array[Dictionary] = []
var _splat_next := 0
var _splats_dirty := false
var _ambient_seeds := PackedVector3Array()
var _frame := 0
var _shake := 0.0
var _post_material: ShaderMaterial
var _damage_flash := 0.0


func setup(p_world: WorldState, font: Font) -> void:
	world = p_world
	_biome = Content.biome(world.biome_id)
	vfx.font = font
	_build_backdrop()
	_splats = _new_batch(SPLAT_CAPACITY, _shader_material(SPLAT), true)
	_pickups = _new_batch(600, _shader_material(GLOW), false)
	for i in Content.enemy_count():
		var def := Content.enemy_by_index(i)
		_enemy_batches.append(_new_batch(GameConfig.MAX_ENEMIES + 2, CreatureMaterial.create(def.look), true))
	_build_heroes()
	_projectiles = _new_batch(600, _shader_material(PROJECTILE), false)
	_enemy_orbs = _new_batch(400, _shader_material(GLOW), false)
	add_child(vfx)
	_ambient = _new_batch(AMBIENT_COUNT, _shader_material(GLOW), false)
	_build_ambient()
	camera.position_smoothing_enabled = false
	add_child(camera)
	camera.make_current()
	_build_postfx()


func _process(delta: float) -> void:
	if world == null:
		return
	_frame += 1
	_sync_enemies(delta)
	_sync_heroes(delta)
	_sync_projectiles(delta)
	_sync_pickups(delta)
	_sync_ambient()
	if _splats_dirty:
		_rebuild_splats()
	_update_camera(delta)
	_damage_flash = maxf(0.0, _damage_flash - delta * 3.0)
	_post_material.set_shader_parameter("damage_flash", _damage_flash)


func handle_events(events: Array[GameEvent]) -> void:
	for e in events:
		match e.type:
			GameEvent.Type.HIT:
				_on_hit(e)
			GameEvent.Type.DEATH:
				_on_death(e)
			GameEvent.Type.SHOT:
				Sfx.play(Sfx.Sound.SHOT, -16.0)
				vfx.burst(e.pos, ARROW_COLOR, 3, 200.0, 16.0, 0.2)
			GameEvent.Type.MELEE:
				_on_melee(e)
			GameEvent.Type.PICKUP:
				Sfx.play(Sfx.Sound.PICKUP, -20.0)
				vfx.burst(e.pos, MATERIAL_COLOR, 2, 120.0, 14.0, 0.25)
			GameEvent.Type.PLAYER_HURT:
				_on_player_hurt(e)
			GameEvent.Type.PLAYER_DOWN:
				vfx.burst(e.pos, Color(1, 0.3, 0.3), 40, 500.0, 34.0, 0.9)
				_shake = maxf(_shake, 24.0)
			GameEvent.Type.EXPLOSION:
				Sfx.play(Sfx.Sound.EXPLOSION, -10.0)
				vfx.ring(e.pos, e.a, MAGIC_COLOR)
				vfx.burst(e.pos, MAGIC_COLOR, 26, e.a * 3.0, 34.0, 0.45)
				_shake = maxf(_shake, 7.0)
			GameEvent.Type.TELEGRAPH:
				vfx.ring(e.pos, 90.0, Color(1, 0.35, 0.3))


func _on_hit(e: GameEvent) -> void:
	var entity: SmoothEntity = _enemies.get(e.target)
	if entity != null:
		entity.flash = 1.0
	Sfx.play(Sfx.Sound.HIT, -18.0)
	vfx.number(e.pos, roundi(e.a), Color(1.0, 0.95, 0.75))
	vfx.burst(e.pos, _biome.splat_tint, 5, 240.0, 18.0, 0.3)


func _on_death(e: GameEvent) -> void:
	var def := Content.enemy_by_index(int(e.a))
	Sfx.play(Sfx.Sound.DEATH, -13.0)
	vfx.burst(e.pos, def.look.accent_color, 16, 430.0, 30.0, 0.55)
	vfx.burst(e.pos, def.look.body_color, 12, 260.0, 42.0, 0.7)
	_add_splat(e.pos, e.b * 3.2, def.look.body_color.darkened(0.42))
	if def.is_boss:
		_shake = 30.0


func _on_melee(e: GameEvent) -> void:
	_hero_swings[e.target] = 1.0
	Sfx.play(Sfx.Sound.SWING, -15.0)
	var color := Color(0.95, 0.97, 1.0)
	vfx.slash(e.pos, e.a, e.b, e.c, color)


func _on_player_hurt(e: GameEvent) -> void:
	Sfx.play(Sfx.Sound.HURT, -6.0)
	vfx.number(e.pos, roundi(e.a), Color(1.0, 0.3, 0.3))
	vfx.burst(e.pos, Color(1, 0.25, 0.25), 12, 320.0, 24.0, 0.4)
	_shake = maxf(_shake, 12.0)
	if _is_local_player(e.target):
		_damage_flash = 0.6
	var hero: HeroVisual = _heroes.get(e.target)
	if hero != null:
		hero.flash = 1.0


func _is_local_player(player_id: int) -> bool:
	for slot in Session.slots:
		if slot.player_id == player_id:
			return true
	return false


func _sync_enemies(delta: float) -> void:
	for batch in _enemy_batches:
		batch.begin()
	var follow := 1.0 - exp(-delta * 28.0)
	for e in world.enemies:
		var entity: SmoothEntity = _enemies.get(e.id)
		if entity == null:
			entity = SmoothEntity.new()
			entity.pos = e.pos
			entity.phase = randf()
			_enemies[e.id] = entity
		entity.stamp = _frame
		entity.pos = entity.pos.lerp(e.pos, follow)
		entity.flash = maxf(0.0, entity.flash - delta * 7.0)
		var speed := e.vel.length()
		if speed > 8.0:
			entity.facing = lerp_angle(entity.facing, e.vel.angle(), 1.0 - exp(-delta * 10.0))
		var def := Content.enemy_by_index(e.def_index)
		var stretch := clampf(speed / 900.0, 0.0, 0.3)
		var breath := sin(Time.get_ticks_msec() * 0.005 + entity.phase * TAU) * 0.035
		var size := e.radius * 2.0 / 0.62
		var scale_vector := Vector2(size * (1.0 + stretch + breath), size * (1.0 - stretch * 0.7 - breath))
		var spawning := clampf(e.spawn_left / GameConfig.SPAWN_TELEGRAPH, 0.0, 1.0)
		_enemy_batches[e.def_index].add(
			Transform2D(entity.facing, scale_vector, 0.0, entity.pos),
			Color.WHITE,
			Color(entity.phase, entity.flash, spawning, 0.0))
	for batch in _enemy_batches:
		batch.finish()
	_forget_stale(_enemies)


func _forget_stale(table: Dictionary) -> void:
	if _frame % 30 != 0:
		return
	for id: int in table.keys():
		if table[id].stamp != _frame:
			table.erase(id)


func _sync_heroes(delta: float) -> void:
	var follow := 1.0 - exp(-delta * 34.0)
	for p in world.players:
		var hero: HeroVisual = _heroes[p.id]
		hero.position = hero.position.lerp(p.pos, follow)
		hero.aim_angle = lerp_angle(hero.aim_angle, p.aim.angle(), 1.0 - exp(-delta * 24.0))
		hero.flash = maxf(0.0, hero.flash - delta * 6.0)
		hero.down = not p.alive
		var swing: float = _hero_swings.get(p.id, 0.0)
		swing = maxf(0.0, swing - delta * 5.5)
		_hero_swings[p.id] = swing
		hero.swing = 1.0 - swing if swing > 0.0 else 0.0
		hero.weapon_visuals.clear()
		var mounts := PackedVector2Array()
		for i in p.weapons.size():
			hero.weapon_visuals.append(Content.weapon(p.weapons[i].weapon_id))
			mounts.append(p.weapon_mount(i) - p.pos)
		hero.mounts = mounts


func _sync_projectiles(delta: float) -> void:
	_projectiles.begin()
	_enemy_orbs.begin()
	var follow := 1.0 - exp(-delta * 40.0)
	for p in world.projectiles:
		var entity: SmoothEntity = _projectile_pos.get(p.id)
		if entity == null:
			entity = SmoothEntity.new()
			entity.pos = p.pos
			_projectile_pos[p.id] = entity
		entity.stamp = _frame
		entity.pos = entity.pos.lerp(p.pos, follow)
		if p.team == ProjectileState.Team.ENEMIES:
			# Big round orbs: enemy fire must never be mistaken for your own shots.
			var orb := p.radius * 5.5
			_enemy_orbs.add(Transform2D(0.0, Vector2(orb, orb), 0.0, entity.pos), ENEMY_SHOT_COLOR)
			continue
		var length := clampf(p.vel.length() * 0.09, 40.0, 130.0) + p.radius * 2.0
		var width := p.radius * 3.4
		var color := _projectile_color(p)
		_projectiles.add(Transform2D(p.vel.angle(), Vector2(length, width), 0.0, entity.pos - p.vel.normalized() * length * 0.3), color)
	_projectiles.finish()
	_enemy_orbs.finish()
	_forget_stale(_projectile_pos)


func _projectile_color(p: ProjectileState) -> Color:
	match p.visual:
		ProjectileState.Visual.MAGIC:
			return MAGIC_COLOR
		ProjectileState.Visual.ENEMY_ORB:
			return ENEMY_SHOT_COLOR
	return ARROW_COLOR


func _sync_pickups(delta: float) -> void:
	_pickups.begin()
	var follow := 1.0 - exp(-delta * 30.0)
	var time := Time.get_ticks_msec() * 0.004
	for p in world.pickups:
		var entity: SmoothEntity = _pickup_pos.get(p.id)
		if entity == null:
			entity = SmoothEntity.new()
			entity.pos = p.pos
			entity.phase = randf() * TAU
			_pickup_pos[p.id] = entity
		entity.stamp = _frame
		entity.pos = entity.pos.lerp(p.pos, follow)
		var size := 42.0 + sin(time + entity.phase) * 7.0
		_pickups.add(Transform2D(0.0, Vector2(size, size), 0.0, entity.pos), MATERIAL_COLOR)
	_pickups.finish()
	_forget_stale(_pickup_pos)


func _add_splat(pos: Vector2, size: float, color: Color) -> void:
	var entry := {"pos": pos, "size": size, "color": color, "seed": randf(), "angle": randf() * TAU}
	if _splat_list.size() < SPLAT_CAPACITY:
		_splat_list.append(entry)
	else:
		_splat_list[_splat_next] = entry
		_splat_next = (_splat_next + 1) % SPLAT_CAPACITY
	_splats_dirty = true


func _rebuild_splats() -> void:
	_splats_dirty = false
	_splats.begin()
	for s in _splat_list:
		var color: Color = s["color"]
		color.a = 0.78
		var size: float = s["size"]
		_splats.add(Transform2D(s["angle"], Vector2(size, size), 0.0, s["pos"]), color, Color(s["seed"], 0, 0, 0))
	_splats.finish()


func _sync_ambient() -> void:
	var time := Time.get_ticks_msec() * 0.001
	var rising := _biome.ambient != BiomeDef.Ambient.SPORES
	_ambient.begin()
	for seed_value in _ambient_seeds:
		var height := GameConfig.ARENA_HALF.y * 2.4
		var y := fposmod(seed_value.y - time * (40.0 + seed_value.z * 60.0), height) - height * 0.5 if rising else seed_value.y
		var pos := Vector2(seed_value.x + sin(time * 0.6 + seed_value.z * 20.0) * 30.0, y)
		var color := _biome.color_c
		color.a = 0.18 + 0.3 * seed_value.z
		var size := 8.0 + seed_value.z * 30.0
		_ambient.add(Transform2D(0.0, Vector2(size, size), 0.0, pos), color)
	_ambient.finish()


func _update_camera(delta: float) -> void:
	var points: Array[Vector2] = []
	for slot in Session.slots:
		var player := world.player(slot.player_id)
		if player != null and player.alive:
			points.append(_heroes[player.id].position)
	if points.is_empty():
		for p in world.players:
			if p.alive:
				points.append(_heroes[p.id].position)
	if points.is_empty():
		return
	var bounds := Rect2(points[0], Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)
	var view := get_viewport_rect().size
	var fit := minf(view.x / (bounds.size.x + 900.0), view.y / (bounds.size.y + 560.0))
	var zoom_value := lerpf(camera.zoom.x, clampf(fit, 0.62, 1.0), 1.0 - exp(-delta * 3.0))
	camera.zoom = Vector2(zoom_value, zoom_value)
	var target := bounds.get_center()
	var visible := view / zoom_value * 0.5
	var limit := (GameConfig.ARENA_HALF + Vector2(120, 120) - visible).max(Vector2.ZERO)
	target = target.clamp(-limit, limit)
	camera.position = camera.position.lerp(target, 1.0 - exp(-delta * 7.0))
	_shake = maxf(0.0, _shake - delta * 60.0)
	camera.offset = Vector2(randf_range(-_shake, _shake), randf_range(-_shake, _shake))


func _build_backdrop() -> void:
	var rect := ColorRect.new()
	rect.position = BACKDROP_ORIGIN
	rect.size = BACKDROP_SIZE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material_bg := ShaderMaterial.new()
	material_bg.shader = _biome.background_shader
	material_bg.set_shader_parameter("color_a", _biome.color_a)
	material_bg.set_shader_parameter("color_b", _biome.color_b)
	material_bg.set_shader_parameter("color_c", _biome.color_c)
	material_bg.set_shader_parameter("arena_half", GameConfig.ARENA_HALF)
	material_bg.set_shader_parameter("world_origin", BACKDROP_ORIGIN)
	material_bg.set_shader_parameter("world_size", BACKDROP_SIZE)
	rect.material = material_bg
	add_child(rect)


func _build_heroes() -> void:
	var index := 0
	for p in world.players:
		var hero := HeroVisual.new()
		hero.setup(Content.character(p.character_id), index * 0.37)
		hero.position = p.pos
		add_child(hero)
		_heroes[p.id] = hero
		index += 1


func _build_ambient() -> void:
	var half := GameConfig.ARENA_HALF * 1.2
	for _i in AMBIENT_COUNT:
		_ambient_seeds.append(Vector3(randf_range(-half.x, half.x), randf_range(-half.y, half.y), randf()))


func _build_postfx() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 1
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_post_material = _shader_material(POSTFX)
	rect.material = _post_material
	layer.add_child(rect)
	add_child(layer)


func _new_batch(capacity: int, batch_material: Material, custom: bool) -> EntityBatch:
	var batch := EntityBatch.new(capacity, batch_material, custom)
	add_child(batch)
	return batch


func _shader_material(shader: Shader) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = shader
	return result
