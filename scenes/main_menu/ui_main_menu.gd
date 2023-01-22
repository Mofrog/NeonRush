extends Control


@onready var menu = $Menu
@onready var settings = $Settings
@onready var btn_settings = $Menu/C/Body/Menu/BtnSettings


func _on_btn_settings_pressed():
	menu.visible = false
	settings.visible = true


func _on_settings_exit_settings():
	menu.visible = true
	settings.visible = false
	btn_settings.grab_focus()


func _on_btn_exit_pressed():
	get_tree().free()
