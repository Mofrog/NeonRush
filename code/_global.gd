extends Node


var is_mouse_trail_disable = false

enum CURSOR_STATE { MOVE, BRUSH, SELECT }
var cursor_state : CURSOR_STATE = CURSOR_STATE.BRUSH


# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.new().load_settings()
