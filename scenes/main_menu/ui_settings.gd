extends Control


signal saved


@onready var btn_settings = $M/C/Body/Menu/BtnSettings
var warning_popup = null


var settings : Dictionary = {
	"Language" : 0,
	"WSize" : 5,
	"WMode" : 2,
	"VSync" : 1,
	"MaxFPS" : 2.0,
	"MSens" : 1.0,
	"Graphics" : 2,
	"Blur" : 1,
	"Distance" : 12,
	"Master volume" : 1.0,
	"Music volume" : 1.0,
	"Effect volume" : 1.0,
	"FPSCounter" : 0
}
var default_settings = settings.duplicate()


func _ready():
	$M/C/Body/Menu/BtnSettings.grab_focus()
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file != null:
		var result = JSON.parse_string(file.get_as_text())
		settings = settings if result == null else result
		set_settings()
		default_settings = settings.duplicate()


func _on_visibility_changed():
	if btn_settings == null: return
	btn_settings.toggle_mode = true
	btn_settings.button_pressed = true
	btn_settings.grab_focus()


func _on_btn_settings_pressed():
	if is_settings_changed(): 
		init_popup()
	else: 
		get_parent().remove_child(self)
		queue_free()


func _on_btn_cancel_btn_pressed():
	get_parent().remove_child(self)
	queue_free()


func _on_btn_save_btn_pressed():
	if is_settings_changed():
		var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
		file.store_string(JSON.stringify(settings))
		emit_signal("saved")
	get_parent().remove_child(self)
	queue_free()


func _on_ok_pressed():
	warning_popup.queue_free()


func _on_cancel_pressed():
	get_parent().remove_child(self)
	queue_free()


func init_popup():
	warning_popup = preload("res://code/ui_elements/pop_up.tscn").instantiate()
	warning_popup.ok.connect(_on_ok_pressed)
	warning_popup.cancel.connect(_on_cancel_pressed)
	warning_popup.header = "Warning"
	warning_popup.text = "Do you want discard the changes?"
	warning_popup.cancel_text = "Discard"
	warning_popup.ok_text = "Return"
	add_child(warning_popup)


func is_settings_changed():
	for i in settings: if settings[i] != default_settings[i]: return true
	return false


# Settings
func set_settings():
	$M/C2/C/C/C/SItem16/OptLang.select(settings["Language"])
	$M/C2/C/C/C/SItem/OptWSize.select(settings["WSize"])
	$M/C2/C/C/C/SItem2/OptWMode.select(settings["WMode"])
	$M/C2/C/C/C/SItem3/OptVS.select(settings["VSync"])
	$M/C2/C/C/C/SItem4/SOMaxFPS.select(settings["MaxFPS"])
	$M/C2/C/C/C/SItem7/SOMouseSens.select(settings["MSens"])
	$M/C2/C/C/C/SItem13/OptGraphics.select(settings["Graphics"])
	$M/C2/C/C/C/SItem6/OptBlur.select(settings["Blur"])
	$M/C2/C/C/C/SItem5/SOVisible.select(settings["Distance"])
	$M/C2/C/C/C/SItem8/SOVMaster.select(settings["Master volume"])
	$M/C2/C/C/C/SItem10/SOVMusic.select(settings["Music volume"])
	$M/C2/C/C/C/SItem9/SOVEffect.select(settings["Effect volume"])
	$M/C2/C/C/C/SItem12/OptFPSCounter.select(settings["FPSCounter"])


func _on_opt_lang_item_selected(index): settings["Language"] = index
func _on_opt_w_size_item_selected(index): settings["WSize"] = index
func _on_opt_w_mode_item_selected(index): settings["WMode"] = index
func _on_opt_vs_item_selected(index): settings["VSync"] = index
func _on_so_max_fps_value_changed(value): settings["MaxFPS"] = value
func _on_so_mouse_sens_value_changed(value): settings["MSens"] = value
func _on_opt_graphics_item_selected(index): settings["Graphics"] = index
func _on_opt_blur_item_selected(index): settings["Blur"] = index
func _on_so_visible_value_changed(value): settings["Distance"] = value
func _on_sov_master_value_changed(value): settings["Master volume"] = value
func _on_sov_music_value_changed(value): settings["Music volume"] = value
func _on_sov_effect_value_changed(value): settings["Effect volume"] = value
func _on_opt_fps_counter_item_selected(index): settings["FPSCounter"] = index
