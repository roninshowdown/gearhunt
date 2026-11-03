class_name CharacterDef
extends ContentDef

enum Headgear { HELMET, HOOD, MASK }

@export var unlock_cost: int = 0
@export var base_stats: Dictionary = {}
@export var starting_weapon: WeaponDef
@export_group("Visual")
@export var look: CreatureLook
@export var headgear: Headgear = Headgear.HELMET
@export var headgear_color: Color = Color.WHITE
