extends Node3D


@onready var l_time = $C/C/C/Time
@onready var l_jumps = $C/C/C/Jumps
@onready var l_acc = $C/C/C/Acc
@onready var time_text = l_time.text
@onready var jumps_text = l_jumps.text
@onready var acc_text = l_acc.text

@onready var c_test_mode = $C/TestMode
@onready var rytm_rule = $C/RytmRule

@onready var chunks = $Chunks
@onready var character = $Character
@onready var menu = $Menu


# Go to:
#	ui_editor
#	ui_map_select


# Global var's
var is_test_mode = ProjectSettings.get_setting("global/is_test_mode")
var chunk_size = ProjectSettings.get_setting("config/chunk_size")
var play_map_id = ProjectSettings.get_setting("global/play_map_id")
# Setting "global/result_id"


var chunk_thread = Thread.new()
var last_character_position = Vector3()

var record_count = 0
var results : Dictionary = {
	"Score" : 0.0,
	"Time" : 0.0,
	"Accuracy" : 0.0,
	"Perfect" : 0,
	"Good" : 0,
	"Bad" : 0,
	"Miss" : 0,
	"Positions" : [],
	"Rotations" : [],
	"Jumps" : 0,
	"DateTime" : ""
}
var map_data = null
var audio_stream = null


#------------------------------------READY_EXIT FUNC'S--------------------------
func _ready(): 
	load_map()
	if is_test_mode: c_test_mode.visible = true


func _exit_tree():
	if chunk_thread.is_active() && !chunk_thread.is_alive(): chunk_thread.wait_to_finish()


#------------------------------------PROCESS FUNC'S-----------------------------
func _process(_delta):
	update_character_position()
	update_ui()
	
	if Input.is_action_just_pressed("game_menu"):
		menu.visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		rytm_rule.stop()
	
	if Input.is_action_just_pressed("game_restart"): restart()
	
	if Input.is_action_just_pressed("game_jump") && character.is_game_start: 
			var result = rytm_rule.click()
			results["Score"] += result
			match result:
				300: results["Perfect"] += 1
				100: results["Good"] += 1
				50: results["Bad"] += 1
				0: results["Miss"] += 1
			results["Accuracy"] = GameMath.calc_acc(results)
			results["Jumps"] += 1
			if result != 0:
				character.jump()


func _physics_process(_delta):
	# Save character position every 0.05 sec
	if character.is_game_start:
		if record_count == 0: 
			results["Positions"].append(character.position)
			results["Rotations"].append(character.camera.rotation)
		record_count += 1
		if record_count == 3: record_count = 0


# Update chunks visibility every walked chunk
func update_character_position():
	if last_character_position == null:
		last_character_position = character.position
	if last_character_position.distance_to(character.position) >= chunk_size.x:
		last_character_position = character.position
		if chunk_thread.is_active(): chunk_thread.wait_to_finish()
		chunk_thread.start(Callable(chunks,"update_chunks_visibility").bind(character))


func update_ui():
	l_time.text = time_text.format({
		"Min" : str(floor(rytm_rule.time_manager.time / 60)),
		"Sec" : str(floor(fmod(rytm_rule.time_manager.time, 60))),
		"Ssec" : str(snapped(fmod(rytm_rule.time_manager.time, 1) * 100, 1))
	}) 
	l_jumps.text = jumps_text.format({
		"Jumps" : str(results["Jumps"])
	})
	l_acc.text = acc_text.format({
		"Acc" : str(snapped(results["Accuracy"], 0.01))
	})


#----------------------------------FUNC'S---------------------------------------
# Restart map
func restart():
	# Restart character
	character.restart()
	rytm_rule.stop(true)
	
	# Restart map
	if character.is_game_start: add_child(StartEnd.new())
	character.is_game_start = false
	if chunk_thread.is_active(): chunk_thread.wait_to_finish()
	chunks.update_chunks_visibility(character)
	
	# Restart results
	results = {
	"Score" : 0.0,
	"Time" : 0.0,
	"Accuracy" : 0.0,
	"Perfect" : 0,
	"Good" : 0,
	"Bad" : 0,
	"Miss" : 0,
	"Positions" : [],
	"Rotations" : [],
	"Jumps" : 0
	}


# Onready loading of the map
func load_map():
	if play_map_id == -1: 
		if is_test_mode:
			if get_tree().change_scene_to_file("res://scenes/level_editor/ui_editor.tscn") != 0: 
				printerr("Scene change error / level_game to ui_editor")
		else:
			if get_tree().change_scene_to_file("res://scenes/map_select_menu/ui_map_select.tscn") != 0: 
				printerr("Scene change error / level_game to ui_map_select")
	map_data = SaveLoadManager.load_map_header(play_map_id)
	var data = SaveLoadManager.load_map_data(map_data["Name"])
	if !data.has("Chunks"): return
	chunks.delete_all_chunks()
	chunks.chunks = data["Chunks"]
	chunks.update_chunks_visibility(character)
	add_child(StartEnd.new())
	
	# Load song
	var path = OS.get_executable_path().get_base_dir() + "/maps/" + data["Name"] + "/" + data["Song"].get_file()
	var song_data : AudioStream = AudioLoader.loadfile(path)
	audio_stream = song_data
	rytm_rule.init_manager(data["End"], data["Delay"], data["BPM"], data["BS"], data["TD"])


func save_results(): 
	var score = results["Score"]
	var t_m = GameMath.calc_time_mult(rytm_rule.time_manager.time, map_data["PerfectTime"])
	var j_m = GameMath.calc_jumps_mult(results["Jumps"], map_data["JumpsCount"])
	var a_m = GameMath.calc_acc_mult(results["Accuracy"])
	var data = {
		"IdMap" : play_map_id,
		"Score" : GameMath.calc_score(score, t_m, j_m, a_m),
		"Accuracy" : results["Accuracy"],
		"Perfect" : results["Perfect"],
		"Good" : results["Good"],
		"Bad" : results["Bad"],
		"Miss" : results["Miss"],
		"Positions" : JSON.stringify(results["Positions"]),
		"Rotations" : JSON.stringify(results["Rotations"]),
		"Jumps" : results["Jumps"],
		"Time" : rytm_rule.time_manager.time,
		"DateTime" : Time.get_datetime_string_from_system()
	}
	var result_id = SaveLoadManager.save_result(data)
	if result_id != -1: ProjectSettings.set_setting("global/result_id", result_id)


#----------------------------------SIGNALS--------------------------------------
# Exit menu
func _on_BtnContinue_pressed():
	menu.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if character.is_game_start: rytm_rule.start()


# Exit level
func _on_BtnExit_pressed(): 
	if is_test_mode:
		save_results()
		if get_tree().change_scene_to_file("res://scenes/level_editor/ui_editor.tscn") != 0: 
			printerr("Scene change error / level_game to ui_editor")
	else:
		if get_tree().change_scene_to_file("res://scenes/map_select_menu/ui_map_select.tscn") != 0: 
			printerr("Scene change error / level_game to ui_map_select")
	get_tree().paused = false


func _on_RytmRule_timeout(): restart()


func _on_Character_area_entered(area):
	if area is StartEnd:
		# End game
		if area.is_end:
			save_results()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			var item = load("res://scenes/win_menu/ui_win_menu.tscn").instantiate()
			item.level_game = self
			add_child(item)
		else:
		# Start game
			rytm_rule.start(audio_stream)
			character.is_game_start = true
			area.free()


func _on_BtnHelp_pressed():
	PopUp.new().accept_dialog("Help", "Movement: WASD\nJump: Space / Left Mouse\nRestart: F", self, true)
