extends Control


@onready var menu = $Menu
var settings = null
@onready var btn_settings = $Menu/C/Body/Menu/BtnSettings


func _on_btn_settings_pressed():
	menu.visible = false
	settings = preload("res://scenes/main_menu/ui_settings.tscn").instantiate()
	add_child(settings)
	settings.exit_settings.connect(_on_settings_exit_settings)


func _on_settings_exit_settings():
	menu.visible = true
	btn_settings.grab_focus()
	settings.queue_free()


func _on_btn_exit_pressed():
	get_tree().free()
