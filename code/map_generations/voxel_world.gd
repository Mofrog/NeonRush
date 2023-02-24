extends Node3D


var chunks = {}
#chunks[Vector3()] = {				Chunk position
#	"b" : {								Blocks
#		Vector3() : { 	 					Position
#			"t" : int,						Block texture
#			"s" : int,						Block shape
#			"r" : Vector3(),				Rotation
#			"o" : int 						Object id
#		}
#	},  
#	"v" : PackedVector3Array(),			Triangles
#	"u" : PackedVector2Array(),			UV's
#	"r" : null							ChunkMeshRef
#}


func create_chunk(_position):
	if _position in chunks:
		var mesh_data = VoxelMath.create_chunk(_position, chunks)
		chunks[_position]["v"] = mesh_data["v"]
		chunks[_position]["u"] = mesh_data["u"]


func commit_chunk(_position):
	if !(_position in chunks): return
	
	var chunk = chunks[_position]
	var reference = chunk["r"]
	if reference == null: reference = MeshInstance3D.new()
	
	# Begin mesh creation
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in chunk["u"].size():
		st.set_uv(chunk["u"][i])
		st.set_smooth_group(-1)
		st.add_vertex(chunk["v"][i])
	
	st.generate_normals()
	st.generate_tangents()
	st.set_material(load("res://art/materials/m_block.tres"))
	
	reference.set_mesh(st.commit(Mesh.new()))
	
	# Create shape
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(chunk["v"])
	var shape_obj = CollisionShape3D.new()
	shape_obj.shape = shape
	reference.add_child(shape_obj)
	
	# Commit object
	if !reference in get_children(): add_child(reference)
	chunk["r"] = reference


func add_block(_position, _texture, _block_shape, _rotation):
	var chunk_pos = VoxelMath.get_chunk_pos(_position)
	if chunk_pos in chunks:
		var blocks = chunks[chunk_pos]["b"]
		if _position in blocks: return false
		blocks[_position] = { 
			"t" : _texture,
			"s" : _block_shape,
			"r" : _rotation,
			"o" : -1
		}
		chunks[chunk_pos]["b"] = blocks
	else:
		chunks[VoxelMath.get_chunk_pos(_position)] = {
			"b" : {
				_position : {
					"t" : _texture,
					"s" : _block_shape,
					"r" : _rotation,
					"o" : -1
					}
				},
			"v" : PackedVector3Array(),
			"u" : PackedVector2Array(),
			"r" : null
		}
	return true


#func add_object(_position, _object_id):
#	chunks[VoxelMath.get_chunk_pos(_position)] = {
#		"b" : { _position : { -1 : _object_id } },
#		"v" : PackedVector3Array(),
#		"u" : PackedVector2Array(),
#		"r" : null
#	}


func delete_block(_position):
	var chunk_pos = VoxelMath.get_chunk_pos(_position)
	if chunk_pos in chunks:
		var chunk = chunks[chunk_pos]
		if _position in chunk["b"]:
			chunk["b"].erase(_position)
			if chunk["b"].size() == 0:
				remove_child(chunk["r"])
				chunk["r"].queue_free()
				chunks.erase(chunk_pos)
			return true
	return false
