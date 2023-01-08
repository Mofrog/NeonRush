extends HBoxContainer

@export var max_time = 100.0

@onready var b_to_start = $BtnToStart
@onready var b_inverse = $BtnInverse
@onready var b_stop = $BtnStop
@onready var b_start = $BtnStart
@onready var b_to_end = $BtnToEnd
@onready var txt_time = $TxtTime
@onready var txt_start = $TxtStart
@onready var txt_end = $TxtEnd
@onready var timeline = $Timeline
@onready var manager = $TimeManager

var stream = null


func _ready():
	ProjectSettings.set_setting("global/timeline", self)


func _process(_delta):
	txt_time.value = manager.time
	timeline.value = manager.time


func set_max(time):
	max_time = time
	txt_end.text = str("End: ", max_time)
	txt_time.max_value = max_time
	timeline.max_value = max_time
	manager.max_time = max_time


func _on_BtnToStart_pressed():
	manager.to_point(0.0)
	b_stop.visible = false
	b_inverse.visible = true
	b_start.visible = true


func _on_BtnInverse_pressed():
	manager.inverse()
	b_stop.visible = true
	b_inverse.visible = false
	b_start.visible = false


func _on_BtnStop_pressed():
	manager.stop()
	b_stop.visible = false
	b_inverse.visible = true
	b_start.visible = true


func _on_BtnStart_pressed():
	manager.start(stream)
	b_stop.visible = true
	b_inverse.visible = false
	b_start.visible = false


func _on_BtnToEnd_pressed():
	manager.to_point(max_time)
	b_stop.visible = false
	b_inverse.visible = true
	b_start.visible = true
