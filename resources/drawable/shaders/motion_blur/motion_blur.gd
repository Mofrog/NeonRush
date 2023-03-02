@tool
extends MeshInstance3D

var cam_pos_prev = Vector3()
var cam_rot_prev = Quaternion()

var is_mb_enabled = ProjectSettings.get_setting("config/is_motion_blur_enabled")


func _physics_process(_delta):
	if !is_mb_enabled: 
		get_parent().remove_child(self)
		queue_free()
		return
	
	var mat = get_surface_override_material(0)
	var cam = get_parent()
	assert(cam is Camera3D)
	
	# Linear velocity is just difference in positions between two frames.
	var velocity = cam.global_transform.origin - cam_pos_prev
	
	# Angular velocity is a little more complicated, as you can see.
	# See https://math.stackexchange.com/questions/160908/how-to-get-angular-velocity-from-difference-orientation-quaternion-and-time
	var cam_rot = Quaternion(cam.global_transform.basis)
	var cam_rot_diff = cam_rot - cam_rot_prev
	if cam_rot.dot(cam_rot_prev) < 0.0: # Wraparound Fix
		cam_rot_diff = -cam_rot_diff;
		
	var cam_rot_conj = conjugate(cam_rot)
	var ang_vel = (cam_rot_diff * 2.0) * cam_rot_conj; 
	ang_vel = Vector3(ang_vel.x, ang_vel.y, ang_vel.z) # Convert Quaternion to Vector3
	
	mat.set_shader_parameter("linear_velocity", velocity)
	mat.set_shader_parameter("angular_velocity", ang_vel)
		
	cam_pos_prev = cam.global_transform.origin
	cam_rot_prev = Quaternion(cam.global_transform.basis)
	
# Calculate the conjugate of a quaternion.
func conjugate(quat):
	return Quaternion(-quat.x, -quat.y, -quat.z, quat.w)
