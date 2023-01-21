extends GPUParticles2D


var once = false


func _input(event):
	if event is InputEventMouseMotion:
		if !once:
			position = event.position
			once = true
			visible = true
			return
		position += event.relative
