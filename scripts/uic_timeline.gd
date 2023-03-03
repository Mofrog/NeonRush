extends Control

const slider_size = 100

var slider_editing = false
var is_timeline_generated = false

@onready var visible_slider = $C/C/VisibleSlider
@onready var time_slider = $C/C/TimeSlider


func _ready(): 
	visible_slider.max_value = slider_size
	time_slider.max_value = slider_size


func _process(_delta):
	if !is_timeline_generated:
		var current_size = 0.0
		while current_size < GlobalTime.max_time:
			var item = preload("res://scenes/uic_timeline_item.tscn").instantiate().duplicate()
			item.custom_minimum_size.x = (10.0 / slider_size * size.x) + 1
			item.get_node("Label").text = str(current_size + 5)
			$C/C/TimelineScroll/Times.add_child(item)
			current_size += 10.0
		is_timeline_generated = true
	
	if !slider_editing:
		$C/Header/Menu/L/Time.text = str(snapped(GlobalTime.time, 0.01))
		visible_slider.value = GlobalTime.time
		
		if visible_slider.min_value > GlobalTime.time \
		&& GlobalTime.time < 10:
			visible_slider.max_value = slider_size
			visible_slider.min_value = 0
		
		if GlobalTime.time_state == GlobalTime.TIME_STATE.TO_START:
			visible_slider.max_value = slider_size
			visible_slider.min_value = 0
		
		if GlobalTime.time_state == GlobalTime.TIME_STATE.TO_END:
			visible_slider.max_value = GlobalTime.max_time
			visible_slider.min_value = GlobalTime.max_time - slider_size
		
		if GlobalTime.time_state == GlobalTime.TIME_STATE.PLAY \
		&& visible_slider.max_value < GlobalTime.max_time \
		&& visible_slider.value > visible_slider.max_value - 5:
			visible_slider.max_value += 0.1
			visible_slider.min_value += 0.1
		
		if GlobalTime.time_state == GlobalTime.TIME_STATE.REVERSE \
		&& visible_slider.min_value > 0 \
		&& visible_slider.value < visible_slider.min_value + 5:
			visible_slider.max_value -= 0.1
			visible_slider.min_value -= 0.1
		
		if visible_slider.max_value < GlobalTime.time \
		&& GlobalTime.time > GlobalTime.max_time - 10:
			visible_slider.max_value = GlobalTime.max_time
			visible_slider.min_value = GlobalTime.max_time - slider_size
	
	if slider_editing:
		$C/Header/Menu/L/Time.text = str(snapped(visible_slider.value, 0.01))
		visible_slider.value = $C/C/TimeSlider.value
		
		if visible_slider.value < visible_slider.min_value + 1:
			visible_slider.min_value -= 1
			visible_slider.max_value -= 1
		if visible_slider.value > visible_slider.max_value - 1:
			visible_slider.min_value += 1
			visible_slider.max_value += 1
	
	if visible_slider.max_value > GlobalTime.max_time:
		visible_slider.max_value = GlobalTime.max_time
		visible_slider.min_value = GlobalTime.max_time - slider_size
	if visible_slider.min_value < 0: 
		visible_slider.max_value = slider_size
		visible_slider.min_value = 0
	
	time_slider.max_value = visible_slider.max_value
	time_slider.min_value = visible_slider.min_value
	
	$C/C/TimelineScroll.scroll_horizontal = \
		visible_slider.min_value / slider_size * size.x 
	
	$C/C/Grabber.position.x = \
		(visible_slider.value - visible_slider.min_value) \
		/ (visible_slider.max_value - visible_slider.min_value) \
		* size.x - 2.5
	
	if size.y < 40: $C/C.visible = false
	else: $C/C.visible = true


func _on_time_slider_drag_started():
	slider_editing = true
func _on_time_slider_drag_ended(_value_changed):
	GlobalTime.time = time_slider.value
	GlobalTime.replay_song()
	slider_editing = false
