extends Node
## Autoload `Inputs`. Translates physical devices into PlayerIntents. Each
## controller is read by device id, which is what makes local co-op work.

const STICK_DEADZONE := 0.22
const TRIGGER_THRESHOLD := 0.35

const KEY_BINDINGS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
}


func _enter_tree() -> void:
	for action: String in KEY_BINDINGS:
		InputMap.add_action(action)
		for key: int in KEY_BINDINGS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key as Key
			InputMap.action_add_event(action, event)
	InputMap.add_action("attack")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("attack", click)


## `screen_to_world` converts a viewport position, needed for mouse aiming.
func read_intent(slot: LocalSlot, player_pos: Vector2, mouse_world: Vector2) -> PlayerIntent:
	if slot.device == LocalSlot.KEYBOARD:
		return _read_keyboard(slot, player_pos, mouse_world)
	return _read_controller(slot)


func _read_keyboard(slot: LocalSlot, player_pos: Vector2, mouse_world: Vector2) -> PlayerIntent:
	var intent := PlayerIntent.new()
	intent.move = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var to_mouse := mouse_world - player_pos
	if to_mouse.length_squared() > 16.0:
		slot.last_aim = to_mouse.normalized()
	intent.aim = slot.last_aim
	intent.attacking = Input.is_action_pressed("attack")
	return intent


func _read_controller(slot: LocalSlot) -> PlayerIntent:
	var device := slot.device
	var intent := PlayerIntent.new()
	intent.move = _stick(device, JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	var aim := _stick(device, JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
	if aim != Vector2.ZERO:
		slot.last_aim = aim.normalized()
	elif intent.move != Vector2.ZERO:
		slot.last_aim = intent.move.normalized()
	intent.aim = slot.last_aim
	intent.attacking = Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > TRIGGER_THRESHOLD \
		or Input.is_joy_button_pressed(device, JOY_BUTTON_RIGHT_SHOULDER)
	return intent


func _stick(device: int, axis_x: JoyAxis, axis_y: JoyAxis) -> Vector2:
	var value := Vector2(Input.get_joy_axis(device, axis_x), Input.get_joy_axis(device, axis_y))
	if value.length() < STICK_DEADZONE:
		return Vector2.ZERO
	return value.limit_length(1.0)
