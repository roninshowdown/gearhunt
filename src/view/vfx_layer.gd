class_name VfxLayer
extends Node2D
## Short-lived effects: particles, slashes, shockwaves, damage numbers.

const MAX_PARTICLES := 900
const GLOW := preload("res://assets/shaders/glow.gdshader")

var font: Font

var _batch: EntityBatch
var _pos := PackedVector2Array()
var _vel := PackedVector2Array()
var _life := PackedFloat32Array()
var _max_life := PackedFloat32Array()
var _size := PackedFloat32Array()
var _colors := PackedColorArray()
var _used := 0
var _slashes: Array[Dictionary] = []
var _rings: Array[Dictionary] = []
var _numbers: Array[Dictionary] = []


func _ready() -> void:
	var material_glow := ShaderMaterial.new()
	material_glow.shader = GLOW
	_batch = EntityBatch.new(MAX_PARTICLES, material_glow, false)
	add_child(_batch)
	for array: Variant in [_pos, _vel]:
		array.resize(MAX_PARTICLES)
	_pos.resize(MAX_PARTICLES)
	_vel.resize(MAX_PARTICLES)
	_life.resize(MAX_PARTICLES)
	_max_life.resize(MAX_PARTICLES)
	_size.resize(MAX_PARTICLES)
	_colors.resize(MAX_PARTICLES)


func burst(pos: Vector2, color: Color, count: int, speed: float, size: float, life: float = 0.5) -> void:
	for _i in count:
		if _used >= MAX_PARTICLES:
			return
		var i := _used
		_pos[i] = pos
		_vel[i] = Vector2.from_angle(randf() * TAU) * randf_range(speed * 0.25, speed)
		_max_life[i] = randf_range(life * 0.5, life)
		_life[i] = _max_life[i]
		_size[i] = randf_range(size * 0.5, size)
		_colors[i] = color
		_used += 1


func slash(pos: Vector2, angle: float, reach: float, arc_degrees: float, color: Color) -> void:
	_slashes.append({"pos": pos, "angle": angle, "reach": reach, "arc": deg_to_rad(arc_degrees), "t": 0.0, "color": color})


func ring(pos: Vector2, radius: float, color: Color) -> void:
	_rings.append({"pos": pos, "radius": radius, "t": 0.0, "color": color})


func number(pos: Vector2, value: int, color: Color) -> void:
	if _numbers.size() < 80:
		_numbers.append({"pos": pos + Vector2(randf_range(-18, 18), -24), "text": str(value), "t": 0.0, "color": color})


func _process(delta: float) -> void:
	_step_particles(delta)
	_slashes = _advance(_slashes, delta / 0.16)
	_rings = _advance(_rings, delta / 0.34)
	_numbers = _advance(_numbers, delta / 0.65)
	queue_redraw()


func _step_particles(delta: float) -> void:
	_batch.begin()
	var i := 0
	while i < _used:
		_life[i] -= delta
		if _life[i] <= 0.0:
			_used -= 1
			_pos[i] = _pos[_used]
			_vel[i] = _vel[_used]
			_life[i] = _life[_used]
			_max_life[i] = _max_life[_used]
			_size[i] = _size[_used]
			_colors[i] = _colors[_used]
			continue
		_vel[i] *= 1.0 - minf(4.0 * delta, 1.0)
		_pos[i] += _vel[i] * delta
		var fade := _life[i] / _max_life[i]
		var size := _size[i] * (0.5 + 0.5 * fade)
		var color := _colors[i]
		color.a = fade
		_batch.add(Transform2D(0.0, Vector2(size, size), 0.0, _pos[i]), color)
		i += 1
	_batch.finish()


func _advance(list: Array[Dictionary], step: float) -> Array[Dictionary]:
	var kept: Array[Dictionary] = []
	for entry in list:
		entry["t"] = float(entry["t"]) + step
		if entry["t"] < 1.0:
			kept.append(entry)
	return kept


func _draw() -> void:
	for s in _slashes:
		_draw_slash(s)
	for r in _rings:
		var t: float = r["t"]
		var color: Color = r["color"]
		color.a = 1.0 - t
		draw_arc(r["pos"], float(r["radius"]) * (0.3 + 0.7 * t), 0.0, TAU, 48, color, 10.0 * (1.0 - t) + 1.0, true)
	if font == null:
		return
	for n in _numbers:
		var t: float = n["t"]
		var color: Color = n["color"]
		color.a = 1.0 - t * t
		var pos: Vector2 = n["pos"] + Vector2(0, -46.0 * t)
		draw_string_outline(font, pos, n["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 30, 8, Color(0.03, 0.03, 0.07, color.a))
		draw_string(font, pos, n["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 30, color)


func _draw_slash(s: Dictionary) -> void:
	var t: float = s["t"]
	var color: Color = s["color"]
	var angle: float = s["angle"]
	var half: float = float(s["arc"]) * 0.5
	var reach: float = s["reach"]
	var points := PackedVector2Array()
	var steps := 16
	var sweep := lerpf(-half, half, minf(t * 1.6, 1.0))
	for i in steps + 1:
		var a := angle + lerpf(-half, sweep, float(i) / steps)
		points.append(s["pos"] + Vector2.from_angle(a) * reach)
	for i in range(steps, -1, -1):
		var a := angle + lerpf(-half, sweep, float(i) / steps)
		var inner := reach * (0.86 - 0.22 * sin(float(i) / steps * PI))
		points.append(s["pos"] + Vector2.from_angle(a) * inner)
	color.a = 0.85 * (1.0 - t)
	if points.size() >= 3:
		draw_colored_polygon(points, color)
