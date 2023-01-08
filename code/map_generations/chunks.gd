extends Spatial

# FIXME Fix rare data dubles in block spawn
# FIXME Fix rare data loss in block spawn and movement
# FIXME Fix severe memory leak in collision generation
# FIXME Fix light memory leak in geometry generation


const chunk_scene = preload("res://code/map_generations/chunk.tscn")

# key - position;
# value - blocks dict
var chunks : Dictionary = {}

# key - position; value - mesh instance
var geometry = {}


#----------------------------------UTILITE FUNC'S-------------------------------
# calculate theorytically chunk position from coordinates
func calc_chunk_position(pos):
	var size = ProjectSettings.get_setting("config/chunk_size")
	return Vector3(floor(pos.x / size.x), \
	floor(pos.y / size.y), floor(pos.z / size.z))


# get chunk from position
func get_chunk_in_position(pos):
	var chunk_name = str(pos.x, "_", pos.y, "_", pos.z)
	var chunk_to_edit = get_node_or_null(str(chunk_name))
	return chunk_to_edit


func delete_all_chunks():
	chunks.clear()
	for i in get_children():
		remove_child(i)
		i.free()

#----------------------------------EDIT FUNC'S----------------------------------
# place blocks in positions
func place_block(array_of_pos, r = 0, t = 0, p = 0, o = -1):
	var count = 0
	
	var chunks_to_update = []
	for pos in array_of_pos:
		var chunk_pos = calc_chunk_position(pos)
		var chunk_to_edit = get_chunk_in_position(chunk_pos)
		
		#if chunk does not exists, then create chunk
		if chunk_to_edit == null:
			var chunk_instance = chunk_scene.instance().duplicate()
			chunk_instance.name = str(chunk_pos.x, "_", chunk_pos.y, "_", chunk_pos.z)
			chunk_instance.position = chunk_pos
			add_child(chunk_instance)
			chunk_to_edit = chunk_instance
			chunk_to_edit.blocks[pos] = {
				"r" : r,
				"t" : t,
				"p" : p,
				"o" : o 
			}
			count += 1
		else:
			# if block doesn't found spawn new
			if !chunk_to_edit.blocks.has(pos):
				# warning-ignore:return_value_discarded
				chunks.erase(chunk_pos)
				chunk_to_edit.blocks[pos] = {
					"r" : r,
					"t" : t,
					"p" : p,
					"o" : o 
				}
				count += 1
		
		# add current chunk to updating array
		if chunks_to_update.find(chunk_to_edit) == -1:
			chunks_to_update.append(chunk_to_edit)
	
	if count > 0: 
		for chunk in chunks_to_update: 
			chunk.generate_mesh()
			chunks[chunk.position] = chunk.blocks


# erasing blocks in positions
func erase_block(array_of_pos):
	var chunks_to_update = []
	for pos in array_of_pos:
		var chunk_to_edit = get_chunk_in_position(calc_chunk_position(pos))
		
		#if chunk does not exists, skip this block
		if chunk_to_edit == null: continue
		
		if chunk_to_edit.blocks.has(pos):
# warning-ignore:return_value_discarded
			chunks.erase(calc_chunk_position(pos))
			chunk_to_edit.blocks.erase(pos)
		else: continue
		
		# if chunk without blocks, delete it
		if chunk_to_edit.blocks.size() == 0:
			chunks_to_update.erase(chunk_to_edit)
			remove_child(chunk_to_edit)
			chunk_to_edit.call_deferred("free")
			continue
		
		# add current chunk to updating array
		if chunks_to_update.find(chunk_to_edit) == -1:
			chunks_to_update.append(chunk_to_edit)
	
	for chunk in chunks_to_update: 
		chunk.generate_mesh()
		chunks[chunk.position] = chunk.blocks


#-------------------------------SAVE AND UPDATE FUNC'S--------------------------
func generate_chunks(character):
	for pos in chunks.keys():
		var chunk_instance = chunk_scene.instance().duplicate()
		chunk_instance.position = pos
		chunk_instance.blocks = chunks[pos].duplicate(true)
		call_deferred("add_child", chunk_instance)
		var is_game = character is preload("res://scenes/level_game/character_game.gd")
		geometry[pos] = chunk_instance.generate_mesh(is_game)
		remove_child(chunk_instance)
		chunk_instance.queue_free()


func spawn_chunk(current_pos, update_collsion = false):
	if chunks.has(current_pos):
		var chunk_instance = chunk_scene.instance().duplicate()
		chunk_instance.name = str(current_pos.x, "_", current_pos.y, "_", current_pos.z)
		chunk_instance.position = current_pos
		chunk_instance.blocks = chunks[current_pos].duplicate(true)
		call_deferred("add_child", chunk_instance)
		if !geometry.has(current_pos): geometry[current_pos] = null
		chunk_instance.generate_mesh(update_collsion, geometry[current_pos])


# update all chunks visibility by character visible radius
func update_chunks_visibility(character):
	for pos in chunks.keys():
		var char_pos = calc_chunk_position(character.translation)
		var radius = pos.distance_to(char_pos)
		var chunk_instance = get_chunk_in_position(pos)
		var visible_radius = ProjectSettings.get_setting("config/visible_radius")
		
		if radius <= visible_radius && chunk_instance == null:
			if character is preload("res://scenes/level_game/character_game.gd"):
				spawn_chunk(pos,true)
			else: 
				spawn_chunk(pos)
		elif radius > visible_radius && chunk_instance != null:
			remove_child(chunk_instance)
			chunk_instance.queue_free()
