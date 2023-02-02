extends Node3D


@onready var select = $Select
@onready var cursor = $Cursor

var selection_start_pos = Vector3()
var selection_end_pos = Vector3()


func calc_position(intersection):
	if !intersection.is_empty():
		cursor.position = intersection["position"].round()


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


func set_scale_to_selection():
	select.position = (selection_start_pos + selection_end_pos) / 2
	select.scale = Vector3.ONE + (selection_start_pos - selection_end_pos).abs()
