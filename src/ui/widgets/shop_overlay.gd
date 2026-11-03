class_name ShopOverlay
extends Control
## Between-wave shop with one panel per local player.

var controller: MatchController

var _title: Label
var _panels: Array[ShopPanel] = []


func setup(p_controller: MatchController) -> void:
	controller = p_controller
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.05, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	center.add_child(column)
	_title = UiTheme.label("", 52, UiTheme.ACCENT, true)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	column.add_child(row)
	for slot in Session.slots:
		var panel := ShopPanel.new()
		row.add_child(panel)
		panel.setup(controller, slot)
		_panels.append(panel)
	controller.economy_changed.connect(refresh)


func refresh() -> void:
	if not visible:
		return
	_title.text = tr("SHOP_TITLE") % controller.world.wave
	for panel in _panels:
		panel.refresh()
