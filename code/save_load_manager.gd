extends RefCounted

class_name SaveLoadManager


# Save map in maps folder
static func save_map(data, chunks, is_data_resave = false):
	var path = OS.get_executable_path().get_base_dir() + "/maps"
	path += "/" + data["Name"]
	# Saving params dict
	var params : Dictionary = {
		"Name" : data["Name"], 
		"Creator" : data["Creator"], 
		"Song" : data["Song"], 
		"Artist" : data["Artist"], 
		"Length" : data["Length"], 
		"Start" : data["Start"], 
		"End" : data["End"],
		"BPM" : data["BPM"],
		"Mode" : data["Mode"],
		"Delay" : data["Delay"],
		"Difficult" : data["Difficult"],
		"BS" : data["BS"],
		"TD" : data["TD"],
		"PerfectTime" : data["PerfectTime"],
		"JumpsCount" : data["JumpsCount"]
	}
	
	# Open db
	var db = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns").new()
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	
	# Check if this map is exist and resave it
	db.query(str("SELECT * FROM Map WHERE Map.Name = \"", data["Name"], "\""))
	var result = db.query_result
	if result.size() > 0:
		if is_data_resave:
			# Resave data
			if !db.update_rows("Map", "Name = \"" + data["Name"] + "\"", params):
				printerr("Resave query failed in map save")
				return false
			
			# Delete all results
			if !db.delete_rows("Result", "IdMap = " + str(data["Id"])):
				printerr("Delete old results query failed in map save")
				return false
		
		if chunks == null: 
			db.close_db()
			return true
		
		# Save a map data file
		var file = File.new()
		file.open(path + "/data.nrmap", File.WRITE)
		params["Chunks"] = chunks
		file.store_var(params)
		file.close()
		db.close_db()
		return true
	
	# Add new db entry
	if !db.insert_row("Map", params): 
		printerr("Insert query failed in map save")
		return false
	
	db.close_db()
	
	if chunks == null: return true
	
	# Create a map folder
	var dir = Directory.new()
	dir.make_dir_recursive(path) 
	
	# Save a song file
	dir.copy(data["Song"], path + "/" + data["Song"].get_file())
	
	# Save a map data file
	var file = File.new()
	file.open(path + "/data.nrmap", File.WRITE)
	params["Chunks"] = chunks
	file.store_var(params)
	file.close()
	return true


# Delete map by id
static func delete_map(map_id):
	var db = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns").new()
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	
	# Delete folder
	db.query(str("SELECT * FROM Map WHERE Map.Id = ", map_id))
	var map_name = db.query_result[0]["Name"]
	var map_path = OS.get_executable_path().get_base_dir() + "/maps/" + map_name
	if OS.move_to_trash(map_path) != 0:
		printerr("Map folder delete is faled")
		return false
	
	# Delete row in db
	if !db.delete_rows("Map", str("Map.Id = ", map_id)):
		printerr("Map db row delete is faled")
		return false
	
	# Delete all results
	if !db.delete_rows("Result", str("IdMap = ", map_id)):
		printerr("Delete old results query failed in map save")
		return false
	
	db.close_db()
	return true


# Load map data from maps folder by name or id
static func load_map_data(map_name = null, id_map = null):
	if id_map != null && map_name == null: map_name = load_map_header(id_map)["Name"]
	
	var path = OS.get_executable_path().get_base_dir() + "/maps"
	path += "/" + map_name
	var file = File.new()
	file.open(path + "/data.nrmap", File.READ)
	var data = file.get_var()
	if data == null: return
	if !data.has("Chunks"): return
	return data


# Load map header data from db by id
static func load_map_header(id_map = null, name = null):
	var db = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns").new()
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	var map_header
	if id_map != null:
		db.query(str("select * from Map where Map.id = ", id_map))
		map_header = db.query_result[0]
	else: 
		db.query(str("select * from Map where Map.Name = \"", name, "\""))
		map_header = db.query_result[0]
	return map_header


static func save_result(data):
	var db = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns").new()
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	if !db.insert_row("Result", data): 
		printerr("Insert row failed in level_game result saving")
		return -1
	db.query(str("SELECT Id FROM Result WHERE Result.Positions = \'", data["Positions"], "\'"))
	var result_id = db.query_result[0]["Id"]
	db.close_db()
	return result_id


# Load result from db by id
static func load_result(result_id, is_delete_after = false):
	var db = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns").new()
	db.path = "user://user.db"
	db.verbosity_level = 0
	db.open_db()
	db.query(str("select * from Result where Result.Id = ", result_id))
	var result = db.query_result[0]
	if is_delete_after: db.delete_rows("Result", "Result.Id = " + str(result_id))
	db.close_db()
	return result
