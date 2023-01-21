extends Control


signal exit_settings


@onready var btn_settings = $M/C/Body/Menu/BtnSettings


func _on_visibility_changed():
	if btn_settings == null: return
	btn_settings.toggle_mode = true
	btn_settings.button_pressed = true
	btn_settings.grab_focus()


func _on_btn_settings_toggled(button_pressed):
	if (!button_pressed): 
		btn_settings.toggle_mode = false
		emit_signal("exit_settings")
