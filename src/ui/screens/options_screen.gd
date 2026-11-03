class_name OptionsScreen
extends Screen


func _ready() -> void:
	add_child(MenuBackdrop.new())
	var column := centered_column(620)
	column.add_child(UiTheme.label(tr("MENU_OPTIONS"), 56, UiTheme.ACCENT, true))

	var fullscreen := CheckButton.new()
	fullscreen.text = tr("OPT_FULLSCREEN")
	fullscreen.button_pressed = bool(Save.setting("fullscreen"))
	fullscreen.toggled.connect(func(on: bool) -> void: Save.set_setting("fullscreen", on))
	column.add_child(fullscreen)

	column.add_child(UiTheme.label(tr("OPT_VOLUME")))
	var volume := HSlider.new()
	volume.max_value = 1.0
	volume.step = 0.05
	volume.value = float(Save.setting("volume"))
	volume.value_changed.connect(func(value: float) -> void: Save.set_setting("volume", value))
	column.add_child(volume)

	column.add_child(UiTheme.label(tr("OPT_LANGUAGE")))
	var languages := HBoxContainer.new()
	languages.add_theme_constant_override("separation", 12)
	for entry: Array in [["de", "Deutsch"], ["en", "English"]]:
		var code: String = entry[0]
		var button := UiTheme.button(entry[1], func() -> void:
			Save.set_setting("language", code)
			app.show_screen(OptionsScreen.new()))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		languages.add_child(button)
	column.add_child(languages)

	var back := UiTheme.button(tr("MENU_BACK"), func() -> void: app.show_menu())
	column.add_child(back)
	focus_first(back)
