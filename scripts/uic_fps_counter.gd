extends Control


@onready var text = $Label.text


func _process(_delta):
	if ProjectSettings.get_setting("config/is_fps_counter_enabled"):
		visible = true
	else:
		visible = false
	
	$Label.text = text.format({"FPS" : Engine.get_frames_per_second()})
