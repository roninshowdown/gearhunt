class_name StatSystem
extends RefCounted


static func recompute(p: PlayerState) -> void:
	var previous_max := p.max_hp() if not p.stats.is_empty() else 0.0
	var stats: Dictionary = Stats.BASE.duplicate()
	_add(stats, Content.character(p.character_id).base_stats)
	_add(stats, p.meta_stats)
	for item_id in p.items:
		_add(stats, Content.item(item_id).stats)
	p.stats = stats
	if previous_max > 0.0:
		p.hp = clampf(p.hp + maxf(0.0, p.max_hp() - previous_max), 0.0, p.max_hp())


static func _add(target: Dictionary, source: Dictionary) -> void:
	for key: String in source:
		target[key] = float(target.get(key, 0.0)) + float(source[key])
