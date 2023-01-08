extends KinematicBody

onready var camera = $Camera
onready var debug = $Debug


signal area_entered(area)


export var speed = 15
export var fric = 1.13
export var air_fric = 1.1
export var gravity = 20
export var jump_scale = 8

var velocity = Vector3()
var velocity_speed = 0.0
var acceleration = 0.0

var is_game_start = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	debug.init_debug(["acceleration", "fric", "velocity_speed"], self)


func _physics_process(delta):
	# get direction vector by input
	var dir = Vector3()
	dir.x = Input.get_action_strength("game_right") - Input.get_action_strength("game_left")
	dir.z = Input.get_action_strength("game_back") - Input.get_action_strength("game_forward")
	dir = dir.rotated(Vector3.UP, camera.rotation.y).normalized()
	
	# calc acceleration
	acceleration = stepify((acceleration + speed * delta) / fric, 0.01)
	
	# calc velocity
	velocity.x += dir.x * acceleration
	if !is_on_floor(): velocity.x /= air_fric
	else: velocity.x /= fric
	velocity.z += dir.z * acceleration
	if !is_on_floor(): velocity.z /= air_fric
	else: velocity.z /= fric
	
	
	# add gravity
	velocity.y -= gravity * delta
	
	# set velocity
	velocity = move_and_slide(velocity, Vector3.UP)
	velocity_speed = stepify(Vector3(velocity.x, 0, velocity.z).length(), 0.01)


func jump(strength = 1, is_important = false): 
	if is_game_start && (is_on_floor() || is_important):
		velocity.y = jump_scale * strength


func restart():
	velocity = Vector3.ZERO
	acceleration = 0
	translation = Vector3(1,5,0)
	camera.deg = Vector2.ZERO


func _on_Area_area_entered(area): emit_signal("area_entered", area)
