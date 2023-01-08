extends Spatial


# Maximum ray length in edit mode
const cursor_ray_length = 100

# Overall editor movement speed
var speed = 3

# Editor slowing value
const dec = 2.1

# Editor friction
const fric = 1.5

# Editor zooming
const zoom_scale = 0.1
const max_zoom = 100
const min_zoom = 0

enum STATE {CURSOR, SELECT, MOVE}
var state = STATE.CURSOR
var is_cancel = false
var grid_offset = 0

var cursor_pos = Vector3()
var cursor_pos_cubic = Vector3()

var selection_start_pos = Vector3()
var selection_end_pos = Vector3()
var acceleration = 0
var velocity = Vector3()

var id_tex = 0
var id_obj = 0
var b_rot = 0
var b_type = 0

#----------------------------------FUNC'S---------------------------------------
func _physics_process(_delta):
	if ProjectSettings.get_setting("global/is_on_ui"): return
	zoom()
	movement(_delta)
	selection()
	cursor_location()
	
	if Input.is_action_pressed("editor_speed_up"): speed = 15
	else: speed = 3



func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation(event)
	if Input.is_action_just_released("editor_rotation"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		state = STATE.CURSOR


func ray_cast(mask = 1): 
	var camera = $spring_arm/camera
	var space_state = get_world().direct_space_state
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * cursor_ray_length
	var intersection = space_state.intersect_ray(from, to, [], mask, true, true)
	return intersection


# zoom movement function
func zoom():
	var spring_arm = $spring_arm
	if Input.is_action_just_released("editor_zoom_up"):
		if Input.is_action_pressed("control"):
			spring_arm.spring_length -= zoom_scale * spring_arm.spring_length + 0.2 \
			if spring_arm.spring_length > min_zoom else 0
		else:
			grid_offset += 1
	
	if Input.is_action_just_released("editor_zoom_down"):
		if Input.is_action_pressed("control"):
			spring_arm.spring_length += zoom_scale * spring_arm.spring_length + 0.2 \
			if spring_arm.spring_length < max_zoom else 0
		else:
			grid_offset -= 1


# movement function
func movement(_delta):
	var dir = Vector3()
	if !Input.is_action_pressed("control"):
		dir.x = Input.get_action_strength("editor_right") - \
		Input.get_action_strength("editor_left")
		
		dir.z = Input.get_action_strength("editor_back") - \
		Input.get_action_strength("editor_forward")
	
	dir = dir.rotated(Vector3.UP, rotation.y).normalized()
	dir.y = Input.get_action_strength("editor_up") - \
	Input.get_action_strength("editor_down")
	
	acceleration += speed * _delta
	acceleration /= fric if acceleration < dec \
	else fric * 10
	
	velocity.x += dir.x * acceleration
	velocity.y += dir.y * acceleration
	velocity.z += dir.z * acceleration
	velocity /= fric
	
	translation += velocity


# rotation function
func rotation(event):
	if Input.is_action_pressed("editor_rotation"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		state = STATE.MOVE
		var sens = ProjectSettings.get_setting("config/mouse_sens")
		rotation_degrees.y -= event.relative.x * sens
		rotation_degrees.x -= event.relative.y * sens
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)


# select some area
func selection():
	if Input.is_action_pressed("editor_action_primary"):
		if !is_cancel:
			if state == STATE.CURSOR:
				state = STATE.SELECT
				selection_start_pos = cursor_pos_cubic
			selection_end_pos = cursor_pos_cubic
		
		if Input.is_action_just_pressed("editor_action_secondary"):
			is_cancel = true
			reset_selection()
	if Input.is_action_just_released("editor_action_primary"):
		state = STATE.CURSOR
		is_cancel = false


func reset_selection():
	selection_start_pos = Vector3.ZERO
	selection_end_pos = Vector3.ZERO


# calculate cursor location
func cursor_location():
	var intersection = ray_cast()
	if !intersection.empty():
		cursor_pos = intersection.position
		cursor_pos_cubic = cursor_pos.ceil()


func rotate_object():
	b_rot += 90
	if b_rot > 360: b_rot = 90
