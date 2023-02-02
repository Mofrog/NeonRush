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
#const FRONT_FACE = 	[Vector3(1,1,1),Vector3(1,0,1),Vector3(0,0,1),Vector3(0,1,1)]
#const BACK_FACE = 		[Vector3(0,1,0),Vector3(0,0,0),Vector3(1,0,0),Vector3(1,1,0)]


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
	
	for block_position in blocks:
		if blocks[block_position].keys()[0] != -1:
			var data = create_block(block_position, blocks)
			returns["v"].append_array(data["v"])
			returns["u"].append_array(data["u"])
	
	return returns


static func create_block(block_position, blocks):
	const TOP_FACE = 	[Vector3(0,1,0),Vector3(1,1,0),Vector3(1,1,1),Vector3(0,1,1)]
	const DOWN_FACE = 	[Vector3(0,0,0),Vector3(0,0,1),Vector3(1,0,1),Vector3(1,0,0)]
	const LEFT_FACE = 	[Vector3(0,1,1),Vector3(0,0,1),Vector3(0,0,0),Vector3(0,1,0)]
	const RIGHT_FACE = 	[Vector3(1,1,0),Vector3(1,0,0),Vector3(1,0,1),Vector3(1,1,1)]
	const FRONT_FACE = 	[Vector3(1,1,1),Vector3(1,0,1),Vector3(0,0,1),Vector3(0,1,1)]
	const BACK_FACE = 	[Vector3(0,1,0),Vector3(0,0,0),Vector3(1,0,0),Vector3(1,1,0)]
	
	var returns = {
		"v" : PackedVector3Array(),
		"u" : PackedVector2Array()
	}
	var id_tex = blocks[block_position].keys()[0]
	
	if !(block_position + Vector3i.UP in blocks): 
		var data = create_face(TOP_FACE, block_position, id_tex)
		returns["v"].append_array(data["Triangle_1"] + data["Triangle_2"])
		returns["u"].append_array(data["UV_1"] + data["UV_2"])
	if !(block_position + Vector3i.DOWN in blocks): 
		var data = create_face(DOWN_FACE, block_position, id_tex)
		returns["v"].append_array(data["Triangle_1"] + data["Triangle_2"])
		returns["u"].append_array(data["UV_1"] + data["UV_2"])
	if !(block_position + Vector3i.LEFT in blocks): 
		var data = create_face(LEFT_FACE, block_position, id_tex)
		returns["v"].append_array(data["Triangle_1"] + data["Triangle_2"])
		returns["u"].append_array(data["UV_1"] + data["UV_2"])
	if !(block_position + Vector3i.RIGHT in blocks): 
		var data = create_face(RIGHT_FACE, block_position, id_tex)
		returns["v"].append_array(data["Triangle_1"] + data["Triangle_2"])
		returns["u"].append_array(data["UV_1"] + data["UV_2"])
	if !(block_position + Vector3i.FORWARD in blocks): 
		var data = create_face(FRONT_FACE, block_position, id_tex)
		returns["v"].append_array(data["Triangle_1"] + data["Triangle_2"])
		returns["u"].append_array(data["UV_1"] + data["UV_2"])
	if !(block_position + Vector3i.BACK in blocks): 
		var data = create_face(BACK_FACE, block_position, id_tex)
		returns["v"].append_array(data["Triangle_1"] + data["Triangle_2"])
		returns["u"].append_array(data["UV_1"] + data["UV_2"])
	
	return returns


static func create_face(face, block_position, id_tex):
	var a = face[0] + block_position
	var b = face[1] + block_position
	var c = face[2] + block_position
	var d = face[3] + block_position
	
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
	var sep_abs = Vector2(sep_px.x / atlas_size.x, sep_px.y / atlas_size.y)# + Vector2.ONE * 0.005
	
	var tex_coords = Vector2(real_size.x * id_tex / atlas_size.x, 0)
	
	var uv_a = tex_coords + Vector2(sep_abs.x, sep_abs.y)
	var uv_b = tex_coords + Vector2(sep_abs.x, tex_abs.y - sep_abs.y)
	var uv_c = tex_coords + Vector2(tex_abs.x - sep_abs.x, tex_abs.y - sep_abs.y)
	var uv_d = tex_coords + Vector2(tex_abs.x - sep_abs.x, sep_abs.y)
	
	return {
		"Triangle_1" : [a,b,c],
		"UV_1" : [uv_a,uv_b,uv_c],
		"Triangle_2" : [a,c,d],
		"UV_2" : [uv_a,uv_c,uv_d]
	}
