class_name CreatureMaterial
extends RefCounted

const SHADER := preload("res://assets/shaders/creature.gdshader")


static func create(look: CreatureLook) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	material.set_shader_parameter("body_color", look.body_color)
	material.set_shader_parameter("dark_color", look.dark_color)
	material.set_shader_parameter("accent_color", look.accent_color)
	material.set_shader_parameter("lobes", float(look.lobes))
	material.set_shader_parameter("lobe_amount", look.lobe_amount)
	material.set_shader_parameter("spikes", float(look.spikes))
	material.set_shader_parameter("spike_length", look.spike_length)
	material.set_shader_parameter("eyes", float(look.eyes))
	material.set_shader_parameter("organelles", look.organelles)
	material.set_shader_parameter("wobble_speed", look.wobble_speed)
	return material
