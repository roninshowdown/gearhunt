class_name GameScreen
extends Screen
## Composes one match: controller, world view, HUD, shop, pause and end overlays.

var config: MatchConfig
var controller := MatchController.new()
var view := WorldView.new()
var hud := Hud.new()
var shop := ShopOverlay.new()

var _overlays: CanvasLayer
var _pause: Control
var _end: Control
var _rewarded := false


func _ready() -> void:
	add_child(controller)
	controller.setup(config)
	add_child(view)
	view.setup(controller.world, UiTheme.FONT_BOLD)
	controller.events_ready.connect(view.handle_events)
	controller.phase_changed.connect(_on_phase_changed)

	_overlays = CanvasLayer.new()
	_overlays.layer = 2
	add_child(_overlays)
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.theme = UiTheme.build()
	_overlays.add_child(ui)
	ui.add_child(hud)
	hud.setup(controller.world)
	ui.add_child(shop)
	shop.setup(controller)
	shop.visible = false
	_pause = _build_pause()
	ui.add_child(_pause)
	_end = Control.new()
	_end.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_end.visible = false
	ui.add_child(_end)


func _process(_delta: float) -> void:
	controller.mouse_world = view.get_global_mouse_position()


func _input(event: InputEvent) -> void:
	var pressed_pause: bool = (event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_ESCAPE) \
		or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START)
	if pressed_pause and controller.world.phase == WorldState.Phase.WAVE:
		_toggle_pause()


func _toggle_pause() -> void:
	_pause.visible = not _pause.visible
	if not Net.is_online():
		controller.paused = _pause.visible
	if _pause.visible:
		_pause.find_child("Resume", true, false).grab_focus()


func _on_phase_changed(phase: WorldState.Phase) -> void:
	hud.visible = phase == WorldState.Phase.WAVE
	shop.visible = phase == WorldState.Phase.SHOP
	if shop.visible:
		shop.refresh()
	if phase == WorldState.Phase.VICTORY or phase == WorldState.Phase.DEFEAT:
		_show_end(phase == WorldState.Phase.VICTORY)


func _show_end(victory: bool) -> void:
	var kills := 0
	for p in controller.world.players:
		kills += p.kills
	var reward := MetaRewards.soul_dust(controller.world.wave, kills, victory)
	if not _rewarded:
		_rewarded = true
		Save.award_soul_dust(reward)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.05, 0.8)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_end.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_end.add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 620
	column.add_theme_constant_override("separation", 18)
	center.add_child(column)
	var title := UiTheme.label(tr("END_VICTORY") if victory else tr("END_DEFEAT"), 84, UiTheme.ACCENT if victory else UiTheme.DANGER, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var summary := UiTheme.label(tr("END_SUMMARY") % [controller.world.wave, kills], 28)
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(summary)
	var dust := UiTheme.label(tr("END_REWARD") % reward, 36, UiTheme.WARM, true)
	dust.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(dust)
	var back := UiTheme.button(tr("MENU_BACK"), _quit_to_menu)
	column.add_child(back)
	_end.visible = true
	back.grab_focus()


func _build_pause() -> Control:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.visible = false
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.05, 0.7)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 460
	column.add_theme_constant_override("separation", 16)
	center.add_child(column)
	var title := UiTheme.label(tr("PAUSE_TITLE"), 62, UiTheme.ACCENT, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var resume := UiTheme.button(tr("PAUSE_RESUME"), _toggle_pause)
	resume.name = "Resume"
	column.add_child(resume)
	column.add_child(UiTheme.button(tr("PAUSE_QUIT"), _quit_to_menu))
	return root


func _quit_to_menu() -> void:
	if Net.is_online():
		Net.leave()
	app.show_menu()
