class_name CreaturePreview
extends Control
## Shows a hero with its starting weapon inside a UI layout.

var _hero: HeroVisual


func _init() -> void:
	custom_minimum_size = Vector2(240, 220)


func show_character(character: CharacterDef) -> void:
	if _hero != null:
		_hero.queue_free()
	_hero = HeroVisual.new()
	_hero.setup(character, 0.1)
	_hero.scale = Vector2(1.55, 1.55)
	_hero.position = custom_minimum_size * 0.5
	_hero.weapon_visuals = [character.starting_weapon]
	_hero.mounts = PackedVector2Array([Vector2(46, 0)])
	add_child(_hero)
