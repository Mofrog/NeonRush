extends OptionButton



func _on_focus_entered():
	$StrokeFocus.visible = true


func _on_focus_exited():
	$StrokeFocus.visible = false


func _on_toggled(_button_pressed):
	if _button_pressed:
		ProjectSettings.set_setting("art/is_mouse_trail_dis", true)
		Input.set_custom_mouse_cursor(null, CURSOR_ARROW)
		$OptionArrowD.visible = false
		$OptionArrowP.visible = true
	else:
		ProjectSettings.set_setting("art/is_mouse_trail_dis", false)
		Input.set_custom_mouse_cursor(load("res://art/icons/mouse_empty.tres"), CURSOR_ARROW)
		$OptionArrowD.visible = true
		$OptionArrowP.visible = false
