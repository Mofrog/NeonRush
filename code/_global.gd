extends Node


var is_mouse_trail_disable = false

enum CURSOR_STATE { MOVE, BRUSH, SELECT }
var cursor_state : CURSOR_STATE = CURSOR_STATE.BRUSH

enum CURSOR_TYPE { CURSOR, ADD, DELETE }
var cursor_type : CURSOR_TYPE = CURSOR_TYPE.CURSOR

enum GRID_AXIS { X, Y, Z }
var grid_axis : GRID_AXIS = GRID_AXIS.X

var grid_height = 0

var texture_id = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	Settings.new().load_settings()
