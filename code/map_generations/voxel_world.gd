extends Node3D


var chunks = {}
#chunks[chunk_position] = {
#	"b" : { _position : { _texture : _object_id } },	Blocks, Position, Texture, Object
#	"v" : PackedVector3Array(),							Triangles
#	"u" : PackedVector2Array(),							UV's
#	"r" : null											ChunkMeshRef
#}


func generate_chunk_data(_position):
	var mesh_data = VoxelMath.create_chunk(_position, chunks)
	chunks[_position]["v"] = mesh_data["v"]
	chunks[_position]["u"] = mesh_data["u"]


func create_chunk_mesh(_position):
	var chunk = chunks[_position]
	var reference = chunk["r"]
	
	if reference != null:
		remove_child(reference)
		reference.queue_free()
	reference = MeshInstance3D.new()
	
	# Begin mesh creation
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in chunk["u"].size():
		st.set_uv(chunk["u"][i])
		st.add_vertex(chunk["v"][i])
	
	st.generate_normals()
	st.generate_tangents()
	st.set_material(load("res://addons/art/materials/m_blocks.tres"))
	
	# Commit mesh
	var mesh = Mesh.new()
	st.commit(mesh)
	reference.set_mesh(mesh)
	
	# Create shape
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(chunk["v"])
	reference.add_child(shape)
	
	# Commit object
	add_child(reference)
	chunk["r"] = reference


func add_block(_position, _texture, _block_type):
	chunks[VoxelMath.get_chunk_pos(_position)] = {
		"b" : { _position : { _texture : -1 } },
		"v" : PackedVector3Array(),
		"u" : PackedVector2Array(),
		"r" : null
	}


func add_object(_position, _object_id):
	chunks[VoxelMath.get_chunk_pos(_position)] = {
		"b" : { _position : { -1 : _object_id } },
		"v" : PackedVector3Array(),
		"u" : PackedVector2Array(),
		"r" : null
	}


func remove_block(_position):
	chunks[VoxelMath.get_chunk_pos(_position)]["b"].erase(_position)
