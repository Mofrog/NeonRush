extends Node

enum TIME_STATE { TO_START, REVERSE, STOP, PLAY, TO_END }
var time_state : TIME_STATE = TIME_STATE.STOP
var time = 0.0
var max_time = 197.62

var audio = AudioStreamPlayer.new()


func _init():
	add_child(audio)


func _physics_process(delta):
	match time_state:
		TIME_STATE.TO_START:
			time = 0.0
			if audio.playing && audio.stream != null: audio.stop()
		TIME_STATE.REVERSE:
			time -= delta * 1
			if time < 0: time = max_time
			if audio.playing && audio.stream != null: audio.stop()
		TIME_STATE.STOP:
			if audio.playing && audio.stream != null: audio.stop()
		TIME_STATE.PLAY:
			time += delta * 1
			if time > max_time: time = 0
			if !audio.playing && audio.stream != null: audio.play(time)
		TIME_STATE.TO_END:
			time = max_time
			if audio.playing && audio.stream != null: audio.stop()


func replay_song():
	if audio.playing && audio.stream != null: audio.play(time)
