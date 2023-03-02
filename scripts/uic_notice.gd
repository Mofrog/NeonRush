extends Control


var notice_text = "Notice"
var life_time = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	$C/C/Text.text = notice_text
	$Timer.wait_time = life_time
	$Timer.start()


func _on_timer_timeout():
	get_parent().remove_child(self)
	queue_free()
