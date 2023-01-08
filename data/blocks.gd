# TODO Add texture db connection

extends Object
class_name Blocks


const textures : Dictionary = {
	"tiles_small" : {
		"black" : Vector2(0,0),
		"black_emi" : Vector2(1,0),
		"white" : Vector2(2,0),
		"white_emi" : Vector2(3,0),
		"chess" : Vector2(5,0)
	},
	"tiles_xsmall" : 1,
	"logs" : 2,
	"bricks" : 3
}


const objects : Dictionary = {
	"end" : "res://code/map_objects/start_end.tscn",
	"springboard_light" : "res://code/map_objects/springboard_1.tscn",
	"springboard_med" : "res://code/map_objects/springboard_2.tscn"
}
