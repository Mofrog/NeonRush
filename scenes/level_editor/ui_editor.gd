extends Control


@onready var map_name = $M/V/Control/MapName

@onready var grid_axis = $M/V/Header/H/GridAxis
@onready var button_type = $M/V/Header/H/BtnType

@onready var footer = $M/V/Footer

@onready var viewport_container = $M/V/Footer/V
@onready var editor = $M/V/Footer/V/V/Root
@onready var chunks = $M/V/Footer/V/V/Root/Chunks
@onready var character = $M/V/Footer/V/V/Root/Character

@onready var tab_container = $M/V/Footer/TabContainer
@onready var blocks_list = $M/V/Footer/TabContainer/Blocks/List
@onready var objects_list = $M/V/Footer/TabContainer/Objects/ListO

@onready var timeline = $M/V/PanelContainer/Timeline

@onready var settings_p = $Settings


# Go to:
#	level_game
#	ui_map_select
#	ui_main_menu


# Global var's
var play_map_id = ProjectSettings.get_setting("global/play_map_id")
var result_id = ProjectSettings.get_setting("global/result_id")
var is_test_mode = ProjectSettings.get_setting("global/is_test_mode")
# Setting:
#	"global/is_editor_map_load"
#	"global/is_test_mode"
#	"global/result_id"


#------------------------------------READY_EXIT FUNC'S--------------------------
func _ready():
	ProjectSettings.set_setting("global/is_editor_map_load", false)
	ProjectSettings.set_setting("global/is_test_mode", false)
	
	ProjectSettings.set_setting("global/is_end_valid", false)
	for i in Blocks.objects.keys(): objects_list.add_item(i)
	if result_id != -1: editor.draw_visual_path()
	load_map()


#------------------------------------PROCESS FUNC'S-----------------------------
func _process(_delta):
	check_ui_focus()
	shortcuts_process()
	if timeline != null && result_id != -1: editor.update_replay_pos(timeline.manager.time)
	map_name.text = settings_p.data["Name"]


func shortcuts_process():
	if tab_container.current_tab == 1: character.b_type = 2
	elif button_type.pressed: character.b_type = 1
	else: character.b_type = 0
	
	if Input.is_action_just_pressed("editor_grid_switch"):
		if grid_axis.selected == 2: grid_axis.selected = 0
		else: grid_axis.selected += 1


func check_ui_focus():
	var rect = Rect2(footer.position, viewport_container.size)
	if rect.has_point(get_local_mouse_position()):
		map_name.grab_focus()
		footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ProjectSettings.set_setting("global/is_on_ui", false)
	else:
		footer.mouse_filter = Control.MOUSE_FILTER_STOP
		ProjectSettings.set_setting("global/is_on_ui", true)


#------------------------------------UTILITE FUNC'S-----------------------------
# Onready loading of the map
func load_map():
	if play_map_id == -1: return
	
	# Get map data
	var data = SaveLoadManager.load_map_header(play_map_id)
	map_name.text = data["Name"]
	settings_p.data_update(data, true)
	settings_p.disable_edit()
	
	# Load song
	var path = OS.get_executable_path().get_base_dir() + "/maps/" + data["Name"] + "/" + data["Song"].get_file()
	var song_data : AudioStream = AudioLoader.loadfile(path)
	timeline.stream = song_data
	timeline.set_max(data["End"])
	timeline.manager.set_bpm(data["BPM"])
	timeline.manager.calc_delay(data["BS"], data["TD"])
	timeline.manager.set_general_delay(data["Delay"])
	
	# Load map
	data = SaveLoadManager.load_map_data(data["Name"])
	if !data.has("Chunks"): return
	chunks.delete_all_chunks()
	chunks.chunks = data["Chunks"]
	chunks.update_chunks_visibility(character)
	ProjectSettings.set_setting("global/is_end_valid", true)


# Save the map
func save_map():
	SaveLoadManager.save_map(settings_p.data, chunks.chunks, settings_p.is_data_resave)
	settings_p.disable_edit()
	PopUp.new().accept_dialog("Succes!", "Map saved :3", self)


# Check that map have a song
func is_map_valid():
	# Check song existance
	if settings_p.data["Song"] == "unknown": 
		PopUp.new().accept_dialog("Fail!", "There is no song at your map!", self)
		return false
	if !ProjectSettings.get_setting("global/is_end_valid"):
		PopUp.new().accept_dialog("Fail!", "There is no end at your map!", self)
		return false
	return true


func exit_editor(): 
	if is_map_valid(): save_map()
	if get_tree().change_scene_to_file("res://scenes/main_menu/ui_main_menu.tscn") != 0: 
		printerr("Scene change error / ui_editor to ui_main_menu")


# Close warning panel
func _on_Warning_hide(): get_tree().paused = false


#--------------------------------------MENU EVENTS------------------------------
# Return to the main menu
func _on_BtnBack_pressed():
	PopUp.new().confirm_dialog("Exit?", "Please confirm. Map will be saved.", self, null, "exit_editor")


# Save map
func _on_BtnSave_pressed(): if is_map_valid(): save_map()


# Load map (Open the map selection scene)
func _on_BtnLoad_pressed():
	ProjectSettings.set_setting("global/is_editor_map_load", true)
	if get_tree().change_scene_to_file("res://scenes/map_select_menu/ui_map_select.tscn") != 0: 
		printerr("Scene change error / ui_editor to ui_map_select")


# Open map settings panel
func _on_BtnSetts_pressed():
	settings_p.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Start map test at game scene
func _on_BtnTest_pressed():
	if is_map_valid(): save_map()
	else: return
	
	var id = SaveLoadManager.load_map_header(null ,settings_p.data["Name"])["Id"]
	ProjectSettings.set_setting("global/result_id", id)
	ProjectSettings.set_setting("global/is_test_mode", true)
	if get_tree().change_scene_to_file("res://scenes/level_game/level_game.tscn") != 0: 
		printerr("Scene change error / ui_editor to level_game")


#------------------------------------HEADER EVENTS------------------------------
func _on_GridAxis_pressed_group(button):
	if character != null:
		match button:
			0: character.grid_offset = character.cursor_pos_cubic.y
			1: character.grid_offset = character.cursor_pos_cubic.z
			2: character.grid_offset = character.cursor_pos_cubic.x
		editor.grid_axis = button


func _on_LChCursor_pressed_group(button): if editor != null: editor.type = button


func _on_BtnRotate_pressed(): 
	character.rotate_object()
	editor.rotate_preview()


#----------------------------------BLOCKS LIST EVENTS---------------------------
func _on_List_item_selected(index): if character != null: character.id_tex = index


func _on_ListO_item_selected(index): if character != null: character.id_obj = index


#-----------------------------------TIMELINE EVENTS-----------------------------
func _on_TabContainer_tab_changed(tab): 
	if editor != null: 
		if tab == 0 || tab == 2: editor.object = 0
		else: editor.object = 1


func _on_BtnHelp_pressed():
	PopUp.new().accept_dialog("Help",
	"Movement: WASD\n" + \
	"Up, Down: Space, Alt\n" + \
	"View around: Mouse Wheel Button\n" + \
	"Zoom: Ctrl + Mouse Wheel Up, Down\n" + \
	"Action: Left Mouse Button\n" + \
	"Cancel: Right Mouse Button\n" + \
	"Grid Up, Down: Mouse Wheel Up, Down\n" + \
	"Select, Spawn, Delete mode: Z, X, C\n" + \
	"Rotate grid: Q\n" + \
	"Switch block type: T\n" + \
	"Rotate block: R\n" + \
	"Save map: Shift + S", self)
