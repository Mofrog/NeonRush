extends Control

var is_grid_height_change = false

func _process(_delta):
	if !is_grid_height_change:
		$C/C/C/Body/Right/OnScreen/CLeft/GridHeight.value = Global.grid_height
		$C/C/C/Body/Right/OnScreen/CLeft/TxtGridHeight.text = str(Global.grid_height)
	else:
		$C/C/C/Body/Right/OnScreen/CLeft/TxtGridHeight.text = str($C/C/C/Body/Right/OnScreen/CLeft/GridHeight.value)
		Global.grid_height = $C/C/C/Body/Right/OnScreen/CLeft/GridHeight.value
	$C/C/C/Body/Right/C/Header/Menu/L/X/C/GridRotationX.text = str(Global.block_rotation.x)
	$C/C/C/Body/Right/C/Header/Menu/L/Y/C/GridRotationY.text = str(Global.block_rotation.y)
	$C/C/C/Body/Right/C/Header/Menu/L/Z/C/GridRotationZ.text = str(Global.block_rotation.z)


func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui_main.tscn")


func _on_c_mouse_entered():
	$C/C/C/Body/Right/C/C.grab_focus()


# Cursor type
func _on_btn_cursor_toggled(button_pressed):
	if button_pressed: Global.cursor_type = Global.CURSOR_TYPE.CURSOR
func _on_btn_add_toggled(button_pressed):
	if button_pressed: Global.cursor_type = Global.CURSOR_TYPE.ADD
func _on_btn_delete_toggled(button_pressed):
	if button_pressed: Global.cursor_type = Global.CURSOR_TYPE.DELETE


# Grid axis
func _on_btn_grid_x_toggled(button_pressed):
	if button_pressed: Global.grid_axis = Global.GRID_AXIS.X
func _on_btn_grid_y_toggled(button_pressed):
	if button_pressed: Global.grid_axis = Global.GRID_AXIS.Y
func _on_btn_grid_z_toggled(button_pressed):
	if button_pressed: Global.grid_axis = Global.GRID_AXIS.Z


# Grid height
func _on_btn_grid_up_pressed():
	Global.grid_height += 1
func _on_btn_grid_down_pressed():
	Global.grid_height -= 1
func _on_grid_height_drag_started():
	is_grid_height_change = true
func _on_grid_height_drag_ended(_value_changed):
	Global.grid_height = $C/C/C/Body/Right/OnScreen/CLeft/GridHeight.value
	is_grid_height_change = false
	$C/C/C/Body/Right/C/C.grab_focus()


# Block type
func _on_btn_blocks_toggled(button_pressed):
	if button_pressed: $C/C/C/Body/Left/C/Header/Menu/Label.text = tr("E_Block_Select")
	$"C/C/C/Body/Left/C/ScrollContainer/С/ItemList".visible = true
	$"C/C/C/Body/Left/C/ScrollContainer/С/ShapeList".visible = false
	$"C/C/C/Body/Left/C/ScrollContainer/С/ObjectList".visible = false
func _on_btn_shapes_toggled(button_pressed):
	if button_pressed: $C/C/C/Body/Left/C/Header/Menu/Label.text = tr("E_Shape_Select")
	$"C/C/C/Body/Left/C/ScrollContainer/С/ItemList".visible = false
	$"C/C/C/Body/Left/C/ScrollContainer/С/ShapeList".visible = true
	$"C/C/C/Body/Left/C/ScrollContainer/С/ObjectList".visible = false
func _on_btn_objects_toggled(button_pressed):
	if button_pressed: $C/C/C/Body/Left/C/Header/Menu/Label.text = tr("E_Object_Select")
	$"C/C/C/Body/Left/C/ScrollContainer/С/ItemList".visible = false
	$"C/C/C/Body/Left/C/ScrollContainer/С/ShapeList".visible = false
	$"C/C/C/Body/Left/C/ScrollContainer/С/ObjectList".visible = true
func _on_item_list_item_selected(index):
	Global.texture_id = index
func _on_shape_list_item_selected(index):
	Global.shape_id = index
func _on_object_list_item_selected(index):
	Global.object_id = index


# Block rotation
func _on_grid_rotation_x_pressed():
	Global.block_rotation.x = 0
func _on_btn_rotate_x_pressed():
	Global.block_rotation.x += 90
	if Global.block_rotation.x >= 360:
		Global.block_rotation.x = 0
func _on_grid_rotation_y_pressed():
	Global.block_rotation.y = 0
func _on_btn_rotate_y_pressed():
	Global.block_rotation.y += 90
	if Global.block_rotation.y >= 360:
		Global.block_rotation.y = 0
func _on_grid_rotation_z_pressed():
	Global.block_rotation.z = 0
func _on_btn_rotate_z_pressed():
	Global.block_rotation.z += 90
	if Global.block_rotation.z >= 360:
		Global.block_rotation.z = 0
func _on_grid_rotation_zero_pressed():
	Global.block_rotation = Vector3.ZERO


# Timeline
func _on_btn_to_start_toggled(button_pressed):
	if button_pressed: GlobalTime.time_state = GlobalTime.TIME_STATE.TO_START
func _on_btn_reverse_toggled(button_pressed):
	if button_pressed: GlobalTime.time_state = GlobalTime.TIME_STATE.REVERSE
func _on_btn_stop_toggled(button_pressed):
	if button_pressed: GlobalTime.time_state = GlobalTime.TIME_STATE.STOP
func _on_btn_play_toggled(button_pressed):
	if button_pressed: GlobalTime.time_state = GlobalTime.TIME_STATE.PLAY
func _on_btn_to_end_toggled(button_pressed):
	if button_pressed: GlobalTime.time_state = GlobalTime.TIME_STATE.TO_END
