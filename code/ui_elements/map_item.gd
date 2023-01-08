extends Control
class_name MapItem


signal selected(item)

export var map_data : Dictionary = {}


func _ready():
	$V/MapName.text = str(map_data["Name"], " - ", map_data["PerfectTime"], " sec.")
	$V/Song.text = str(map_data["Artist"], " - ", map_data["Song"].get_file().get_basename())
	$V/Difficult.value = float(map_data["Difficult"])


func _on_Btn_pressed(): emit_signal("selected", self)
