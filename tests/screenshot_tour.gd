extends Node
## Walks through the real UI and saves screenshots; needs a display.
##   godot --path . res://tests/screenshot_tour.tscn -- <output folder>

var out := "user://shots"
var app: App


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out = args[0]
	DirAccess.make_dir_recursive_absolute(out)
	get_window().size = Vector2i(1920, 1080)
	Save.path = "user://tour_profile.json"
	Save.load_profile()
	app = load("res://scenes/main.tscn").instantiate()
	add_child(app)
	await wait(0.5)
	await shot("01_menu")
	await run_biome("sunken_deep", "02_water", "warrior", "hunter")
	await run_biome("demon_tower", "03_demon", "hunter", "warrior")
	get_tree().quit()


func run_biome(biome: String, name_prefix: String, first: String, second: String) -> void:
	Session.reset()
	Session.biome_id = biome
	app.show_screen(LobbyScreen.new())
	var slot := Session.add_local_player(LocalSlot.KEYBOARD)
	Session.set_character(slot, first)
	var slot2 := Session.add_local_player(0)
	Session.set_character(slot2, second)
	await wait(0.4)
	(app._current as LobbyScreen)._refresh()
	await wait(0.3)
	await shot(name_prefix + "_lobby")
	Session.start_match()
	await wait(0.3)
	var game: GameScreen = app._current
	var sim := game.controller.simulation
	sim.world.wave = 7
	sim.world.time_left = 60.0
	for p in sim.world.players:
		p.weapons.append(WeaponInstance.new("axe"))
		p.weapons.append(WeaponInstance.new("fire_staff"))
		p.weapons.append(WeaponInstance.new("crossbow"))
		p.stats[Stats.MAX_HP] = 500.0
		p.hp = 500.0
		p.materials = 60
	for i in 70:
		var entry: SpawnEntry = sim.biome.spawns[i % sim.biome.spawns.size()]
		sim.spawn_enemy(entry.enemy, Vector2(randf_range(-850, 850), randf_range(-520, 520)))
	# A scripted move and attack so effects show up in the frame.
	var t := 0.0
	while t < 5.0:
		var intents := {}
		for p in sim.world.players:
			var intent := PlayerIntent.new()
			intent.move = Vector2.from_angle(t + p.id).normalized() * 0.5
			intent.attacking = true
			var nearest := _nearest(sim, p)
			intent.aim = p.pos.direction_to(nearest) if nearest != Vector2.INF else Vector2.RIGHT
			game.controller.scripted_intents[p.id] = intent
		await get_tree().physics_frame
		t += 1.0 / 60.0
	await shot(name_prefix + "_fight")
	sim.world.time_left = 0.0
	await wait(0.4)
	await shot(name_prefix + "_shop")
	game.queue_free()
	app._current = null


func _nearest(sim: Simulation, p: PlayerState) -> Vector2:
	var best := Vector2.INF
	var best_d := INF
	for e in sim.world.enemies:
		var d := e.pos.distance_squared_to(p.pos)
		if d < best_d:
			best_d = d
			best = e.pos
	return best


func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func shot(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [out, file_name])
