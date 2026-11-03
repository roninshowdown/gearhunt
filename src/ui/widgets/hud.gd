class_name Hud
extends Control
## In-wave overlay. Reads WorldState only.

var world: WorldState

var _wave: Label
var _timer: Label
var _players: HBoxContainer
var _bars: Dictionary = {}
var _boss_bar: ProgressBar


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(p_world: WorldState) -> void:
	world = p_world
	_players = HBoxContainer.new()
	_players.position = Vector2(30, 24)
	_players.add_theme_constant_override("separation", 22)
	add_child(_players)
	for p in world.players:
		_add_player_panel(p)
	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER_TOP)
	center.offset_left = -220
	center.offset_right = 220
	center.offset_top = 18
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_wave = UiTheme.label("", 30, UiTheme.TEXT, true)
	_wave.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outline(_wave)
	center.add_child(_wave)
	_timer = UiTheme.label("", 68, UiTheme.TEXT, true)
	_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outline(_timer)
	center.add_child(_timer)
	_boss_bar = _bar(UiTheme.DANGER, Vector2(900, 30))
	_boss_bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_boss_bar.offset_left = -450
	_boss_bar.offset_right = 450
	_boss_bar.offset_top = -70
	_boss_bar.offset_bottom = -36
	_boss_bar.visible = false
	add_child(_boss_bar)


func _process(_delta: float) -> void:
	if world == null:
		return
	_wave.text = tr("HUD_WAVE") % [world.wave, GameConfig.TOTAL_WAVES]
	_timer.text = str(ceili(maxf(world.time_left, 0.0)))
	_timer.add_theme_color_override("font_color", UiTheme.DANGER if world.time_left < 5.0 else UiTheme.TEXT)
	for p in world.players:
		var entry: Dictionary = _bars[p.id]
		var bar: ProgressBar = entry["hp"]
		bar.max_value = p.max_hp()
		bar.value = p.hp
		entry["hp_text"].text = "%d / %d" % [ceili(p.hp), roundi(p.max_hp())] if p.alive else tr("HUD_DOWN")
		entry["materials"].text = str(p.materials)
	_update_boss()


func _update_boss() -> void:
	_boss_bar.visible = false
	for e in world.enemies:
		if Content.enemy_by_index(e.def_index).is_boss:
			_boss_bar.visible = true
			_boss_bar.value = e.hp / maxf(e.max_hp, 0.01) * 100.0
			return


func _add_player_panel(p: PlayerState) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTheme.box(Color(0.03, 0.05, 0.1, 0.72), Color(1, 1, 1, 0.08), 14, 2))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	var character := Content.character(p.character_id)
	var title := HBoxContainer.new()
	title.add_theme_constant_override("separation", 14)
	column.add_child(title)
	var name_label := UiTheme.label(tr(character.display_name), 24, character.look.body_color.lightened(0.25), true)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_child(name_label)
	var materials := UiTheme.label("0", 24, Color(0.6, 1.0, 0.6), true)
	title.add_child(materials)
	var stack := Control.new()
	stack.custom_minimum_size = Vector2(300, 32)
	column.add_child(stack)
	var bar := _bar(Color(0.3, 0.92, 0.48), Vector2(300, 32))
	stack.add_child(bar)
	var hp_text := UiTheme.label("", 21, Color.WHITE, true)
	hp_text.custom_minimum_size = Vector2(300, 32)
	hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stack.add_child(hp_text)
	_players.add_child(panel)
	_bars[p.id] = {"hp": bar, "hp_text": hp_text, "materials": materials}


func _bar(fill: Color, size_value: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = size_value
	bar.size = size_value
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := UiTheme.box(Color(0.02, 0.02, 0.05, 0.9), Color(0, 0, 0, 0), 8, 0)
	background.set_content_margin_all(0)
	var foreground := UiTheme.box(fill, Color(0, 0, 0, 0), 8, 0)
	foreground.set_content_margin_all(0)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", foreground)
	return bar


func _outline(target: Label) -> void:
	target.add_theme_constant_override("outline_size", 10)
	target.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08))
