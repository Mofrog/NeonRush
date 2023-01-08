extends Control

onready var map_about = $Left/V/MapAbout/G
onready var map_other = $Left/V/MapAbout/O
onready var map_about_text = map_about.text
onready var map_other_text = map_other.text

onready var audio = $Audio
onready var result_list = $Left/V/ReplayList/Root
onready var map_list = $Right/V/C2/MapList/Root
onready var debug = $Debug

var db = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns").new()


# Exit to:
#	ui_editor
#	ui_main_menu
#	level_game


# Global var's
var is_editor_map_load = ProjectSettings.get_setting("global/is_editor_map_load")
var play_map_id = ProjectSettings.get_setting("global/play_map_id")
# Setting "global/play_map_id"


var selected = {0 : false}


func _ready(): 
	load_maps()
	debug.init_debug(["selected"], self)


# Load data from db and create a list
func load_maps():
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	if !db.query("SELECT * FROM Map"): printerr("Select all query failed in map select")
	var data = db.query_result
	for i in data:
		var item = preload("res://code/ui_elements/map_item.tscn").instance()
		item.map_data = i
		map_list.add_child(item)
		item.connect("selected", self, "select_item")
		if data[0]["Id"] == play_map_id: select_item(item)
	db.close_db()
	if selected.has(0): select_random()


# Select random map
func select_random():
	selected = {0 : false}
	if map_list.get_child_count() != 0:
		var rand = rand_range(0, map_list.get_child_count())
		var item = map_list.get_child(rand)
		select_item(item)
	else:
		map_about.text = "You have no maps ;<"


# Remove all items from map list
func clean_list():
	if map_list.get_children().size() < 1: return
	for i in map_list.get_children():
		map_list.remove_child(i)
		i.queue_free()


# Load all results for selected map
func load_results(map_id):
	if result_list.get_child_count() >= 1: 
		for i in result_list.get_children():
			result_list.remove_child(i)
			i.queue_free()
	
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	if !db.query(str("SELECT * FROM Result WHERE Result.IdMap = ", map_id, " ORDER BY Result.Score DESC")): 
		printerr("Select all query failed in map select")
	var data = db.query_result
	var map_data = SaveLoadManager.load_map_header(map_id)
	for i in data.size():
		var item = preload("res://code/ui_elements/result_item.tscn").instance()
		item.result_data = data[i]
		item.result_rank = i + 1
		item.map_data = map_data
		result_list.add_child(item)
		item.connect("selected", self, "select_result")
	db.close_db()


# Emit when result item is selected
func select_result(item):
	ProjectSettings.set_setting("global/result_id", item.result_data["Id"])
	ProjectSettings.set_setting("global/play_map_id", selected.keys()[0])
	var scene = load("res://scenes/win_menu/ui_win_menu.tscn").instance()
	add_child(scene)


# Emit when map item is selected
func select_item(item):
	var data = item.map_data
	
	# Second item click - load map
	if selected.has(data["Id"]) && selected[data["Id"]]:
		ProjectSettings.set_setting("global/play_map_id", data["Id"])
		
		# If loading for editor
		if is_editor_map_load:
			if get_tree().change_scene("res://scenes/level_editor/ui_editor.tscn") != 0: 
				print_debug("Scene change error / ui_map_select to ui_editor")
			return
		
		# If loading for game
		if get_tree().change_scene("res://scenes/level_game/level_game.tscn") != 0:
			print_debug("Scene change error / ui_map_select to level_game")
	
	# First item click - map select
	else:
		item.grab_focus()
		map_about.text = map_about_text.format({
			"Name" : data["Name"],
			"Creator" : data["Creator"],
			"Artist" : data["Artist"],
			"Song" : data["Song"].get_file().get_basename()
		})
		map_other.text = map_other_text.format({
			"BPM" : data["BPM"],
			"Difficult" : data["Difficult"],
			"BS" : data["BS"],
			"TD" : data["TD"],
			"PT" : data["PerfectTime"],
			"J": data["JumpsCount"]
		})
		selected = {data["Id"] : true}
		if !is_editor_map_load: load_results(data["Id"])


# Full map delete
func delete():
	if !SaveLoadManager.delete_map(selected.keys()[0]):
		PopUp.new().accept_dialog("Error!", "Map delete is failed :<", self)
		return
	clean_list()
	load_maps()


# Reimport all maps
func reimport_maps():
	var new_count = 0
	var deleted_count = 0
	
	# Get all files
	var files = []
	var dir = Directory.new()
	var path = OS.get_executable_path().get_base_dir() + "/maps"
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file != "." && file != ".." && file != "": files.append(file)
		if file == "": break
	
	# Open db
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	
	# Get all map rows from db
	db.query("SELECT * FROM Map")
	var data = db.query_result
	
	if files.size() == 0 && data.size() == 0: 
		PopUp.new().accept_dialog("You have no any maps!", \
		"It's time to create new one, or import it! ;3", self)
		db.close_db()
		return 0
	
	# Create a check array for db valid 
	var check_arr = []
	for j in data.size(): check_arr.append(false)
	
	# Check map directory valid
	if files.size() != 0:
		for i in max(files.size(), data.size()):
			if i <= files.size() - 1: 
				var exist = false
				var map = SaveLoadManager.load_map_data(files[i])
				for j in data.size(): if map["Name"] == data[j]["Name"]: 
					exist = true
					check_arr[j] = true
				if !exist: 
					# Add non exist rows
					if SaveLoadManager.save_map(map, null): new_count += 1
	
	# Delete non valid rows
	for i in check_arr.size():
		if !check_arr[i]: 
			if !db.delete_rows("Map", str("Map.Id = ", data[i]["Id"])):
				printerr("Delete failed in reimport")
			else: deleted_count += 1
	db.close_db()
	
	PopUp.new().accept_dialog("Your maps are ok!", \
	str("Maps count: ", files.size(), ",\n", \
	"New maps: ", new_count, ",\n", \
	"Deleted empty maps: ", deleted_count, "!"), self)
	
	return files.size()


# Return to main menu or editor menu
func _on_BtnBack_pressed():
	if is_editor_map_load:
		if get_tree().change_scene("res://scenes/level_editor/ui_editor.tscn") != 0: 
			print_debug("Scene change error / ui_map_select to ui_editor")
		return
	if get_tree().change_scene("res://scenes/main_menu/ui_main_menu.tscn") != 0:
		print_debug("Scene change error / ui_map_select to level_game")


# Map delete button signal
func _on_BtnDelete_pressed():
	if map_list.get_child_count() == 0: 
		PopUp.new().accept_dialog("Ehh?", "You can't delete nothing!", self)
		return
	PopUp.new().confirm_dialog("Delete? ;<", "Please confirm", self, null, "delete")


# Reimport maps button signal
func _on_BtnReload_pressed():
	reimport_maps()
	clean_list()
	load_maps()

