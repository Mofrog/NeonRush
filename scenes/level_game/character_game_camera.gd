extends Camera3D


var deg = Vector2()


func _physics_process(_delta):
	rotation_degrees.x = deg.x
	rotation_degrees.y = deg.y

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var sens = ProjectSettings.get_setting("config/mouse_sens")
		deg.x -= event.relative.y * sens
		deg.x = clamp(deg.x, -90, 90)
		deg.y -= event.relative.x * sens
		deg.y = wrapf(deg.y, 0, 360)
