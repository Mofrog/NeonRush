extends Control


onready var c_base_debug = $BaseDebug
onready var c_debug = $Debug

onready var base_debug = $BaseDebug/Label
onready var base_debug_text = base_debug.text
onready var debug = $Debug/Label
onready var debug_text = debug.text

var ver = ProjectSettings.get_setting("config/version")
var is_debug_enabled = ProjectSettings.get_setting("config/is_debug_enabled")

var debug_params : Array = []
var params_targed : Object = null


func _ready():
	if is_debug_enabled: 
		c_base_debug.visible = false
		c_debug.visible = true


func _process(_delta):
	if !is_debug_enabled:
		base_debug.text = base_debug_text.format({
			"Ver" : ver
		})
	else:
		var r_text = ""
		r_text += debug_text.get_slice("\n", 0).format({
			"Ver" : ver
		})
		r_text += "\n"
		for i in debug_params.size():
			if debug_params[i] in params_targed: 
				r_text += debug_text.get_slice("\n", i + 1).format({
					debug_params[i] : params_targed.get(debug_params[i])
				})
				if i + 1 < debug_params.size(): r_text += "\n"
		debug.text = r_text


func init_debug(params : Array, target : Object):
	debug_params = params
	params_targed = target
	for param in debug_params:
		if param in params_targed:
			debug_text += str("\n", param.capitalize(), ": ", "{", param, "}")
