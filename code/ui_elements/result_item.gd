extends Control

signal selected(item)

onready var rank = $HBoxContainer/Rank
onready var about = $HBoxContainer/About
onready var grade = $HBoxContainer/Grade


export var map_data : Dictionary = {}
export var result_data : Dictionary = {}
export var result_rank = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	var t_m = GameMath.calc_time_mult(result_data["Time"], map_data["PerfectTime"])
	var j_m = GameMath.calc_jumps_mult(result_data["Jumps"], map_data["JumpsCount"])
	var a_m = GameMath.calc_acc_mult(result_data["Accuracy"])
	var s_m = GameMath.get_score_mult(t_m, j_m, a_m)
	
	rank.text = rank.text.format({"0" : str(result_rank)}) 
	about.text = about.text.format({
		"User" : "local",
		"Score" : stepify(result_data["Score"], 1),
		"Multiplier" : stepify(s_m, 0.001)
	})
	grade.text = GameMath.get_grade(s_m)["Grade"]


func _on_Btn_pressed(): emit_signal("selected", self)
