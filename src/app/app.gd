class_name App
extends Control
## Root of the running game: switches between screens.

var _current: Screen


func _ready() -> void:
	theme = UiTheme.build()
	Session.reset()
	Session.match_ready.connect(_on_match_ready)
	Net.disconnected.connect(func(reason: String) -> void: show_menu(reason))
	show_menu()


func show_menu(message: String = "") -> void:
	var menu := MainMenuScreen.new()
	menu.message = message
	show_screen(menu)


func show_screen(screen: Screen) -> void:
	if _current != null:
		_current.queue_free()
	screen.app = self
	_current = screen
	add_child(screen)


func _on_match_ready(config: MatchConfig) -> void:
	var game := GameScreen.new()
	game.config = config
	show_screen(game)
