extends TextDatabase


func _initialize():
	entry_name = "IdMap"
	add_mandatory_property("Score", TYPE_INT)
	add_mandatory_property("Accuracy", TYPE_FLOAT)
	add_mandatory_property("Perfect", TYPE_INT)
	add_mandatory_property("Good", TYPE_INT)
	add_mandatory_property("Bad", TYPE_INT)
	add_mandatory_property("Miss", TYPE_INT)
	add_mandatory_property("Positions", TYPE_DICTIONARY)
	add_mandatory_property("Rotations", TYPE_DICTIONARY)
	add_mandatory_property("Jumps", TYPE_INT)
	add_mandatory_property("Time", TYPE_FLOAT)
	add_mandatory_property("Date", TYPE_STRING)
