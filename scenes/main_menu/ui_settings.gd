extends Control


signal saved


var is_update_disabled = true
var warning_popup = null
var settings_class = Settings.new()


func _ready():
	$M/C/Body/Menu/BtnSettings.grab_focus()
	set_settings()


# Exit with saving
func _on_btn_save_btn_pressed():
	if settings_class.is_settings_changed():
		settings_class.save_settings()
		emit_signal("saved")
	get_parent().remove_child(self)
	queue_free()


# Exit without saving
func _on_btn_settings_pressed():
	if settings_class.is_settings_changed(): 
		_init_popup()
	else: 
		get_parent().remove_child(self)
		queue_free()

func _on_btn_cancel_btn_pressed():
	settings_class.settings = settings_class.default_settings
	settings_class.set_settings()
	get_parent().remove_child(self)
	queue_free()

func _init_popup():
	warning_popup = preload("res://code/ui_elements/pop_up.tscn").instantiate()
	warning_popup.ok.connect(_on_btn_cancel_btn_pressed)
	warning_popup.cancel.connect(_on_cancel_pressed)
	warning_popup.header = tr("SMP_Warning") 
	warning_popup.text = tr("SMP_Discard_Changes")
	warning_popup.cancel_text = tr("SMP_Return")
	warning_popup.ok_text = tr("SMP_Discard")
	add_child(warning_popup)

func _on_cancel_pressed():
	warning_popup.queue_free()


# Settings
func set_settings():
	var settings = settings_class.get_data()
	if settings != null:
		settings_class.settings = settings.duplicate()
		settings_class.default_settings = settings.duplicate()
	$M/C2/C/C/C/SItem16/OptLang.select(settings_class.settings["Language"])
	$M/C2/C/C/C/SItem/OptWSize.select(settings_class.settings["WSize"])
	$M/C2/C/C/C/SItem2/OptWMode.select(settings_class.settings["WMode"])
	$M/C2/C/C/C/SItem3/OptVS.select(settings_class.settings["VSync"])
	$M/C2/C/C/C/SItem4/SOMaxFPS.select(settings_class.settings["MaxFPS"])
	$M/C2/C/C/C/SItem7/SOMouseSens.select(settings_class.settings["MSens"])
	$M/C2/C/C/C/SItem13/OptGraphics.select(settings_class.settings["Graphics"])
	$M/C2/C/C/C/SItem6/OptBlur.select(settings_class.settings["Blur"])
	$M/C2/C/C/C/SItem5/SOVisible.select(settings_class.settings["Distance"])
	$M/C2/C/C/C/SItem8/SOVMaster.select(settings_class.settings["Master volume"])
	$M/C2/C/C/C/SItem10/SOVMusic.select(settings_class.settings["Music volume"])
	$M/C2/C/C/C/SItem9/SOVEffect.select(settings_class.settings["Effect volume"])
	$M/C2/C/C/C/SItem12/OptFPSCounter.select(settings_class.settings["FPSCounter"])
	is_update_disabled = false

func set_setting(setting_name, settings_value):
	if is_update_disabled: return
	settings_class.settings[setting_name] = settings_value
	settings_class.set_settings()

func _on_opt_lang_item_selected(index): set_setting("Language", index)
func _on_opt_w_size_item_selected(index): settings_class.settings["WSize"] = index
func _on_opt_w_mode_item_selected(index): settings_class.settings["WMode"] = index
func _on_opt_vs_item_selected(index): set_setting("VSync", index)
func _on_so_max_fps_value_changed(value): set_setting("MaxFPS", value)
func _on_so_mouse_sens_value_changed(value): set_setting("MSens", value)
func _on_opt_graphics_item_selected(index): set_setting("Graphics", index)
func _on_opt_blur_item_selected(index): set_setting("Blur", index)
func _on_so_visible_value_changed(value): set_setting("Distance", value)
func _on_sov_master_value_changed(value): set_setting("Master volume", value)
func _on_sov_music_value_changed(value): set_setting("Music volume", value)
func _on_sov_effect_value_changed(value): set_setting("Effect volume", value)
func _on_opt_fps_counter_item_selected(index): set_setting("FPSCounter", index)

