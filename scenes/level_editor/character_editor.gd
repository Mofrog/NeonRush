extends Node3D


const cursor_ray_length = 100

var deceleration = 2.1
var friction = 10.0
var speed = 3.0
var acceleration = 0.0
var velocity = Vector3()


func _ready():
	$spring_arm/camera.far = ProjectSettings.get_setting("config/visible_radius") * 15


func _unhandled_input(event):
	# Look around
	if Input.is_action_pressed("editor_look_around") && event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.cursor_state = Global.CURSOR_STATE.MOVE
		var sens = ProjectSettings.get_setting("config/mouse_sens")
		rotation_degrees.y -= event.relative.x * sens / 2
		rotation_degrees.x -= event.relative.y * sens / 2
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
	
	if  Input.is_action_just_released("editor_look_around"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Global.cursor_state = Global.CURSOR_STATE.BRUSH


func _process(delta):
	# Movement
	var dir = Vector3()
	dir.x = Input.get_action_strength("editor_right") - Input.get_action_strength("editor_left")
	dir.z = Input.get_action_strength("editor_back") - Input.get_action_strength("editor_forward")
	dir = dir.rotated(Vector3.UP, rotation.y).normalized()
	dir.y = Input.get_action_strength("editor_up") - Input.get_action_strength("editor_down")
	
	acceleration += speed * delta
	acceleration = acceleration if acceleration <= deceleration else deceleration
	
	velocity.x += dir.x * acceleration
	velocity.y += dir.y * acceleration
	velocity.z += dir.z * acceleration
	velocity /= (friction / 4 if Input.is_action_pressed("editor_sprint") else friction)
	
	position += velocity


func ray_cast(mask = 1): 
	var camera = $spring_arm/camera
	var space_state = get_world_3d().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * cursor_ray_length
	var intersection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, mask))
	return intersection
