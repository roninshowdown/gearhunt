extends Node
## Autoload `Sfx`. Placeholder sound effects synthesised at start-up so the game
## has feedback before real audio exists. Replace by loading AudioStreams here.

enum Sound { SHOT, SWING, HIT, DEATH, PICKUP, HURT, EXPLOSION, BUY }

const VOICES := 12
const MIX_RATE := 22050

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	_streams[Sound.SHOT] = _tone(0.09, 880.0, 320.0, 0.15)
	_streams[Sound.SWING] = _tone(0.11, 240.0, 120.0, 0.65)
	_streams[Sound.HIT] = _tone(0.06, 420.0, 180.0, 0.4)
	_streams[Sound.DEATH] = _tone(0.16, 260.0, 60.0, 0.5)
	_streams[Sound.PICKUP] = _tone(0.07, 900.0, 1500.0, 0.0)
	_streams[Sound.HURT] = _tone(0.2, 200.0, 70.0, 0.7)
	_streams[Sound.EXPLOSION] = _tone(0.3, 140.0, 40.0, 0.9)
	_streams[Sound.BUY] = _tone(0.14, 520.0, 1040.0, 0.0)
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)


func play(sound: Sound, volume_db: float = -8.0) -> void:
	var player := _players[_next]
	_next = (_next + 1) % VOICES
	player.stream = _streams[sound]
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.92, 1.08)
	player.play()


func _tone(duration: float, from_hz: float, to_hz: float, noise: float) -> AudioStreamWAV:
	var count := int(duration * MIX_RATE)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase := 0.0
	for i in count:
		var t := float(i) / count
		phase += lerpf(from_hz, to_hz, t) / MIX_RATE
		var sample := lerpf(sin(phase * TAU), randf_range(-1.0, 1.0), noise) * pow(1.0 - t, 2.0)
		bytes.encode_s16(i * 2, int(sample * 24000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.data = bytes
	return stream
