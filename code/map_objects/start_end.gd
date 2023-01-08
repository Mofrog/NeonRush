extends Area3D
class_name StartEnd

var is_end = false


func _init():
	position = Vector3(0, 4, -9)
	scale = Vector3(3, 3, 0.05)
	collision_layer = 2
	collision_mask = 2


func _ready():
	if is_end:
		$Label.text = "End"
		$Label2.text = "End"
	else:
		var scene = load("res://code/map_objects/start_end.tscn").instantiate().duplicate(true)
		for i in scene.get_children():
			scene.remove_child(i)
			add_child(i)


func _exit_tree(): if is_end: ProjectSettings.set_setting("global/is_end_valid", false)
