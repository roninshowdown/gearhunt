class_name EntityBatch
extends MultiMeshInstance2D
## Draws many instances of one quad with one material in a single draw call.

var _count := 0


func _init(capacity: int, shader_material: Material, with_custom_data: bool = true) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_2D
	batch.use_colors = true
	batch.use_custom_data = with_custom_data
	batch.mesh = quad
	batch.instance_count = capacity
	batch.visible_instance_count = 0
	multimesh = batch
	material = shader_material
	# Instances span the arena; never let Godot cull the whole batch.
	multimesh.custom_aabb = AABB(Vector3(-8000, -8000, -1), Vector3(16000, 16000, 2))


func begin() -> void:
	_count = 0


func add(xform: Transform2D, color: Color = Color.WHITE, custom: Color = Color(0, 0, 0, 0)) -> void:
	if _count >= multimesh.instance_count:
		return
	multimesh.set_instance_transform_2d(_count, xform)
	multimesh.set_instance_color(_count, color)
	if multimesh.use_custom_data:
		multimesh.set_instance_custom_data(_count, custom)
	_count += 1


func finish() -> void:
	multimesh.visible_instance_count = _count
