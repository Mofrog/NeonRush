#TODO UI for diffetent resolutions
extends Control


# Map select menu
func _on_btn_select_pressed():
	$Menu.visible = false
	var map_select = preload("res://scenes/map_select_menu/ui_map_select.tscn").instantiate()
	add_child(map_select)
	map_select.tree_exited.connect(_on_map_select_exit)

func _on_map_select_exit():
	$Menu.visible = true
	$Menu/C/Body/Menu/BtnSelect.grab_focus()


func _on_btn_editor_pressed():
	get_tree().change_scene_to_file("res://scenes/level_editor/ui_editor.tscn")


# Settings
func _on_btn_settings_pressed():
	$Menu.visible = false
	var settings = preload("res://scenes/main_menu/ui_settings.tscn").instantiate()
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
	var about = preload("res://scenes/main_menu/ui_about.tscn").instantiate()
	add_child(about)
	about.tree_exited.connect(_on_about_exit)

func _on_about_exit():
	$Menu.visible = true
	$Menu/C/Body/Menu/BtnAbout.grab_focus()


# Exit game
var warning_popup = null

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
