class_name MenuBackdrop
extends ColorRect
## Animated biome floor behind the menus.

const SHADER := preload("res://assets/shaders/biome_water.gdshader")


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var biome: BiomeDef = Content.biome("sunken_deep")
	var shader_material := ShaderMaterial.new()
	shader_material.shader = SHADER
	shader_material.set_shader_parameter("color_a", biome.color_a)
	shader_material.set_shader_parameter("color_b", biome.color_b)
	shader_material.set_shader_parameter("color_c", biome.color_c)
	shader_material.set_shader_parameter("arena_half", Vector2(5000, 5000))
	shader_material.set_shader_parameter("world_origin", Vector2(-960, -540))
	shader_material.set_shader_parameter("world_size", Vector2(1920, 1080))
	material = shader_material
