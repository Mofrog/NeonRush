extends TextDatabase


func _initialize():
	add_mandatory_property("Creator", TYPE_STRING)
	add_mandatory_property("Song", TYPE_STRING)
	add_mandatory_property("Artist", TYPE_STRING)
	add_mandatory_property("Length", TYPE_FLOAT)
	add_mandatory_property("Start", TYPE_FLOAT)
	add_mandatory_property("End", TYPE_FLOAT)
	add_mandatory_property("BPM", TYPE_INT)
	add_mandatory_property("Mode", TYPE_INT)
	add_mandatory_property("Delay", TYPE_FLOAT)
	add_mandatory_property("Difficult", TYPE_FLOAT)
	add_mandatory_property("BS", TYPE_FLOAT)
	add_mandatory_property("TD", TYPE_FLOAT)
	add_mandatory_property("Time", TYPE_FLOAT)
	add_mandatory_property("jumps", TYPE_INT)
