extends Control


signal cancel
signal ok


@export var header = "Pop up header"
@export var text = "Pop up text"
@export var cancel_text = "Cancel"
@export var ok_text = "Ok"


func _ready():
	$C/C/C/C/Header.text = header
	$C/C/C/Text.text = text
	$C/C/C/C3/BtnCancel.text = cancel_text
	$C/C/C/C3/BtnOk.text = ok_text
	get_tree().paused = true


func _exit_tree():
	get_tree().paused = false


func _on_btn_ok_pressed():
	emit_signal("ok")


func _on_btn_cancel_pressed():
	emit_signal("cancel")
