class_name BiomeDef
extends ContentDef
## A playable map: enemy roster, boss and background.

enum Ambient { BUBBLES, EMBERS, SPORES }

@export var spawns: Array[SpawnEntry] = []
@export var boss: EnemyDef
@export var background_shader: Shader
@export var ambient: Ambient = Ambient.BUBBLES
@export var color_a: Color = Color.BLACK
@export var color_b: Color = Color.BLACK
@export var color_c: Color = Color.WHITE
@export var splat_tint: Color = Color(0.3, 0.8, 0.9)
