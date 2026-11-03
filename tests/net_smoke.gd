extends Node
## End-to-end network test over localhost; run one host and one client:
##   godot --headless --path . res://tests/net_smoke.tscn -- host
##   godot --headless --path . res://tests/net_smoke.tscn -- client
## Uses the real Session, Net and MatchController code paths. Exit code 0 = pass.

const PORT := 24999
const RUN_SECONDS := 9.0

var controller: MatchController
var max_enemies_seen := 0
var snapshots := 0
var client_moved := false
var bought := false


func _ready() -> void:
	var role := OS.get_cmdline_user_args()[0]
	get_tree().create_timer(45.0).timeout.connect(func() -> void:
		printerr(role, ": timeout")
		get_tree().quit(2))
	Session.reset()
	Session.match_ready.connect(_on_match)
	if role == "host":
		assert(Net.host(PORT))
		Session.add_local_player(LocalSlot.KEYBOARD)
		Session.roster_changed.connect(_on_roster_host)
		Net.lobby_action_received.connect(func(_peer: int, _a: Dictionary) -> void: pass)
	else:
		Net.connected_to_host.connect(func() -> void:
			Session.add_local_player(LocalSlot.KEYBOARD)
			var slot := Session.slots[0]
			Session.set_character(slot, "warrior"))
		await get_tree().create_timer(0.5).timeout
		assert(Net.join("127.0.0.1", PORT))


func _on_roster_host() -> void:
	if Session.roster.size() == 2 and controller == null:
		Session.start_match()


func _on_match(config: MatchConfig) -> void:
	controller = MatchController.new()
	add_child(controller)
	controller.setup(config)
	Net.snapshot_received.connect(func(_b: PackedByteArray) -> void: snapshots += 1)
	if not Net.is_host():
		_run_client()
	else:
		_run_host()


func _run_client() -> void:
	var slot := Session.slots[0]
	var start_x := controller.world.player(slot.player_id).pos.x
	var elapsed := 0.0
	while elapsed < RUN_SECONDS:
		await get_tree().physics_frame
		elapsed += 1.0 / 60.0
		var intent := PlayerIntent.new()
		intent.move = Vector2.RIGHT
		controller.scripted_intents[slot.player_id] = intent
		max_enemies_seen = maxi(max_enemies_seen, controller.world.enemies.size())
	var moved := absf(controller.world.player(slot.player_id).pos.x - start_x)
	print("client: %d snapshots, peak %d enemies, moved %.0f px" % [snapshots, max_enemies_seen, moved])
	# Host now ends the wave; check that economy, shop and commands replicate.
	var waited := 0.0
	while controller.world.phase != WorldState.Phase.SHOP and waited < 10.0:
		await get_tree().physics_frame
		waited += 1.0 / 60.0
	var p := controller.world.player(slot.player_id)
	var shop_ok := controller.world.phase == WorldState.Phase.SHOP and p.offers.size() == GameConfig.SHOP_OFFERS
	print("client: shop reached=%s offers=%d materials=%d" % [shop_ok, p.offers.size(), p.materials])
	controller.send_command(slot.player_id, {"type": "ready", "value": true})
	waited = 0.0
	while controller.world.wave != 2 and waited < 10.0:
		await get_tree().physics_frame
		waited += 1.0 / 60.0
	print("client: next wave=%d" % controller.world.wave)
	var ok := snapshots > 100 and max_enemies_seen > 0 and moved > 400.0 and shop_ok and controller.world.wave == 2
	print("client: ", "PASS" if ok else "FAIL")
	get_tree().quit(0 if ok else 1)


func _run_host() -> void:
	var sim := controller.simulation
	for p in sim.world.players:
		p.stats[Stats.MAX_HP] = 99999.0
		p.hp = 99999.0
	controller.scripted_intents[sim.world.players[0].id] = PlayerIntent.new()
	await get_tree().create_timer(RUN_SECONDS + 1.0).timeout
	var client := sim.world.players[1]
	print("host: client player at x=%.0f" % client.pos.x)
	sim.world.time_left = 0.0
	sim.world.players[0].ready = true
	await get_tree().create_timer(0.3).timeout
	sim.world.players[0].ready = true
	var waited := 0.0
	while sim.world.wave != 2 and waited < 10.0:
		await get_tree().physics_frame
		sim.world.players[0].ready = true
		waited += 1.0 / 60.0
	print("host: wave=%d" % sim.world.wave)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0 if sim.world.wave == 2 else 1)
