class_name Screen
extends Control
## Base class of everything the App can show. Screens are built in code so
## that they stay diff-friendly and easy to change without the editor.

var app: App


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## A centred vertical column, the standard layout for simple screens.
func centered_column(width: float) -> VBoxContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = width
	column.add_theme_constant_override("separation", 16)
	center.add_child(column)
	return column


func focus_first(button: Control) -> void:
	button.call_deferred("grab_focus")
