class_name LocalSlot
extends RefCounted
## One person sitting at this PC.

const KEYBOARD := -1

var index: int
var device: int = KEYBOARD
var character_id: String = ""
var player_id: int = -1
var last_aim := Vector2.RIGHT
