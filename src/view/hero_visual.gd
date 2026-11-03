class_name HeroVisual
extends Node2D
## A hero's body, headgear and weapons. Also used for lobby previews, so it
## knows nothing about the simulation.

const BODY_RADIUS := PlayerSystem.BODY_RADIUS * 1.25
const WEAPON_SHAPES := {
	WeaponDef.Visual.SWORD: [Vector2(-12, -4), Vector2(8, -6), Vector2(46, -3), Vector2(58, 0), Vector2(46, 3), Vector2(8, 6), Vector2(-12, 4)],
	WeaponDef.Visual.AXE: [Vector2(-14, -3), Vector2(34, -3), Vector2(30, -24), Vector2(54, -18), Vector2(60, 0), Vector2(54, 18), Vector2(30, 24), Vector2(34, 3), Vector2(-14, 3)],
	WeaponDef.Visual.CROSSBOW: [Vector2(-16, -4), Vector2(26, -4), Vector2(26, -26), Vector2(36, -26), Vector2(36, 26), Vector2(26, 26), Vector2(26, 4), Vector2(-16, 4)],
	WeaponDef.Visual.STAFF: [Vector2(-22, -3), Vector2(44, -3), Vector2(50, -9), Vector2(60, 0), Vector2(50, 9), Vector2(44, 3), Vector2(-22, 3)],
}

var character: CharacterDef
var body: MeshInstance2D
var weapon_visuals: Array[WeaponDef] = []
var mounts: PackedVector2Array = []
var aim_angle := 0.0
var swing := 0.0
var flash := 0.0
var down := false

var _material: ShaderMaterial
var _headgear: Node2D


func setup(p_character: CharacterDef, phase: float = 0.0) -> void:
	character = p_character
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * (BODY_RADIUS * 2.0 / 0.62)
	body = MeshInstance2D.new()
	body.mesh = quad
	_material = CreatureMaterial.create(character.look)
	_material.set_shader_parameter("phase_override", phase)
	body.material = _material
	add_child(body)
	_headgear = Node2D.new()
	_headgear.draw.connect(_draw_headgear)
	add_child(_headgear)


func _process(_delta: float) -> void:
	body.rotation = aim_angle
	_headgear.rotation = aim_angle
	_material.set_shader_parameter("flash_override", flash)
	modulate.a = 0.35 if down else 1.0
	queue_redraw()


func _draw() -> void:
	for i in weapon_visuals.size():
		var weapon := weapon_visuals[i]
		var mount: Vector2 = mounts[i] if i < mounts.size() else Vector2.ZERO
		var angle := aim_angle
		var is_melee := weapon.attack is MeleeArcAttack
		if is_melee:
			angle += sin(swing * PI) * 2.2 - 1.1 * swing
		draw_set_transform(mount, angle)
		if weapon.visual == WeaponDef.Visual.BOW:
			_draw_bow(weapon)
		else:
			_draw_shape(WEAPON_SHAPES[weapon.visual], weapon.color)
	draw_set_transform(Vector2.ZERO)


func _draw_shape(points: Array, color: Color) -> void:
	var shape := PackedVector2Array(points)
	draw_colored_polygon(shape, color)
	var outline := shape.duplicate()
	outline.append(shape[0])
	draw_polyline(outline, Color(0.05, 0.05, 0.1), 3.5, true)
	draw_line(shape[0], shape[0] + Vector2(10, 0), Color(0.45, 0.28, 0.16), 7.0, true)


func _draw_bow(weapon: WeaponDef) -> void:
	var arc := PackedVector2Array()
	for i in 13:
		var a := lerpf(-1.25, 1.25, i / 12.0)
		arc.append(Vector2(cos(a) * 34.0 - 8.0, sin(a) * 40.0))
	draw_polyline(arc, Color(0.05, 0.05, 0.1), 9.0, true)
	draw_polyline(arc, weapon.color, 5.0, true)
	draw_line(arc[0], arc[12], Color(0.95, 0.95, 0.9), 2.0, true)


func _draw_headgear() -> void:
	var color := character.headgear_color
	var dark := color.darkened(0.55)
	match character.headgear:
		CharacterDef.Headgear.HELMET:
			var crest := PackedVector2Array([Vector2(-44, -9), Vector2(-6, -11), Vector2(4, 0), Vector2(-6, 11), Vector2(-44, 9), Vector2(-54, 0)])
			_headgear.draw_colored_polygon(crest, color)
			_headgear.draw_polyline(_closed(crest), dark, 3.5, true)
			_headgear.draw_line(Vector2(-46, 0), Vector2(-2, 0), Color(0.95, 0.3, 0.2), 6.0, true)
			for side: float in [-1.0, 1.0]:
				var horn := PackedVector2Array([Vector2(-12, 25 * side), Vector2(4, 28 * side), Vector2(-16, 56 * side)])
				_headgear.draw_colored_polygon(horn, Color(0.95, 0.9, 0.78))
				_headgear.draw_polyline(_closed(horn), dark, 3.0, true)
		CharacterDef.Headgear.HOOD:
			var hood := PackedVector2Array([Vector2(-66, 0), Vector2(-24, -33), Vector2(-6, -30), Vector2(-2, -22), Vector2(-20, 0), Vector2(-2, 22), Vector2(-6, 30), Vector2(-24, 33)])
			_headgear.draw_colored_polygon(hood, color)
			_headgear.draw_polyline(_closed(hood), dark, 3.5, true)
			var feather := PackedVector2Array([Vector2(-22, -26), Vector2(-62, -46), Vector2(-48, -24)])
			_headgear.draw_colored_polygon(feather, Color(0.95, 0.75, 0.3))
		CharacterDef.Headgear.MASK:
			_headgear.draw_circle(Vector2(8, 0), 18.0, color)


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var result := points.duplicate()
	result.append(points[0])
	return result
