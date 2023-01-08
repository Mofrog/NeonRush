# TODO Refractor settings
extends Control


@onready var debug = $VerTooltip
@onready var settings = $AcceptDialog


var is_debug_enabled = ProjectSettings.get_setting("config/is_debug_enabled")
var is_motion_blur_enabled = ProjectSettings.get_setting("config/is_motion_blur_enabled")
var visible_radius = ProjectSettings.get_setting("config/visible_radius")
var mouse_sens = ProjectSettings.get_setting("config/mouse_sens")


func _init():
	var dir = Directory.new()
	var err = File.new().open("user://user.db", File.READ)
	if err != OK:
		dir.copy("res://data/user.db", "user://user.db")
		print("Added db")
	
	var file = File.new()
	file.open("user://user.settings", File.READ)
	var data = file.get_var()
	if data != null:
		is_debug_enabled = data["is_debug_enabled"]
		is_motion_blur_enabled = data["is_motion_blur_enabled"]
		visible_radius = data["visible_radius"]
		mouse_sens = data["mouse_sens"]
		ProjectSettings.set_setting("config/is_debug_enabled", is_debug_enabled)
		ProjectSettings.set_setting("config/is_motion_blur_enabled", is_motion_blur_enabled)
		ProjectSettings.set_setting("config/visible_radius", visible_radius)
		ProjectSettings.set_setting("config/mouse_sens", mouse_sens)
	file.close()


func _ready():
	ProjectSettings.set_setting("global/play_map_id", -1)
	ProjectSettings.set_setting("global/result_id", -1)
	
	debug.init_debug(["is_debug_enabled", "is_motion_blur_enabled", "visible_radius", "mouse_sens"], self)


func _on_MapSelect_pressed():
	if get_tree().change_scene_to_file("res://scenes/map_select_menu/ui_map_select.tscn") != OK: 
		print_debug("Scene change error")


func _on_Editor_pressed():
	if get_tree().change_scene_to_file("res://scenes/level_editor/ui_editor.tscn") != OK: 
		print_debug("Scene change error")


func _on_Exit_pressed():
	get_tree().quit()


func _on_BtnAbout_pressed():
	PopUp.new().accept_dialog("About", 
		"Neon Rush\nBy: MLKW(Mofrog)\n" + \
		"Licenced under MIT\n" + \
		"More info checked github page: https://github.com/Mofrog/NeonRush \n" + \
		"Join to Neon rush discord server: https://discord.gg/qKznMrpdnw", 
		self)


func _on_BtnSettings_pressed(): 
	get_tree().paused = true
	settings.visible = true
	
	$AcceptDialog/MarginContainer/VBoxContainer/Config/BtnDebug.button_pressed = is_debug_enabled
	$AcceptDialog/MarginContainer/VBoxContainer/Config/BtnBlur.button_pressed = is_motion_blur_enabled
	$AcceptDialog/MarginContainer/VBoxContainer/Config2/Radius.value = visible_radius
	$AcceptDialog/MarginContainer/VBoxContainer/Config2/HSlider.value = mouse_sens


func _on_AcceptDialog_hide():
	var file = File.new()
	file.open("user://user.settings", File.WRITE)
	var data = {
		"is_debug_enabled" : ProjectSettings.get_setting("config/is_debug_enabled"),
		"is_motion_blur_enabled" : ProjectSettings.get_setting("config/is_motion_blur_enabled"),
		"visible_radius" : ProjectSettings.get_setting("config/visible_radius"),
		"mouse_sens" : ProjectSettings.get_setting("config/mouse_sens")
	}
	file.store_var(data)
	file.close()
	get_tree().paused = false
	PopUp.new().accept_dialog("Info", "Settings saved.", self)


func _on_BtnDebug_toggled(button_pressed):
	ProjectSettings.set_setting("config/is_debug_enabled", button_pressed)


func _on_BtnBlur_toggled(button_pressed):
	ProjectSettings.set_setting("config/is_motion_blur_enabled", button_pressed)


func _on_Radius_value_changed(value):
	ProjectSettings.set_setting("config/visible_radius", value)


func _on_HSlider_value_changed(value):
	ProjectSettings.set_setting("config/mouse_sens", value)
