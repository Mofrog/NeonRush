extends OptionButton


@export var disable_arrow = false


func _ready():
	if disable_arrow:
		$OptionArrowD.visible = false
		$OptionArrowP.visible = false


func _on_focus_entered():
	$StrokeFocus.visible = true


func _on_focus_exited():
	$StrokeFocus.visible = false


func _on_toggled(_button_pressed):
	if _button_pressed:
		Global.is_mouse_trail_disable = true
		#Input.set_custom_mouse_cursor(null, CURSOR_ARROW)
		if !disable_arrow:
			$OptionArrowD.visible = false
			$OptionArrowP.visible = true
	else:
		Global.is_mouse_trail_disable = false
		#Input.set_custom_mouse_cursor(load("res://art/icons/mouse_empty.tres"), CURSOR_ARROW)
		if !disable_arrow:
			$OptionArrowD.visible = true
			$OptionArrowP.visible = false
