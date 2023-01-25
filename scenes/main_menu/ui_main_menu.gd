extends Control


var settings = null
var about = null
var warning_popup = null


# Settings
func _on_btn_settings_pressed():
	$Menu.visible = false
	settings = preload("res://scenes/main_menu/ui_settings.tscn").instantiate()
	add_child(settings)
	settings.tree_exited.connect(_on_settings_exit_settings)
	settings.saved.connect(_on_settings_saved)

func _on_settings_saved():
	var notice = preload("res://code/ui_elements/notice.tscn").instantiate()
	notice.notice_text = "Settings saved!"
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
	warning_popup.header = "Warning"
	warning_popup.text = "Do you want exit?"
	warning_popup.cancel_text = "No!"
	warning_popup.ok_text = "Exit"
	add_child(warning_popup)
	
func _on_ok_pressed(): get_tree().free()

func _on_cancel_pressed(): warning_popup.queue_free()
