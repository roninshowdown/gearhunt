class_name CreatureLook
extends Resource
## Parameters of the procedural creature shader (assets/shaders/creature.gdshader).

@export var body_color: Color = Color(0.5, 0.8, 0.6)
@export var dark_color: Color = Color(0.1, 0.25, 0.2)
@export var accent_color: Color = Color(1.0, 0.9, 0.5)
@export_range(2, 12) var lobes: int = 5
@export_range(0.0, 0.3) var lobe_amount: float = 0.06
@export_range(0, 24) var spikes: int = 0
@export_range(0.0, 0.5) var spike_length: float = 0.0
@export_range(0, 3) var eyes: int = 2
@export_range(0.0, 1.0) var organelles: float = 0.5
@export_range(0.2, 6.0) var wobble_speed: float = 2.0
