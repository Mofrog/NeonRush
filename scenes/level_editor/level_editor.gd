extends Node3D


@onready var character = $Character
@onready var cursor = $Cursor
@onready var grid = $Grid
@onready var voxel_world = $VoxelWorld


func _process(_delta):
	cursor.calc_position(character.ray_cast())
	
	match Global.grid_axis:
		Global.GRID_AXIS.X:
			grid.position.x = character.position.ceil().x
			grid.position.y = Global.grid_height + 0.05
			grid.position.z = character.position.ceil().z
			grid.set_rotation_degrees(Vector3(0, 0, 0))
		Global.GRID_AXIS.Y:
			grid.position.x = character.position.ceil().x
			grid.position.y = character.position.ceil().y
			grid.position.z = Global.grid_height + 0.05
			grid.set_rotation_degrees(Vector3(90, 0, 0))
		Global.GRID_AXIS.Z:
			grid.position.x = Global.grid_height + 0.05
			grid.position.y = character.position.ceil().y
			grid.position.z = character.position.ceil().z
			grid.set_rotation_degrees(Vector3(0, 0, 90))


func _unhandled_input(event):
	# Selection
	if event is InputEventMouseMotion && Input.is_action_pressed("editor_interact"):
		if Global.cursor_state == Global.CURSOR_STATE.BRUSH:
			Global.cursor_state = Global.CURSOR_STATE.SELECT
			cursor.selection_start_pos = cursor.cursor.position
		cursor.selection_end_pos = cursor.cursor.position
	
	if Input.is_action_just_released("editor_interact"):
		match Global.cursor_type:
			Global.CURSOR_TYPE.CURSOR:
				pass
			Global.CURSOR_TYPE.ADD:
				place_blocks()
			Global.CURSOR_TYPE.DELETE:
				place_blocks(true)
		Global.cursor_state = Global.CURSOR_STATE.BRUSH


func place_blocks(is_delete = false):
	var positions = cursor.get_selection_positions()
	var chunks = []
	var check_array = []
	for i in positions:
		if is_delete: check_array.append(voxel_world.delete_block(i))
		else: check_array.append(voxel_world.add_block(i, Global.texture_id, 0))
		var chunk = VoxelMath.get_chunk_pos(i)
		if !(chunk in chunks): chunks.append(chunk)
	if check_array.all(is_false): return
	for i in chunks:
		voxel_world.create_chunk(i)
		voxel_world.commit_chunk(i)

func is_false(item): return !item


#-------------------------------FUNC'S------------------------------------------
#func _ready(): add_child(StartEnd.new())
#
#
#func _exit_tree():
#	if thread.is_active(): thread.wait_to_finish()
#
#
#func _process(_delta): 
#	setting_cursor()
#	setting_grid()
#	set_scale_to_selection(selection)
#	update_character_position()
#
#	if character.b_type == 1 && type == TYPE.SPAWN && object == OBJECT.BLOCK: 
#		preview.visible = true
#	else: preview.visible = false
#
#	if ProjectSettings.get_setting("global/is_on_ui"): return
#	if Input.is_action_just_released("editor_action_primary"):
#		if character.is_cancel: return
#		match type:
#			# TODO Add blocks selection mechanic
#			TYPE.SPAWN:
#				match object:
#					OBJECT.BLOCK:
#						spawn_in_area()
#					OBJECT.OBJECT:
#						spawn_in_area()
#				character.reset_selection()
#			TYPE.DELETE:
#				match object:
#					OBJECT.BLOCK:
#						delete_in_area()
#					OBJECT.OBJECT:
#						delete_in_area()
#				character.reset_selection()
#
#
## set varius grafical settings to cursor
#func setting_cursor():
#	if character.is_cancel:
#		cursor.visible = false
#		selection.visible = false
#		return
#
#	# cursor location
#	if character.cursor_pos_cubic != null:
#		cursor.position = character.cursor_pos_cubic - Vector3(0.5,0.5,0.5)
#
#	# editor state
#	match character.state:
#		0:
#			cursor.visible = true
#			if type == TYPE.SELECT && selection.position != Vector3(-0.5, -0.5, -0.5): 
#				selection.visible = true
#			else: selection.visible = false
#		2:
#			cursor.visible = false
#			if type == TYPE.SELECT && selection.position != Vector3(-0.5, -0.5, -0.5): 
#				selection.visible = true
#			else: selection.visible = false
#		1:
#			cursor.visible = true
#			selection.visible = true
#
#	# cursor type
#	match type:
#		TYPE.SELECT:
#			cursor.material_override = load("res://art/materials/m_cursor_brush.tres")
#			selection.material_override = load("res://art/materials/m_select_brush.tres")
#		TYPE.SPAWN:
#			cursor.material_override = load("res://art/materials/m_cursor_spawn.tres")
#			selection.material_override = load("res://art/materials/m_select_spawn.tres")
#		TYPE.DELETE:
#			cursor.material_override = load("res://art/materials/m_cursor_delete.tres")
#			selection.material_override = load("res://art/materials/m_select_delete.tres")
#
#
## set current grid axis and offset
#func setting_grid():
#	grid.position = character.cursor_pos_cubic
#	match grid_axis:
#		GRID_AXIS.X:
#			grid.rotation_degrees = Vector3(0, 0, 0)
#			grid.position.y = character.grid_offset + 0.05
#			grid.grid_axis = 0
#		GRID_AXIS.Y:
#			grid.rotation_degrees = Vector3(90, 0, 0)
#			grid.position.z = character.grid_offset + 0.05
#			grid.grid_axis = 1
#		GRID_AXIS.Z:
#			grid.rotation_degrees = Vector3(0, 0, 90)
#			grid.position.x = character.grid_offset + 0.05
#			grid.grid_axis = 2
#
#
## set object scale and position to selection area
#func set_scale_to_selection(_object):
#	if character.selection_start_pos != null && character.selection_end_pos != null:
#		_object.position = (character.selection_start_pos + \
#			character.selection_end_pos) / 2
#		_object.position -= Vector3(0.5, 0.5, 0.5)
#		_object.scale = Vector3.ONE \
#			+ (character.selection_start_pos - character.selection_end_pos).abs() / 2
#		_object.scale -= Vector3(0.45, 0.45, 0.45)
#
#
## perform methods every walked chunk
#func update_character_position():
#	if last_character_position == null:
#		last_character_position = character.position
#	var size = ProjectSettings.get_setting("generation/chunk_size")
#	if last_character_position.distance_to(character.position) >= size.x:
#		last_character_position = character.position
#		if thread.is_active() && !thread.is_alive(): thread.wait_to_finish()
#		thread.start(Callable(chunks,"update_chunks_visibility").bind(character))
#

# Set mesh_replay_center character location at current time
#func update_replay_pos(time : float):
#	var id_pos = int(time / 0.05)
#	if replay_pos.size() > id_pos: 
#		mesh_replay_center.position = str_to_var("Vector3" + replay_pos[id_pos])
#		var rot = str_to_var("Vector3" + replay_rot[id_pos])
#		mesh_replay_center.rotate_y(rot.y - mesh_replay_center.rotation.y)
#		mesh_rot_center.rotate_x(rot.x - mesh_rot_center.rotation.x)
#
#
# Create mesh_replay_center visible line path
#func draw_visual_path():
#	if result_id == -1: return
#	var result = SaveLoadManager.load_result(result_id, true)
#	ProjectSettings.set_setting("global/result_id", -1)
#	var test_json_conv = JSON.new()
#	test_json_conv.parse(result["Positions"])
#	replay_pos = test_json_conv.get_data()
#	test_json_conv = JSON.new()
#	test_json_conv.parse(result["Rotations"])
#	replay_rot = test_json_conv.get_data()
#
#	# Generate visible line path
#	var mesh = Mesh.new()
#	var mesh_instance = MeshInstance3D.new()
#	var st = SurfaceTool.new()
#	st.begin(Mesh.PRIMITIVE_LINE_STRIP) 
#	for i in replay_pos.size():
#		st.add_vertex(str_to_var("Vector3" + replay_pos[i]))
#	st.set_material(load("res://art/materials/m_visual_path.tres"))
#	st.commit(mesh)
#	mesh_instance.set_mesh(mesh)
#	add_child(mesh_instance)
#	mesh_replay_center.visible = true
#
#
#func rotate_preview():
#	preview.rotation_degrees.y += 90
#	if preview.rotation_degrees.y > 360: preview.rotation_degrees.y = 90
#
#
## deleting all blocks in selected area
#func delete_in_area():
#	var positions = get_selection_positions(character.selection_start_pos, \
#		character.selection_end_pos)
#	chunks.erase_block(positions)
#
#
## action that add blocks to selected area
#func spawn_in_area():
#	var positions = get_selection_positions(character.selection_start_pos, \
#		character.selection_end_pos)
#	if character.id_obj == 0 && object == OBJECT.OBJECT:
#		if !ProjectSettings.get_setting("global/is_end_valid"): 
#			ProjectSettings.set_setting("global/is_end_valid", true)
#			chunks.place_block(positions, character.b_rot, character.id_tex, \
#			character.b_type, character.id_obj)
#		return
#	chunks.place_block(positions, character.b_rot, character.id_tex, \
#	character.b_type, character.id_obj)
