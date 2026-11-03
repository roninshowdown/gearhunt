class_name PlayerIntent
extends RefCounted
## What a player wants to do this tick. The only gameplay input the simulation
## receives, whether it came from a keyboard, a controller or the network.

var move := Vector2.ZERO
var aim := Vector2.RIGHT
var attacking := false


func sanitized() -> PlayerIntent:
	var clean := PlayerIntent.new()
	clean.move = move.limit_length(1.0)
	clean.aim = aim.normalized() if aim.length_squared() > 0.0001 else Vector2.RIGHT
	clean.attacking = attacking
	return clean
