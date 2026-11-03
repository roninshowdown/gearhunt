class_name MainMenuScreen
extends Screen

var message := ""
var _address: LineEdit
var _status: Label


func _ready() -> void:
	add_child(MenuBackdrop.new())
	var column := centered_column(620)
	var title := UiTheme.label(tr("GAME_TITLE"), 92, UiTheme.ACCENT, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	column.add_child(_spacer(26))
	var play := UiTheme.button(tr("MENU_PLAY"), _play_offline)
	column.add_child(play)
	column.add_child(UiTheme.button(tr("MENU_HOST"), _host))
	_address = LineEdit.new()
	_address.placeholder_text = tr("MENU_ADDRESS")
	_address.text = "127.0.0.1"
	var join_row := HBoxContainer.new()
	join_row.add_theme_constant_override("separation", 12)
	_address.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	join_row.add_child(_address)
	join_row.add_child(UiTheme.button(tr("MENU_JOIN"), _join))
	column.add_child(join_row)
	column.add_child(UiTheme.button(tr("MENU_META"), func() -> void: app.show_screen(MetaScreen.new())))
	column.add_child(UiTheme.button(tr("MENU_OPTIONS"), func() -> void: app.show_screen(OptionsScreen.new())))
	column.add_child(UiTheme.button(tr("MENU_QUIT"), func() -> void: get_tree().quit()))
	_status = UiTheme.label(tr(message) if message != "" else "", 24, UiTheme.WARM)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_status)
	focus_first(play)
	Net.connected_to_host.connect(_on_joined)
	Net.connection_failed.connect(_on_join_failed)


func _exit_tree() -> void:
	Net.connected_to_host.disconnect(_on_joined)
	Net.connection_failed.disconnect(_on_join_failed)


func _play_offline() -> void:
	Session.reset()
	app.show_screen(LobbyScreen.new())


func _host() -> void:
	if not Net.host():
		_status.text = tr("NET_HOST_FAILED")
		return
	Session.reset()
	app.show_screen(LobbyScreen.new())


func _join() -> void:
	if Net.join(_address.text.strip_edges()):
		_status.text = tr("MENU_CONNECTING")
	else:
		_status.text = tr("NET_CONNECT_FAILED")


func _on_joined() -> void:
	Session.reset()
	app.show_screen(LobbyScreen.new())


func _on_join_failed() -> void:
	_status.text = tr("NET_CONNECT_FAILED")


func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	return spacer
