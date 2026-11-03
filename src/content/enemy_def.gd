class_name EnemyDef
extends ContentDef

@export var max_hp: float = 6.0
@export var speed: float = 150.0
@export var contact_damage: float = 2.0
@export var radius: float = 26.0
@export var material_drop: int = 1
@export var behavior: EnemyBehavior
@export var is_boss: bool = false
@export var look: CreatureLook
