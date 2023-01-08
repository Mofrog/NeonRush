extends Control
class_name RytmRule

signal timeout

onready var time_manager = $TimeManager
onready var anim_player = $AnimationPlayer
onready var p_l = $p_l
onready var p_r = $p_r
onready var g_l = $g_l
onready var g_r = $g_r
onready var b_l = $b_l
onready var b_r = $b_r

export var beat_theme : Theme = null


# Area sizes and pos
var p_area_size : Vector2
var g_area_size : Vector2
var b_area_size : Vector2
var b_area_pos_l : Vector2
var g_area_pos_l : Vector2
var p_area_pos_l : Vector2


# Beat sett's
const beat_size = Vector2(6, 48)
const beat_pos_r = Vector2(200, -24)
const beat_pos_l = Vector2(-211.1, -24)
var beat_speed = 0.0
var beats : Array = []


func _exit_tree(): 
	for i in get_children():
		remove_child(i)
		i.queue_free()


func update_areas(td):
	# Area sizes 
	# 15.5 at 10 td, 36.(3) at 0 td
	p_area_size = Vector2(200 / (td + 6) + 3, 				60) 
	g_area_size = Vector2(p_area_size.x * 2, 				60)
	b_area_size = Vector2(g_area_size.x * 1.5, 				60)
	
	# Area pos
	var b_area_pos_r = Vector2(20, 							-30)
	b_area_pos_l = Vector2(-20 - b_area_size.x,				-30)
	var g_area_pos_r = Vector2((b_area_size.x / 2 - \
		g_area_size.x / 2) + b_area_pos_r.x,				-30)
	g_area_pos_l = Vector2(-(b_area_size.x / 2 - \
		g_area_size.x / 2) - b_area_pos_r.x - g_area_size.x,-30)
	var p_area_pos_r = Vector2((g_area_size.x / 2 - \
		p_area_size.x / 2) + g_area_pos_r.x,				-30)
	p_area_pos_l = Vector2(-(g_area_size.x / 2 - \
		p_area_size.x / 2) - g_area_pos_r.x - p_area_size.x,-30)
	
	init_area(p_l, p_area_size, p_area_pos_l)
	init_area(p_r, p_area_size, p_area_pos_r)
	init_area(g_l, g_area_size, g_area_pos_l)
	init_area(g_r, g_area_size, g_area_pos_r)
	init_area(b_l, b_area_size, b_area_pos_l)
	init_area(b_r, b_area_size, b_area_pos_r)


func init_area(area : Panel, size, pos):
	area.set_size(size)
	area.set_position(pos)
	area.set_pivot_offset(Vector2(size.x / 2, 30))


func init_manager(max_time, general_delay, bpm, bs, td):
	time_manager.max_time = max_time
	time_manager.set_bpm(bpm)
	time_manager.calc_delay(bs, td)
	time_manager.set_general_delay(general_delay)
	update_areas(td)
	# 800.07 at 10 bs, 100.07 at 0 bs
	beat_speed = 100 + (70 * (bs + 0.01 / 10)) 


func _physics_process(delta):
	for i in beats:
		if i["beat"] != null: 
			i["beat"].move(beat_speed * delta)
			i["double"].move(-beat_speed * delta)
			if i["beat"].rect_position.x + beat_size.x > -10: remove_beat(i)


func click():
	var max_score = 0
	var beat = null
	for i in beats:
		if i["beat"] != null: 
			# Check perfect timing
			if i["beat"].rect_position.x + beat_size.x > p_area_pos_l.x && \
			i["beat"].rect_position.x < p_area_pos_l.x + p_area_size.x:
				if max_score < 3:
					max_score = 3
					beat = i
			# Check good timing
			elif i["beat"].rect_position.x + beat_size.x > g_area_pos_l.x && \
			i["beat"].rect_position.x < g_area_pos_l.x + g_area_size.x:
				if max_score < 2:
					max_score = 2
					beat = i
			# Check bad timing
			elif i["beat"].rect_position.x + beat_size.x > b_area_pos_l.x && \
			i["beat"].rect_position.x < b_area_pos_l.x + b_area_size.x:
				if max_score < 1:
					max_score = 1
					beat = i
	
	if beat != null: remove_beat(beat)
	
	match max_score:
		3: 
			anim_player.play("p_pressed")
			return 300
		2: 
			anim_player.play("g_pressed")
			return 100
		1: 
			anim_player.play("b_pressed")
			return 50
		0: 
			return 0


func start(stream = null):
	time_manager.start(stream)


func stop(restart = false):
	if restart: clear_all()
	time_manager.stop(restart)


func remove_beat(beat):
	remove_child(beat["double"])
	beat["double"].queue_free()
	remove_child(beat["beat"])
	beat["beat"].queue_free()
	beats.erase(beat)


func clear_all(): 
	for i in beats: 
		remove_child(i["double"])
		i["double"].queue_free()
		remove_child(i["beat"])
		i["beat"].queue_free()
	beats.clear()


func spawn_beat():
	var l_b = Beat.new()
	var r_b = Beat.new()
	l_b.init(beat_theme, beat_size, beat_pos_l)
	r_b.init(beat_theme, beat_size, beat_pos_r)
	add_child(l_b)
	add_child(r_b)
	beats.append({
		"beat" : l_b,
		"double" : r_b
	})


# Level end
func _on_TimeManager_timeout(): emit_signal("timeout")


# Signalled on every beat
func _on_TimeManager_beat(): spawn_beat()
