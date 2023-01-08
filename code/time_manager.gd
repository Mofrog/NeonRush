extends Spatial
class_name TimeManager

signal timeout
signal beat

export(int, 0, 500) var bpm = 120

var bpm_delta : float = 1000 / (bpm / 60)
var counted_delta = 0
var general_delay = 0

var time = 0.0
var max_time = 100.0
var is_start = false
var is_inverse = false
var audio = AudioStreamPlayer.new()

var is_beat_sound_enabled = false
var beat_sound = AudioStreamPlayer.new()
var beat_delay = 0
var counted_bpm_delay = 0


func _ready(): 
	add_child(audio)
	add_child(beat_sound)
	beat_sound.volume_db = 2
	beat_sound.stream = load("res://art/sfx/metro-high.wav")


# TODO Add beat dependence from time
func _physics_process(delta):
	if is_start:
		if is_inverse:
			time -= delta
			if time < 0.0: to_point(0.0)
		else:
			time += delta
			counted_delta += delta
			counted_bpm_delay += delta
			
			# play beat sound every beat with delay
			if counted_bpm_delay > bpm_delta / 1000 && is_beat_sound_enabled:
				beat_sound.play()
				counted_bpm_delay = 0
			
			# emit every beat
			if counted_delta > bpm_delta / 1000:
				emit_signal("beat")
				counted_delta = 0
			
			# emit timeout
			if time > max_time:
				to_point(max_time)
				emit_signal("timeout")


func set_general_delay(delay):
	general_delay = delay
	counted_bpm_delay = beat_delay - general_delay
	counted_delta = -general_delay


func set_bpm(new_bpm):
	bpm = new_bpm
	bpm_delta = 1000 / (bpm / 60)
	is_beat_sound_enabled = true


func calc_delay(bs, td): 
	var speed = 100 + (70 * (bs + 0.01 / 10))
	var distance = (600 / (td + 6)) - (300 / (td + 6)) - 175.5
	beat_delay = distance / speed
	counted_bpm_delay = beat_delay
	is_beat_sound_enabled = true
	return beat_delay


func to_point(point):
	time = point
	stop(true)


func start(stream = null):
	if stream != null: audio.stream = stream
	if audio.stream != null: audio.play(time)
	is_start = true
	is_inverse = false


func stop(restart = false):
	if restart: 
		time = 0
		counted_delta = -general_delay
		counted_bpm_delay = beat_delay - general_delay
	audio.stop()
	beat_sound.stop()
	is_start = false


func inverse():
	is_start = true
	is_inverse = true
