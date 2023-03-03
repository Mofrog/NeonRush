extends Node3D


@onready var select = $Select
@onready var cursor = $Cursor

var selection_start_pos = Vector3()
var selection_end_pos = Vector3()

var box_mesh = null
var slope_mesh = null
var half_mesh = null


func _ready():
	box_mesh = BoxMesh.new()
	slope_mesh = PrismMesh.new()
	slope_mesh.left_to_right = 0
	half_mesh = BoxMesh.new()
	half_mesh.size.y = 0.5


func calc_position(intersection):
	if !intersection.is_empty():
		cursor.position = (intersection["position"] - Vector3(0.4,0.4,0.4)).round()


func _process(_delta):
	match Global.cursor_state:
		Global.CURSOR_STATE.MOVE:
			cursor.visible = false
		Global.CURSOR_STATE.BRUSH:
			cursor.visible = true
			if selection_start_pos == Vector3(): select.visible = false
		Global.CURSOR_STATE.SELECT:
			cursor.visible = true
			select.visible = true
			set_scale_to_selection()
	
	match Global.cursor_type:
		Global.CURSOR_TYPE.CURSOR:
			cursor.material_override = load("res://resources/drawable/m_cursor_brush.tres")
			select.material_override = load("res://resources/drawable/m_select_brush.tres")
			if box_mesh != null: cursor.mesh = box_mesh
		Global.CURSOR_TYPE.ADD:
			cursor.material_override = load("res://resources/drawable/m_cursor_spawn.tres")
			select.material_override = load("res://resources/drawable/m_select_spawn.tres")
			if Global.cursor_state != Global.CURSOR_STATE.SELECT:
				selection_start_pos = Vector3()
				selection_end_pos = Vector3()
			match Global.shape_id:
				0: 
					if box_mesh != null: cursor.mesh = box_mesh
					cursor.position.y = 0.0
				1: 
					if slope_mesh != null: cursor.mesh = slope_mesh
					cursor.position.y = 0.0
					cursor.rotation_degrees = Global.block_rotation
				2: 
					if half_mesh != null: cursor.mesh = half_mesh
					cursor.position.y = -0.25
		Global.CURSOR_TYPE.DELETE:
			cursor.material_override = load("res://resources/drawable/m_cursor_delete.tres")
			select.material_override = load("res://resources/drawable/m_select_delete.tres")
			if Global.cursor_state != Global.CURSOR_STATE.SELECT:
				selection_start_pos = Vector3()
				selection_end_pos = Vector3()
			if box_mesh != null: cursor.mesh = box_mesh


func set_scale_to_selection():
	select.position = (selection_start_pos + selection_end_pos) / 2
	select.scale = Vector3(1.02, 1.02, 1.02) + (selection_start_pos - selection_end_pos).abs()


func get_selection_positions():
	if selection_start_pos == Vector3.ZERO && selection_end_pos == Vector3.ZERO: return []
	var positions = []
	var size_x = 1 if selection_end_pos.x - selection_start_pos.x > 0 else -1
	var size_y = 1 if selection_end_pos.y - selection_start_pos.y > 0 else -1
	var size_z = 1 if selection_end_pos.z - selection_start_pos.z > 0 else -1
	for x in 1.0 if size_x == 0 else abs(selection_end_pos.x - selection_start_pos.x) + 1:
		for y in 1.0 if size_y == 0 else abs(selection_end_pos.y - selection_start_pos.y) + 1:
			for z in 1.0 if size_z == 0 else abs(selection_end_pos.z - selection_start_pos.z) + 1:
				var _x = selection_start_pos.x + size_x * x
				var _y = selection_start_pos.y + size_y * y
				var _z = selection_start_pos.z + size_z * z
				positions.append(Vector3(_x, _y, _z))
	return positions
