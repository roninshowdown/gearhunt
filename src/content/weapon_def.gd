class_name WeaponDef
extends ContentDef

enum Visual { SWORD, AXE, BOW, CROSSBOW, STAFF }

@export var price: int = 20
@export var damage: float = 8.0
@export var cooldown: float = 0.8 ## Seconds between attacks at 0 % attack speed.
@export var attack: AttackPattern
@export var visual: Visual = Visual.SWORD
@export var color: Color = Color(0.85, 0.9, 1.0)
