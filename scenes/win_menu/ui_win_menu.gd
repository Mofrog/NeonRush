extends Control

onready var about_map = $C/C/About/C/Map
onready var about_replay = $C/C/About/C/Replay

onready var score = $C/C/Replay/Stat/C/Score
onready var acc = $C/C/Replay/Stat/C/Acc
onready var time = $C/C/Replay/Stat/C/Time
onready var jumps = $C/C/Replay/Stat/C/Jumps
onready var perfect = $C/C/Replay/Stat/C/Pefect
onready var good = $C/C/Replay/Stat/C/Good
onready var bad = $C/C/Replay/Stat/C/Bad
onready var miss = $C/C/Replay/Stat/C/Miss

onready var grade = $C/C/Replay/Grade/Label
onready var about_grade = $C/C/Replay/Grade/About
onready var btn_restart = $C/C/Actions/C/BtnRestart

onready var test_label = $TestMode


# Exit to:
#	ui_editor
#	ui_map_select


# Global var's
var result_id = ProjectSettings.get_setting("global/result_id")
var play_map_id = ProjectSettings.get_setting("global/play_map_id")
var is_test_mode = ProjectSettings.get_setting("global/is_test_mode")

var level_game = null


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	if is_test_mode: test_label.visible = true
	if level_game == null: btn_restart.disabled = true
	
	var result = SaveLoadManager.load_result(result_id)
	var map = SaveLoadManager.load_map_header(play_map_id)
	
	var t_m = GameMath.calc_time_mult(result["Time"], map["PerfectTime"])
	var j_m = GameMath.calc_jumps_mult(result["Jumps"], map["JumpsCount"])
	var a_m = GameMath.calc_acc_mult(result["Accuracy"])
	var s_m = GameMath.get_score_mult(t_m, j_m, a_m)
	
	# About labels
	about_map.text = about_map.text.format({
		"Name" : map["Name"], 
		"Creator" : map["Creator"],
		"Song" : map["Song"].get_file().get_basename(),
		"Artist" : map["Artist"]
	})
	about_replay.text = about_replay.text.format({
		"Player" : "local",
		"DateTime" : result["DateTime"]
	})
	
	# Replay stat labels
	score.text = score.text.format({
		"All" : stepify(result["Score"], 1),
		"Multiplier" : stepify(s_m, 0.01)
	})
	acc.text = acc.text.format({
		"Accuracy" : stepify(result["Accuracy"], 0.1),
		"Multiplier" : stepify(a_m, 0.01)
	})
	time.text = time.text.format({
		"Current" : stepify(result["Time"], 0.1),
		"Perfect" : map["PerfectTime"],
		"Multiplier" : stepify(t_m, 0.01)
	})
	jumps.text = jumps.text.format({
		"Count" : result["Jumps"],
		"Perfect" : map["JumpsCount"],
		"Multiplier" : stepify(j_m, 0.01)
	})
	perfect.text = perfect.text.format({
		"Count" : result["Perfect"]
	})
	good.text = good.text.format({
		"Count" : result["Good"]
	})
	bad.text = bad.text.format({
		"Count" : result["Bad"]
	})
	miss.text = miss.text.format({
		"Count" : result["Miss"]
	})
	
	var g = GameMath.get_grade(s_m)
	grade.text = g["Grade"]
	about_grade.text = g["Info"]


func _on_BtnRestart_pressed(): 
	get_tree().paused = false
	level_game.restart()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_parent().remove_child(self)
	queue_free()


func _on_BtnExit_pressed():
	get_tree().paused = false
	if level_game == null:
		get_parent().remove_child(self)
		queue_free()
		return
	if is_test_mode:
		if get_tree().change_scene("res://scenes/level_editor/ui_editor.tscn") != OK: 
			printerr("Scene change error / ui_win_menu to ui_editor")
	else:
		if get_tree().change_scene("res://scenes/map_select_menu/ui_map_select.tscn") != OK: 
			printerr("Scene change error / ui_win_menu to ui_map_select")
