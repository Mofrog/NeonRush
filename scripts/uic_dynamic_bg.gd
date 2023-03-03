extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pivot_offset = size / 2
	scale = Vector2.ONE * 1.05
	$Image.set_deferred("size", size)


func _input(event):
	if event is InputEventMouseMotion:
		$Image.position.x -= event.relative.x / 100
		$Image.position.y -= event.relative.y / 100
