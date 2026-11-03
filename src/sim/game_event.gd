class_name GameEvent
extends RefCounted
## One-shot, cosmetic notification from the simulation to the view and audio.
## Events may be lost on the network, so game logic must never depend on them.

enum Type { HIT, DEATH, SHOT, MELEE, PICKUP, PLAYER_HURT, PLAYER_DOWN, TELEGRAPH, EXPLOSION, WAVE_START }

var type: Type
var pos: Vector2
var target: int ## Entity id the event refers to.
var a: float
var b: float
var c: float


static func make(p_type: Type, p_pos: Vector2, p_target: int = 0, p_a: float = 0.0, p_b: float = 0.0, p_c: float = 0.0) -> GameEvent:
	var e := GameEvent.new()
	e.type = p_type
	e.pos = p_pos
	e.target = p_target
	e.a = p_a
	e.b = p_b
	e.c = p_c
	return e
