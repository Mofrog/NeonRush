extends AcceptDialog

onready var open_song_p = $OpenSong

onready var map_name = $M/S/V/First/MapName/Name
onready var creator = $M/S/V/First/MapCreator/Name

onready var song = $M/S/V/Second/MapSong/Path
onready var song_btn = $M/S/V/Second/MapSong/BtnLoadSong
onready var artist = $M/S/V/Second/SongArtist/Name

onready var map_length = $M/S/V/Third/Lenght/MapLength
onready var song_length = $M/S/V/Third/Lenght/H/SongLength
onready var song_start = $M/S/V/Third/Lenght2/Start
onready var song_end = $M/S/V/Third/Lenght2/End
onready var cut_btn = $M/S/V/Third/Lenght2/BtnCut

onready var ui_song = $M/S/V/Second
onready var ui_length = $M/S/V/Third/Lenght/H
onready var ui_length2 = $M/S/V/Third/Lenght2

onready var bpm = $M/S/V/Third/BPM/BPM
onready var zero = $M/S/V/Third/BPM/"0"
onready var test = $M/S/V/Third/BPM/Test
var bpm_group : ButtonGroup = null

onready var diff = $M/S/V/Diff/Difficult/Diff
onready var diff_delay = $M/S/V/Diff/Difficult/DiffDelay
onready var delay = $M/S/V/Diff/Difficult/Delay

onready var bs = $M/S/V/Diff/Difficult2/BS
onready var td = $M/S/V/Diff/Difficult2/TD

onready var perfect_time = $M/S/V/Diff/Difficult3/PerfectTime
onready var jumps_count = $M/S/V/Diff/Difficult3/JumpsCount

var timeline = null

var data = {
	"Name" : "unnamed",
	"Creator" : "unknown",
	"Song" : "unknown",
	"Artist" : "unknown",
	"Length" : 0.0,
	"Start" : 0.0,
	"End" : 0.0,
	"BPM" : 1,
	"Mode" : 0,
	"Delay" : 0.0,
	"Difficult" : 0.0,
	"BS" : 0.0,
	"TD" : 0.0,
	"PerfectTime" : 0.0,
	"JumpsCount" : 0
}


var is_data_resave = false


# On open editor
func _ready(): 
	bpm_group = zero.group
	data_update(null, true)
	timeline = ProjectSettings.get_setting("global/timeline")


# Disable song data edit
func disable_edit():
	map_name.editable = false
	creator.editable = false
	artist.editable = false
	song_btn.disabled = true


# Update all text lines from data var
func data_update(new_data = null, is_init = false):
	if new_data != null: data = new_data
	
	map_name.text = str(data["Name"])
	creator.text = str(data["Creator"])
	song.text = str(data["Song"].get_file().get_basename())
	artist.text = str(data["Artist"])
	map_length.value = float(data["End"]) - float(data["Start"])
	song_length.value = float(data["Length"])
	song_start.value = float(data["Start"])
	song_end.value = float(data["End"])
	bpm.value = int(data["BPM"])
	delay.value = float(data["Delay"])
	for i in bpm_group.get_buttons():
		if int(data["Mode"]) == int(i.name): i.pressed = true
	diff.value = float(data["Difficult"])
	bs.value = float(data["BS"])
	td.value = float(data["TD"])
	perfect_time.max_value = float(data["End"])
	perfect_time.value = float(data["PerfectTime"])
	jumps_count.value = int(data["JumpsCount"])
	
	if is_init: is_data_resave = false


# Print all info about this map
func debug():
	prints("Settings set:", "\n",
		"Map name:", data["Name"], "\n",
		"Creator:", data["Creator"], "\n",
		"Song name:", data["Song"], "\n",
		"Artist:", data["Artist"], "\n",
		"Song length:", data["Length"], "\n",
		"Song start:", data["Start"], "\n",
		"Song end:", data["End"], "\n",
		"BPM:", data["BPM"], "\n",
		"Mode:", data["Mode"], "\n",
		"Delay", data["Delay"], "\n",
		"Difficult:", data["Difficult"], "\n",
		"BS:", data["BS"], "\n",
		"TD:", data["TD"], "\n", 
		"PerfectTime:", data["PerfectTime"], "\n",
		"JumpsCount:", data["JumpsCount"])


# Open pop for select the user path of song
func _on_BtnLoadSong_pressed():
	open_song_p.visible = true
	open_song_p.current_dir = OS.get_environment("HOME")


# Load song and set song vars
func _on_OpenSong_file_selected(path):
	if !path.ends_with(".ogg") && !path.ends_with(".mp3") && !path.ends_with(".wav"): 
		PopUp.new().accept_dialog("Warning!", "Incorrect file.", self, true)
		return
	
	# Get song length
	var audio_loader = AudioLoader.new()
	var song_data : AudioStream = audio_loader.loadfile(path)
	data["Song"] = path
	data["Length"] = song_data.get_length()
	data["End"] = song_data.get_length()
	
	timeline.stream = song_data
	timeline.set_max(song_data.get_length())
	
	song_start.max_value = song_data.get_length()
	song_end.max_value = song_data.get_length()
	perfect_time.max_value = song_data.get_length()
	
	data_update()


# Save new map name
func _on_Map_Name_text_changed(new_text): data["Name"] = new_text


# Save new map creator name
func _on_Creator_text_changed(new_text): data["Creator"] = new_text


# Save new song name
func _on_Path_text_changed(new_text): data["Song"] = new_text


# Save new artist name
func _on_Name_text_changed(new_text): data["Artist"] = new_text


# Save new BPM
func _on_BPM_value_changed(value): 
	data["BPM"] = value
	timeline.manager.set_bpm(value)
	is_data_resave = true


# Save new mode
func _on_Mode_pressed(): 
	data["Mode"] = int(bpm_group.get_pressed_button().name)
	is_data_resave = true


# Save new delay
func _on_Delay_value_changed(value): 
	data["Delay"] = value
	timeline.manager.set_general_delay(value)
	test.pressed = false
	is_data_resave = true


# Save new diff
func _on_Diff_value_changed(value): 
	data["Difficult"] = value
	is_data_resave = true


# Save new beat speed
func _on_BS_value_changed(value): 
	data["BS"] = value
	diff_delay.text = str(stepify(-timeline.manager.calc_delay(data["BS"], data["TD"]), 0.01))
	test.pressed = false
	is_data_resave = true


# Save new timing difficult
func _on_TD_value_changed(value): 
	data["TD"] = value
	diff_delay.text = str(stepify(-timeline.manager.calc_delay(data["BS"], data["TD"]), 0.01))
	test.pressed = false
	is_data_resave = true


# Save new perfect time
func _on_PerfectTime_value_changed(value): 
	data["PerfectTime"] = value
	is_data_resave = true


# Save new jumps count
func _on_JumpsCount_value_changed(value): 
	data["JumpsCount"] = value
	is_data_resave = true


# On close settings
func _on_Settings_hide(): 
	debug()
	get_tree().paused = false
	
	# Check unique naming
	var db = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns").new()
	db.path = "res://data/user.db"
	db.verbosity_level = 0
	db.open_db()
	db.query(str("SELECT * FROM Map WHERE Map.Name = \"", data["Name"],"\""))
	var name = db.query_result
	db.close_db()
	if name.size() > 0 && is_data_resave: 
		PopUp.new().accept_dialog("Warning!", \
		"This map already exists.\nMap will be resave.", self)


func _on_Test_toggled(button_pressed):
	if button_pressed: timeline._on_BtnStart_pressed()
	else: timeline._on_BtnToStart_pressed()
