extends Node
## Headless test suite:
##   godot --headless --path . res://tests/test_runner.tscn
## Exits with code 1 on any failure.

var _failures := 0
var _checks := 0


func _ready() -> void:
	_test_content_is_valid()
	_test_translations_complete()
	_test_full_run_with_bot("warrior", "sunken_deep")
	_test_full_run_with_bot("hunter", "demon_tower")
	_test_shop_rules()
	_test_snapshot_roundtrip()
	_test_save_roundtrip()
	_test_same_seed_same_result()
	print("%d checks, %d failures" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)


func check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("FAIL: ", message)


func _test_content_is_valid() -> void:
	check(Content.characters.size() >= 2, "at least two classes")
	check(Content.biomes.size() >= 2, "at least two biomes")
	for table: Dictionary in [Content.characters, Content.weapons, Content.items, Content.enemies, Content.biomes, Content.meta_upgrades]:
		for id: String in table:
			var def: ContentDef = table[id]
			check(def.resource_path.get_file().get_basename() == id, "%s: id equals file name" % id)
	for character: CharacterDef in Content.characters.values():
		check(character.starting_weapon != null and character.look != null, "%s complete" % character.id)
		_check_stat_keys(character.base_stats, character.id)
	for item: ItemDef in Content.items.values():
		_check_stat_keys(item.stats, item.id)
	for upgrade: MetaUpgradeDef in Content.meta_upgrades.values():
		check(Stats.is_valid(upgrade.stat), "%s stat" % upgrade.id)
	for weapon: WeaponDef in Content.weapons.values():
		check(weapon.attack != null, "%s attack" % weapon.id)
	for enemy: EnemyDef in Content.enemies.values():
		check(enemy.behavior != null and enemy.look != null, "%s complete" % enemy.id)
	for biome: BiomeDef in Content.biomes.values():
		check(not biome.spawns.is_empty() and biome.boss != null and biome.background_shader != null, "%s complete" % biome.id)


func _check_stat_keys(stats: Dictionary, owner_id: String) -> void:
	for key: String in stats:
		check(Stats.is_valid(key), "%s: unknown stat %s" % [owner_id, key])


func _test_translations_complete() -> void:
	var names: Array[String] = []
	for table: Dictionary in [Content.characters, Content.weapons, Content.items, Content.enemies, Content.biomes, Content.meta_upgrades]:
		for def: ContentDef in table.values():
			names.append(def.display_name)
			if def.description != "":
				names.append(def.description)
	for locale in ["de", "en"]:
		TranslationServer.set_locale(locale)
		for key in names:
			check(tr(key) != key, "%s missing %s" % [locale, key])


func _config(character: String, biome: String, players: int = 1, seed_value: int = 1234) -> MatchConfig:
	var config := MatchConfig.new()
	config.seed_value = seed_value
	config.biome_id = biome
	for i in players:
		config.loadouts.append({"player_id": i + 1, "peer_id": 1, "character_id": character, "meta_stats": {}})
	return config


## Simple bot that kites and attacks the nearest enemy.
func _bot_intents(sim: Simulation) -> Dictionary:
	var intents := {}
	for p in sim.living_players():
		var intent := PlayerIntent.new()
		var nearest: EnemyState = null
		var best := INF
		for e in sim.world.enemies:
			var d := e.pos.distance_squared_to(p.pos)
			if d < best:
				best = d
				nearest = e
		if nearest != null:
			intent.aim = p.pos.direction_to(nearest.pos)
			intent.attacking = true
			intent.move = -intent.aim if best < 40000.0 else intent.aim * 0.4
		intents[p.id] = intent
	return intents


func _test_full_run_with_bot(character: String, biome: String) -> void:
	var sim := Simulation.new(_config(character, biome, 2))
	var ticks := 0
	var shops := 0
	var max_enemies := 0
	var start := Time.get_ticks_msec()
	while sim.world.phase in [WorldState.Phase.WAVE, WorldState.Phase.SHOP] and ticks < 60 * 60 * 12:
		ticks += 1
		var was_shop := sim.world.phase == WorldState.Phase.SHOP
		if was_shop:
			shops += 1
			for p in sim.world.players:
				for slot in p.offers.size():
					sim.apply_command(p.id, {"type": "buy", "slot": slot})
				sim.apply_command(p.id, {"type": "ready", "value": true})
		sim.step(GameConfig.TICK_DT, _bot_intents(sim))
		sim.world.events.clear()
		max_enemies = maxi(max_enemies, sim.world.enemies.size())
	check(sim.world.phase in [WorldState.Phase.VICTORY, WorldState.Phase.DEFEAT], "%s run terminates" % biome)
	check(sim.world.wave >= 2, "%s bot reaches wave 2" % biome)
	check(max_enemies > 3, "%s spawns enemies" % biome)
	print("  bot %s/%s: wave %d, phase %d, peak %d enemies, %.1f us per tick" % [character, biome, sim.world.wave, sim.world.phase, max_enemies, (Time.get_ticks_msec() - start) * 1000.0 / maxi(ticks, 1)])


func _test_shop_rules() -> void:
	var sim := Simulation.new(_config("warrior", "sunken_deep"))
	sim.world.time_left = 0.0
	sim.step(GameConfig.TICK_DT, {})
	check(sim.world.phase == WorldState.Phase.SHOP, "wave end opens shop")
	var p := sim.world.players[0]
	check(p.offers.size() == GameConfig.SHOP_OFFERS, "shop has offers")
	p.materials = 0
	sim.apply_command(p.id, {"type": "buy", "slot": 0})
	check(not p.offers[0]["sold"], "cannot buy without materials")
	p.materials = 1000
	sim.apply_command(p.id, {"type": "buy", "slot": 0})
	check(p.offers[0]["sold"], "purchase works")
	var left := p.materials
	sim.apply_command(p.id, {"type": "buy", "slot": 0})
	check(p.materials == left, "cannot buy twice")
	sim.apply_command(p.id, {"type": "buy", "slot": 99})
	check(p.materials == left, "invalid slot ignored")
	sim.apply_command(p.id, {"type": "ready", "value": true})
	sim.step(GameConfig.TICK_DT, {})
	check(sim.world.wave == 2 and sim.world.phase == WorldState.Phase.WAVE, "ready starts next wave")


func _test_snapshot_roundtrip() -> void:
	var sim := Simulation.new(_config("hunter", "demon_tower", 2))
	for _i in 900:
		sim.step(GameConfig.TICK_DT, _bot_intents(sim))
	var mirror := WorldState.new()
	for source in sim.world.players:
		var p := PlayerState.new()
		p.id = source.id
		mirror.players.append(p)
	var events: Array[GameEvent] = sim.world.events.duplicate()
	var bytes := SnapshotCodec.encode_snapshot(sim.world, events)
	var decoded := SnapshotCodec.apply_snapshot(mirror, bytes)
	SnapshotCodec.apply_economy(mirror, SnapshotCodec.encode_economy(sim.world))
	check(mirror.tick == sim.world.tick, "tick roundtrip")
	check(mirror.enemies.size() == sim.world.enemies.size() and not mirror.enemies.is_empty(), "enemy roundtrip")
	check(mirror.pickups.size() == sim.world.pickups.size(), "pickup roundtrip")
	check(decoded.size() == events.size(), "event roundtrip")
	check(mirror.enemies[0].pos.distance_to(sim.world.enemies[0].pos) < 0.5, "enemy position precision")
	check(mirror.players[1].pos.distance_to(sim.world.players[1].pos) < 0.5, "player position precision")
	check(mirror.players[0].materials == sim.world.players[0].materials, "economy roundtrip")
	print("  snapshot: %d bytes with %d enemies" % [bytes.size(), mirror.enemies.size()])


func _test_save_roundtrip() -> void:
	var real_path: String = Save.path
	var real_data: Dictionary = Save.data
	Save.path = "user://test_profile.json"
	Save.data = Save._defaults()
	Save.award_soul_dust(500)
	var upgrade: MetaUpgradeDef = Content.meta_upgrades.values()[0]
	check(Save.buy_upgrade(upgrade), "buy upgrade")
	var dust := Save.soul_dust()
	Save.load_profile()
	check(Save.soul_dust() == dust, "dust persists")
	check(Save.upgrade_rank(upgrade) == 1, "rank persists")
	check(float(Save.meta_stats().get(upgrade.stat, 0.0)) == upgrade.per_rank, "meta stats applied")
	DirAccess.remove_absolute(Save.path)
	Save.path = real_path
	Save.data = real_data


func _test_same_seed_same_result() -> void:
	var a := Simulation.new(_config("warrior", "demon_tower"))
	var b := Simulation.new(_config("warrior", "demon_tower"))
	for _i in 1200:
		a.step(GameConfig.TICK_DT, _bot_intents(a))
		b.step(GameConfig.TICK_DT, _bot_intents(b))
	check(a.world.enemies.size() == b.world.enemies.size(), "deterministic enemy count")
	check(a.world.players[0].pos == b.world.players[0].pos, "deterministic player position")
