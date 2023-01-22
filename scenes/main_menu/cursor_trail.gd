extends GPUParticles2D


var once = false


func _process(_delta):
	if ProjectSettings.get_setting("art/is_mouse_trail_dis"): visible = false
	else: visible = true


func _input(event):
	if event is InputEventMouseMotion:
		if !once:
			position = event.position
			once = true
			visible = true
			return
		position = event.position
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT: process_material.color = Color("ffce51")
		if !event.pressed: process_material.color = Color("c3d6ef")
