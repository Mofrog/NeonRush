extends RefCounted
class_name VoxelMath


#const vertices = [
#	Vector3(0,0,0), 0
#	Vector3(1,0,0), 1
#	Vector3(0,1,0), 2
#	Vector3(1,1,0), 3 
#	Vector3(0,0,1), 4
#	Vector3(1,0,1), 5
#	Vector3(0,1,1), 6
#	Vector3(1,1,1)  7
#]
#const TOP_FACE = 		[Vector3(0,1,0),Vector3(1,1,0),Vector3(1,1,1),Vector3(0,1,1)]
#const BOTTOM_FACE = 	[Vector3(0,0,0),Vector3(0,0,1),Vector3(1,0,1),Vector3(1,0,0)]
#const LEFT_FACE = 		[Vector3(0,1,1),Vector3(0,0,1),Vector3(0,0,0),Vector3(0,1,0)]
#const RIGHT_FACE = 	[Vector3(1,1,0),Vector3(1,0,0),Vector3(1,0,1),Vector3(1,1,1)]
#const FRONT_FACE = 	[Vector3(0,1,0),Vector3(0,0,0),Vector3(1,0,0),Vector3(1,1,0)]
#const BACK_FACE = 		[Vector3(1,1,1),Vector3(1,0,1),Vector3(0,0,1),Vector3(0,1,1)]
#const SLOPE_VERT = 	[Vector3(0,1,0),Vector3(1,1,0),Vector3(1,0,1),Vector3(0,0,1)]
#const SLOPE_LEFT = 	LEFT_FACE	#Triangle_2
#const SLOPE_RIGHT = 	RIGHT_FACE	#Triangle_1


static func get_chunk_pos(block_position):
	var chunk_size = ProjectSettings.get_setting("generation/chunk_size")
	return Vector3(\
	floor(block_position.x / chunk_size.x), \
	floor(block_position.y / chunk_size.y), \
	floor(block_position.z / chunk_size.z))


static func create_chunk(chunk_position, chunks_array):
	var blocks = chunks_array[chunk_position]["b"]
	var returns = {
		"v" : PackedVector3Array(),
		"u" : PackedVector2Array()
	}
	
	var vectors = [Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK]
	var near_blocks = PackedVector3Array(blocks.keys())
	for i in vectors:
		if chunk_position + i in chunks_array:
			near_blocks.append_array(chunks_array[chunk_position + i]["b"].keys())
	
	for block_position in blocks:
		if blocks[block_position]["t"] != -1:
			var data = _create_block(block_position, blocks[block_position], near_blocks)
			returns["v"].append_array(data["v"])
			returns["u"].append_array(data["u"])
	return returns


static func _create_block(block_position, block, blocks):
	const TOP_FACE = 	[Vector3(0,1,0),Vector3(1,1,0),Vector3(1,1,1),Vector3(0,1,1)]
	const DOWN_FACE = 	[Vector3(0,0,0),Vector3(0,0,1),Vector3(1,0,1),Vector3(1,0,0)]
	const LEFT_FACE = 	[Vector3(0,1,0),Vector3(0,1,1),Vector3(0,0,1),Vector3(0,0,0)]
	const RIGHT_FACE =	[Vector3(1,1,0),Vector3(1,0,0),Vector3(1,0,1),Vector3(1,1,1)]
	const FRONT_FACE =	[Vector3(0,1,0),Vector3(0,0,0),Vector3(1,0,0),Vector3(1,1,0)]
	const BACK_FACE = 	[Vector3(1,1,1),Vector3(1,0,1),Vector3(0,0,1),Vector3(0,1,1)]
	const SLOPE_VERT = 	[Vector3(0,1,0),Vector3(1,1,0),Vector3(1,0,1),Vector3(0,0,1)]
	const FACES = [TOP_FACE,DOWN_FACE,LEFT_FACE,RIGHT_FACE,FRONT_FACE,BACK_FACE]
	const VECTORS = [Vector3.UP,Vector3.DOWN,Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK]
	
	var returns = {
		"v" : PackedVector3Array(),
		"u" : PackedVector2Array()
	}
	
	match block["s"]:
		0:
			for i in VECTORS.size():
				_c(FACES[i], block_position, block["t"], returns)
		1:
			_c(SLOPE_VERT, block_position, block["t"], returns)
			_c(DOWN_FACE, block_position, block["t"], returns)
			var data = _create_face(LEFT_FACE, block_position, block["t"])
			returns["v"].append_array(data["Triangle_2"])
			returns["u"].append_array(data["UV_2"])
			data = _create_face(RIGHT_FACE, block_position, block["t"])
			returns["v"].append_array(data["Triangle_1"])
			returns["u"].append_array(data["UV_1"])
			_c(FRONT_FACE, block_position, block["t"], returns)
			block_position += Vector3(0.5, 0.5, 0.5)
			for i in returns["v"].size():
				returns["v"][i] = (returns["v"][i] - block_position).rotated(Vector3.UP, deg_to_rad(block["r"].z)) + block_position
				returns["v"][i] = (returns["v"][i] - block_position).rotated(Vector3.FORWARD, deg_to_rad(block["r"].y)) + block_position
				returns["v"][i] = (returns["v"][i] - block_position).rotated(Vector3.RIGHT, deg_to_rad(block["r"].x)) + block_position
	
	
	return returns


static func _c(face, pos, id_tex, returns):
	var data = _create_face(face, pos, id_tex)
	returns["v"].append_array(data["Triangle_1"] + data["Triangle_2"])
	returns["u"].append_array(data["UV_1"] + data["UV_2"])


static func _create_face(face, block_position, id_tex):
	var a = face[0] + block_position
	var b = face[1] + block_position
	var c = face[2] + block_position
	var d = face[3] + block_position
	
	var _texture = _get_texture(id_tex)
	
	var uv_a = _texture["pos"] + Vector2(_texture["sep"].x, _texture["sep"].y)
	var uv_b = _texture["pos"] + Vector2(_texture["sep"].x, _texture["size"].y - _texture["sep"].y)
	var uv_c = _texture["pos"] + Vector2(_texture["size"].x - _texture["sep"].x, _texture["size"].y - _texture["sep"].y)
	var uv_d = _texture["pos"] + Vector2(_texture["size"].x - _texture["sep"].x, _texture["sep"].y)
	
	return {
		"Triangle_1" : [a,b,c],
		"UV_1" : [uv_a,uv_b,uv_c],
		"Triangle_2" : [a,c,d],
		"UV_2" : [uv_a,uv_c,uv_d]
	}


static func _get_texture(id_tex):
	# Texture2D size (px) : Always square
	var tex_px = Vector2(256.0, 256.0)
	# Atlas size (px)
	var atlas_size = Vector2(2560, 2560) 
	# Atlas separation between textures (px)
	var sep_px = Vector2(0, 0)
	# Texture2D real size (px)
	var real_size = tex_px + sep_px * 2
	# Texture2D size (abs)
	var tex_abs = Vector2(real_size.x / atlas_size.x, real_size.y / atlas_size.y) 
	# Atlas separation between textures (abs)
	var sep_abs = Vector2(sep_px.x / atlas_size.x, sep_px.y / atlas_size.y)
	# Texture2D position (abs)
	var tex_coords = Vector2(real_size.x * id_tex / atlas_size.x, 0)
	
	return {
		"size" : tex_abs,
		"sep" : sep_abs,
		"pos" : tex_coords
	}
