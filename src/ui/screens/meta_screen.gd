class_name MetaScreen
extends Screen
## Spends soul dust on permanent upgrades and character unlocks.


func _ready() -> void:
	add_child(MenuBackdrop.new())
	var column := centered_column(860)
	column.add_child(UiTheme.label(tr("META_TITLE"), 56, UiTheme.ACCENT, true))
	column.add_child(UiTheme.label(tr("META_DUST") % Save.soul_dust(), 32, UiTheme.WARM, true))
	for id: String in Content.sorted_ids(Content.meta_upgrades):
		column.add_child(_upgrade_row(Content.meta_upgrades[id]))
	for id: String in Content.sorted_ids(Content.characters):
		var character := Content.character(id)
		if not Save.is_unlocked(character):
			column.add_child(_unlock_row(character))
	var back := UiTheme.button(tr("MENU_BACK"), func() -> void: app.show_menu())
	column.add_child(back)
	focus_first(back)


func _upgrade_row(upgrade: MetaUpgradeDef) -> Control:
	var rank := Save.upgrade_rank(upgrade)
	var maxed := rank >= upgrade.max_rank
	var cost := upgrade.cost_for_rank(rank)
	var action := tr("META_MAX") if maxed else tr("META_BUY") % cost
	var buy := UiTheme.button(action, func() -> void:
		Save.buy_upgrade(upgrade)
		app.show_screen(MetaScreen.new()))
	buy.disabled = maxed or Save.soul_dust() < cost
	return _row(tr(upgrade.display_name), "%s  ·  %s" % [tr(upgrade.description), tr("META_RANK") % [rank, upgrade.max_rank]], buy)


func _unlock_row(character: CharacterDef) -> Control:
	var buy := UiTheme.button(tr("META_BUY") % character.unlock_cost, func() -> void:
		Save.unlock(character)
		app.show_screen(MetaScreen.new()))
	buy.disabled = Save.soul_dust() < character.unlock_cost
	return _row(tr(character.display_name), tr(character.description), buy)


func _row(title: String, detail: String, action: Button) -> Control:
	var panel := PanelContainer.new()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	panel.add_child(row)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_child(UiTheme.label(title, 30, UiTheme.TEXT, true))
	text.add_child(UiTheme.label(detail, 22, UiTheme.MUTED))
	row.add_child(text)
	action.custom_minimum_size.x = 230
	row.add_child(action)
	return panel
