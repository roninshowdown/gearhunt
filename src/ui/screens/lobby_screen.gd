class_name LobbyScreen
extends Screen
## Character and world selection. Same screen offline, as host and as client.
## Every local player is driven by their own device.

const NAV_REPEAT := 0.25

var _cards: HBoxContainer
var _biome_label: Label
var _start: Button
var _nav_lock: Dictionary = {}


func _ready() -> void:
	add_child(MenuBackdrop.new())
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 70
	root.offset_right = -70
	root.offset_top = 50
	root.offset_bottom = -50
	root.add_theme_constant_override("separation", 22)
	add_child(root)
	root.add_child(UiTheme.label(tr("LOBBY_TITLE"), 60, UiTheme.ACCENT, true))
	var hint := tr("LOBBY_HINT")
	if Net.is_online() and Net.is_host():
		hint = (tr("LOBBY_YOU_HOST") % GameConfig.DEFAULT_PORT) + "  ·  " + hint
	root.add_child(UiTheme.label(hint, 22, UiTheme.MUTED))
	_cards = HBoxContainer.new()
	_cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards.add_theme_constant_override("separation", 24)
	root.add_child(_cards)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 16)
	root.add_child(footer)
	footer.add_child(UiTheme.button(tr("MENU_BACK"), _leave))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(spacer)
	if Net.is_host():
		footer.add_child(UiTheme.button("<", func() -> void: _cycle_biome(-1)))
	_biome_label = UiTheme.label("", 30, UiTheme.TEXT, true)
	footer.add_child(_biome_label)
	if Net.is_host():
		footer.add_child(UiTheme.button(">", func() -> void: _cycle_biome(1)))
		_start = UiTheme.button(tr("LOBBY_START"), _start_run)
		_start.custom_minimum_size.x = 300
		footer.add_child(_start)
	else:
		footer.add_child(UiTheme.label(tr("LOBBY_WAITING"), 26, UiTheme.WARM))
	Session.roster_changed.connect(_refresh)
	_refresh()


func _exit_tree() -> void:
	Session.roster_changed.disconnect(_refresh)


func _process(delta: float) -> void:
	for device: int in _nav_lock.keys():
		_nav_lock[device] = float(_nav_lock[device]) - delta
	for device in Input.get_connected_joypads():
		var x := Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
		if absf(x) > 0.6 and float(_nav_lock.get(device, 0.0)) <= 0.0:
			var slot := Session.slot_for_device(device)
			if slot != null:
				_nav_lock[device] = NAV_REPEAT
				_cycle_character(slot, int(signf(x)))


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_on_key(event)
	elif event is InputEventJoypadButton and event.pressed:
		_on_joy_button(event)


func _on_key(event: InputEventKey) -> void:
	var slot := Session.slot_for_device(LocalSlot.KEYBOARD)
	match event.physical_keycode:
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			if slot == null:
				Session.add_local_player(LocalSlot.KEYBOARD)
				_refresh()
			elif Net.is_host():
				_start_run()
		KEY_A, KEY_LEFT:
			if slot != null:
				_cycle_character(slot, -1)
		KEY_D, KEY_RIGHT:
			if slot != null:
				_cycle_character(slot, 1)
		KEY_ESCAPE:
			if slot != null:
				Session.remove_local_player(slot)
				_refresh()
			else:
				_leave()


func _on_joy_button(event: InputEventJoypadButton) -> void:
	var slot := Session.slot_for_device(event.device)
	match event.button_index:
		JOY_BUTTON_A:
			if slot == null:
				Session.add_local_player(event.device)
				_refresh()
		JOY_BUTTON_B:
			if slot != null:
				Session.remove_local_player(slot)
				_refresh()
		JOY_BUTTON_START:
			if slot != null and Net.is_host():
				_start_run()
		JOY_BUTTON_DPAD_LEFT:
			if slot != null:
				_cycle_character(slot, -1)
		JOY_BUTTON_DPAD_RIGHT:
			if slot != null:
				_cycle_character(slot, 1)
		JOY_BUTTON_LEFT_SHOULDER:
			_cycle_biome(-1)
		JOY_BUTTON_RIGHT_SHOULDER:
			_cycle_biome(1)


func _start_run() -> void:
	if Session.slots.is_empty():
		Session.add_local_player(LocalSlot.KEYBOARD)
	Session.start_match()


func _leave() -> void:
	if Net.is_online():
		Net.leave()
	app.show_menu()


func _cycle_character(slot: LocalSlot, step: int) -> void:
	var ids: Array = Content.sorted_ids(Content.characters).filter(func(id: String) -> bool:
		return Save.is_unlocked(Content.character(id)))
	var index := ids.find(slot.character_id)
	Session.set_character(slot, ids[posmod(index + step, ids.size())])
	_refresh()


func _cycle_biome(step: int) -> void:
	if not Net.is_host():
		return
	var ids := Content.sorted_ids(Content.biomes)
	Session.set_biome(ids[posmod(ids.find(Session.biome_id) + step, ids.size())])
	_refresh()


func _refresh() -> void:
	for child in _cards.get_children():
		child.queue_free()
	if not Net.is_host() and Session.biome_id == "":
		Session.biome_id = Content.sorted_ids(Content.biomes)[0]
	var biome_name := tr(Content.biome(Session.biome_id).display_name)
	_biome_label.text = "%s: %s" % [tr("LOBBY_BIOME"), biome_name]
	var shown := 0
	for slot in Session.slots:
		_cards.add_child(_card(slot.character_id, _device_name(slot), slot))
		shown += 1
	for entry in Session.roster:
		if entry["peer_id"] != Net.my_peer_id():
			_cards.add_child(_card(entry["character_id"], tr("LOBBY_REMOTE"), null))
			shown += 1
	for _i in range(shown, mini(GameConfig.MAX_LOCAL_PLAYERS if not Net.is_online() else GameConfig.MAX_PLAYERS, GameConfig.MAX_PLAYERS)):
		_cards.add_child(_empty_card())


func _card(character_id: String, owner_name: String, slot: LocalSlot) -> Control:
	var character := Content.character(character_id)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 0)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	column.add_child(UiTheme.label(owner_name, 22, UiTheme.MUTED))
	var preview := CreaturePreview.new()
	preview.show_character(character)
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(preview)
	var selector := HBoxContainer.new()
	selector.alignment = BoxContainer.ALIGNMENT_CENTER
	selector.add_theme_constant_override("separation", 12)
	if slot != null:
		var previous := UiTheme.button("<", func() -> void: _cycle_character(slot, -1))
		previous.focus_mode = Control.FOCUS_NONE
		selector.add_child(previous)
	selector.add_child(UiTheme.label(tr(character.display_name), 38, UiTheme.TEXT, true))
	if slot != null:
		var following := UiTheme.button(">", func() -> void: _cycle_character(slot, 1))
		following.focus_mode = Control.FOCUS_NONE
		selector.add_child(following)
	column.add_child(selector)
	var description := UiTheme.label(tr(character.description), 23, UiTheme.MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(340, 72)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(description)
	return panel


func _empty_card() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 0)
	panel.modulate.a = 0.55
	var text := UiTheme.label(tr("LOBBY_EMPTY"), 28, UiTheme.MUTED)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(text)
	return panel


func _device_name(slot: LocalSlot) -> String:
	if slot.device == LocalSlot.KEYBOARD:
		return tr("LOBBY_KEYBOARD") % (slot.index + 1)
	return tr("LOBBY_CONTROLLER") % [slot.index + 1, slot.device + 1]
