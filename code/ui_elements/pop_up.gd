extends Control
class_name PopUp


@export var p_theme : Theme = load("res://art/themes/pop_up_theme.tres")
var is_stop_disabled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	anchor_bottom = 1
	anchor_left = 0
	anchor_right = 1
	anchor_top = 0
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	get_tree().paused = true


func _exit_tree():
	if is_stop_disabled: is_stop_disabled = false
	else: get_tree().paused = false


func accept_dialog(title, text, target, stop_disable = false):
	target.add_child(self)
	is_stop_disabled = stop_disable
	
	var dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.theme = p_theme
	dialog.anchor_bottom = 0.5
	dialog.anchor_left = 0.5
	dialog.anchor_right = 0.5
	dialog.anchor_top = 0.5
	dialog.offset_left = -100
	dialog.offset_right = 100
	
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog.visible = true
	dialog.window_title = title
	dialog.dialog_text = text
	
	dialog.connect("hide",Callable(self,"_exit_dialog"))


func confirm_dialog(title, text, target, cancel_method, ok_method, stop_disable = false):
	target.add_child(self)
	is_stop_disabled = stop_disable
	
	var dialog = ConfirmationDialog.new()
	add_child(dialog)
	dialog.theme = p_theme
	dialog.anchor_bottom = 0.5
	dialog.anchor_left = 0.5
	dialog.anchor_right = 0.5
	dialog.anchor_top = 0.5
	dialog.offset_left = -100
	dialog.offset_right = 100
	
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog.visible = true
	dialog.window_title = title
	dialog.dialog_text = text
	
	if cancel_method != null: dialog.get_cancel_button().connect("pressed",Callable(target,cancel_method))
	if ok_method != null: dialog.get_ok_button().connect("pressed",Callable(target,ok_method))
	dialog.connect("hide",Callable(self,"_exit_dialog"))


func _exit_dialog():
	get_parent().remove_child(self)
	queue_free()
