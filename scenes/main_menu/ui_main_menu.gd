extends Control


var settings = null
var about = null
var warning_popup = null
var settings_data = {}


func _ready(): load_lang()


func load_lang():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file != null:
		settings_data = JSON.parse_string(file.get_as_text())
		if settings_data != null:
			TranslationServer.set_locale("ru" if settings_data["Language"] == 1 else "")
	else:
		TranslationServer.set_locale("")


# Settings
func _on_btn_settings_pressed():
	$Menu.visible = false
	settings = preload("res://scenes/main_menu/ui_settings.tscn").instantiate()
	add_child(settings)
	settings.tree_exited.connect(_on_settings_exit_settings)
	settings.saved.connect(_on_settings_saved)

func _on_settings_saved():
	var notice = preload("res://code/ui_elements/notice.tscn").instantiate()
	notice.notice_text = tr("MMP_Saved")
	add_child(notice)

func _on_settings_exit_settings():
	$Menu.visible = true
	$Menu/C/Body/Menu/BtnSettings.grab_focus()


# About
func _on_btn_about_pressed():
	$Menu.visible = false
	about = preload("res://scenes/main_menu/ui_about.tscn").instantiate()
	add_child(about)
	about.tree_exited.connect(_on_about_exit)

func _on_about_exit():
	$Menu.visible = true
	$Menu/C/Body/Menu/BtnAbout.grab_focus()


# Exit game
func _on_btn_exit_pressed(): init_popup()

func init_popup():
	warning_popup = preload("res://code/ui_elements/pop_up.tscn").instantiate()
	warning_popup.ok.connect(_on_ok_pressed)
	warning_popup.cancel.connect(_on_cancel_pressed)
	warning_popup.header = tr("SMP_Warning")
	warning_popup.text = tr("MMP_Exit?")
	warning_popup.cancel_text = tr("MMP_No")
	warning_popup.ok_text = tr("MMP_Exit")
	add_child(warning_popup)
	
func _on_ok_pressed(): get_tree().free()

func _on_cancel_pressed(): warning_popup.queue_free()
