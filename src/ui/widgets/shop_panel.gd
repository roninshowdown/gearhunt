class_name ShopPanel
extends PanelContainer
## One player's shop. Buttons do not use Godot's global focus, because in local
## co-op two people navigate at once; each panel listens to its own device.

const NAV_REPEAT := 0.2
const ACTIONS_PER_ROW := 2

var controller: MatchController
var slot: LocalSlot

var _column: VBoxContainer
var _actions: Array[Button] = []
var _commands: Array[Dictionary] = []
var _selected := 0
var _nav_timer := 0.0


func setup(p_controller: MatchController, p_slot: LocalSlot) -> void:
	controller = p_controller
	slot = p_slot
	custom_minimum_size = Vector2(760, 0)
	_column = VBoxContainer.new()
	_column.add_theme_constant_override("separation", 10)
	add_child(_column)
	refresh()


func refresh() -> void:
	var p := controller.world.player(slot.player_id)
	if p == null:
		return
	for child in _column.get_children():
		_column.remove_child(child)
		child.queue_free()
	_actions.clear()
	_commands.clear()
	var character := Content.character(p.character_id)
	_column.add_child(UiTheme.label(tr(character.display_name), 34, character.look.body_color.lightened(0.25), true))
	_column.add_child(UiTheme.label("%s   ·   %s" % [tr("SHOP_MATERIALS") % p.materials, tr("SHOP_WEAPONS") % [p.weapons.size(), GameConfig.MAX_WEAPONS]], 25, UiTheme.WARM))
	for i in p.offers.size():
		_add_offer(p, i)
	var reroll_price := ShopSystem.reroll_price(controller.world.wave, p.rerolls)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	_column.add_child(footer)
	var reroll := _add_action(tr("SHOP_REROLL") % reroll_price, {"type": "reroll"}, footer)
	reroll.disabled = p.ready or p.materials < reroll_price
	reroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var ready_text := tr("SHOP_WAITING") if p.ready else tr("SHOP_READY")
	var ready_button := _add_action(ready_text, {"type": "ready", "value": not p.ready}, footer)
	ready_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_selected = clampi(_selected, 0, _actions.size() - 1)
	_highlight()


func _add_offer(p: PlayerState, index: int) -> void:
	var offer := p.offers[index]
	var id := String(offer["id"])
	var is_weapon: bool = offer["kind"] == ShopSystem.KIND_WEAPON
	var def: ContentDef = Content.weapon(id) if is_weapon else Content.item(id)
	var sold: bool = offer["sold"]
	var price := int(offer["price"])
	var kind := tr("SHOP_KIND_WEAPON") if is_weapon else tr("SHOP_KIND_ITEM")
	var text := "%s  (%s)\n%s" % [tr(def.display_name), kind, tr(def.description)]
	var button := _add_action(text, {"type": "buy", "slot": index}, _column)
	button.custom_minimum_size.y = 96
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 25)
	var full: bool = is_weapon and p.weapons.size() >= GameConfig.MAX_WEAPONS
	button.disabled = sold or full or p.ready or p.materials < price
	var tag := UiTheme.label(tr("SHOP_SOLD") if sold else str(price), 32, UiTheme.MUTED if sold else UiTheme.WARM, true)
	tag.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	tag.offset_left = -130
	tag.offset_right = -22
	tag.offset_top = -24
	tag.offset_bottom = 24
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	button.add_child(tag)


func _add_action(text: String, command: Dictionary, parent: Control) -> Button:
	var button := UiTheme.button(text, func() -> void: _send(command))
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	_actions.append(button)
	_commands.append(command)
	return button


func _send(command: Dictionary) -> void:
	if command.get("type") == "buy":
		Sfx.play(Sfx.Sound.BUY)
	controller.send_command(slot.player_id, command)


func _process(delta: float) -> void:
	_nav_timer -= delta
	if slot == null or slot.device == LocalSlot.KEYBOARD:
		return
	var y := Input.get_joy_axis(slot.device, JOY_AXIS_LEFT_Y)
	if absf(y) > 0.6 and _nav_timer <= 0.0:
		_nav_timer = NAV_REPEAT
		_move(int(signf(y)))


func _input(event: InputEvent) -> void:
	if slot == null:
		return
	if slot.device == LocalSlot.KEYBOARD and event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_W, KEY_UP:
				_move(-1)
			KEY_S, KEY_DOWN:
				_move(1)
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_activate()
	elif event is InputEventJoypadButton and event.pressed and event.device == slot.device:
		match event.button_index:
			JOY_BUTTON_DPAD_UP:
				_move(-1)
			JOY_BUTTON_DPAD_DOWN:
				_move(1)
			JOY_BUTTON_A:
				_activate()


func _move(step: int) -> void:
	_selected = posmod(_selected + step, _actions.size())
	_highlight()


func _activate() -> void:
	if not _actions[_selected].disabled:
		_send(_commands[_selected])


func _highlight() -> void:
	for i in _actions.size():
		_actions[i].modulate = Color(1.25, 1.25, 1.25) if i == _selected else Color.WHITE
		if i == _selected:
			_actions[i].add_theme_stylebox_override("normal", UiTheme.box(UiTheme.BG_LIGHT, UiTheme.ACCENT, 14))
		else:
			_actions[i].remove_theme_stylebox_override("normal")
