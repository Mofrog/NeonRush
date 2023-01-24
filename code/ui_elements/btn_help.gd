extends Button


signal btn_pressed()


@export var key_btn = "Q"
@export var wait_time = 0.5
@export var one_shot = false


func _ready():
	if one_shot: $ProgressBar.visible = false
	$Label.text = key_btn
	$Timer.wait_time = wait_time


func _process(_delta):
	if $ProgressBar.value == 1:
		btn_pressed.emit()
	if $Timer.is_stopped(): 
		$ProgressBar.value = 0
	else: 
		$ProgressBar.value = (wait_time - $Timer.time_left) * 2


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT: 
			$Timer.start(0)
		else: 
			$Timer.stop()


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if OS.get_keycode_string(event.keycode) == key_btn: 
				if one_shot:
					pressed.emit()
					return
				grab_focus()
				$Timer.start(0)
		else:
			$Timer.stop()


func _on_mouse_exited(): $Timer.stop()
