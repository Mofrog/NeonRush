extends StaticBody


const atlas : AtlasTexture = preload("res://art/atlas/diffuse.tres")
const m_atlas : Material = preload("res://art/materials/m_blocks.tres")

var textures = Blocks.textures
var objects = Blocks.objects

#----------------------------------Block geometry var's-------------------------
const vertices = [
	Vector3(0,0,0),
	Vector3(1,0,0),
	Vector3(0,1,0),
	Vector3(1,1,0),
	Vector3(0,0,1),
	Vector3(1,0,1),
	Vector3(0,1,1),
	Vector3(1,1,1)
]
const TOP_VERT = [2,3,7,6]
const BOTTOM_VERT = [0,4,5,1]
const LEFT_VERT = [6,4,0,2]
const RIGHT_VERT = [3,1,5,7]
const FRONT_VERT = [7,5,4,6]
const BACK_VERT = [2,0,1,3]

const SLOPE_VERT = [2,3,5,4]
const SLOPE_LEFT = [4,0,2]
const SLOPE_RIGHT = [3,1,5]


enum {BLOCK,SLOPE,OBJECT}

var st = SurfaceTool.new()
var mesh = null
var mesh_instance = null

var blocks : Dictionary = {}

var block : Dictionary = {
	"r" : 0,
	"t" : "tiles_small_black",
	"p" : BLOCK,
	"o" : -1
}

var is_have_collision = false

var position = Vector3()


#----------------------------------FUNC'S---------------------------------------
# generate full mesh of chunk
func generate_mesh(update_collision = false, preloaded_mesh = null):
	if mesh_instance != null:
		mesh_instance.call_deferred("queue_free")
		mesh_instance = null
	
	if get_child_count() > 0: 
		for i in get_children(): i.queue_free()
	
	if preloaded_mesh != null:
		for pos in blocks.keys(): if blocks[pos]["p"] == OBJECT:
			create_object(pos[0],pos[1],pos[2],blocks[pos]["o"])
		mesh_instance = preloaded_mesh.dublicate()
		add_child(mesh_instance)
		return null
	
	mesh = Mesh.new()
	mesh_instance = MeshInstance.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES) 
	
	var is_tangents_valid = false
	for pos in blocks.keys(): 
		match blocks[pos]["p"]:
			BLOCK:
				create_block(pos[0],pos[1],pos[2],blocks[pos]["t"])
				is_tangents_valid = true
			SLOPE:
				create_slope(pos[0],pos[1],pos[2],blocks[pos]["t"],blocks[pos]["r"])
				is_tangents_valid = true
			OBJECT:
				create_object(pos[0],pos[1],pos[2],blocks[pos]["o"])
	
	st.generate_normals()
	if is_tangents_valid: st.generate_tangents()
	st.set_material(m_atlas)
	st.commit(mesh)
	mesh_instance.set_mesh(mesh)
	
	if update_collision: mesh_instance.create_trimesh_collision()
	
	add_child(mesh_instance)
	return mesh_instance.duplicate()


func create_object(x,y,z,id_obj):
	var obj = load(objects[objects.keys()[id_obj]]).instance()
	obj.translation = Vector3(x + 0.5,y + 0.25,z + 0.5)
	if obj is Area: 
		obj.is_end = true
	add_child(obj)


func create_slope(x,y,z,id_tex,a=0):
	var verts = vertices.duplicate()
	
	for i in verts.size():
		verts[i] = verts[i].rotated(Vector3.UP,deg2rad(a))
		if a == 90 || a == 180: verts[i].z += 1
		if a == 180 || a == 270: verts[i].x += 1
	
	create_face(SLOPE_VERT,x,y,z,id_tex,verts)
	create_face(BOTTOM_VERT,x,y,z,id_tex,verts)
	create_triangle(SLOPE_LEFT,x,y,z,id_tex,verts)
	create_triangle(SLOPE_RIGHT,x,y,z,id_tex,verts)
	create_face(BACK_VERT,x,y,z,id_tex,verts)


# create all block faces
func create_block(x,y,z,id_tex):
	if is_valid(Vector3(x,y+1,z)): create_face(TOP_VERT,x,y,z,id_tex)
	if is_valid(Vector3(x,y-1,z)): create_face(BOTTOM_VERT,x,y,z,id_tex)
	if is_valid(Vector3(x-1,y,z)): create_face(LEFT_VERT,x,y,z,id_tex)
	if is_valid(Vector3(x+1,y,z)): create_face(RIGHT_VERT,x,y,z,id_tex)
	if is_valid(Vector3(x,y,z+1)): create_face(FRONT_VERT,x,y,z,id_tex)
	if is_valid(Vector3(x,y,z-1)): create_face(BACK_VERT,x,y,z,id_tex)


func is_valid(pos):
	return !blocks.has(pos) || blocks[pos]["p"] != BLOCK


func create_triangle(i,x,y,z,id_tex,verts = null):
	var offset = Vector3(int(x),int(y),int(z))
	if verts == null: verts = vertices
	var a = verts[i[0]] + offset
	var b = verts[i[1]] + offset
	var c = verts[i[2]] + offset
	
	# Texture size (px) : Always square
	var tex_px = Vector2(256.0, 256.0)
	# Atlas size (px)
	var atlas_size = Vector2(atlas.get_width(), atlas.get_height()) 
	# Atlas separation between textures (px)
	var sep_px = Vector2(0, 0)
	# Texture real size (px)
	var real_size = tex_px + sep_px * 2
	
	# Texture size (abs)
	var tex_abs = Vector2(real_size.x / atlas_size.x, real_size.y / atlas_size.y) 
	# Atlas separation between textures (abs)
	var sep_abs = Vector2(sep_px.x / atlas_size.x, sep_px.y / atlas_size.y)# + Vector2.ONE * 0.005
	
	
	var tex_coords = Vector2(real_size.x * id_tex / atlas_size.x, 0)
	
	
	var uv_a = tex_coords + Vector2(sep_abs.x, sep_abs.y)
	var uv_b = tex_coords + Vector2(sep_abs.x, tex_abs.y - sep_abs.y)
	var uv_c = tex_coords + Vector2(tex_abs.x - sep_abs.x, tex_abs.y - sep_abs.y)
	
	st.add_triangle_fan([a,b,c],[uv_a,uv_b,uv_c])


# create indivual face from coordinates
func create_face(i,x,y,z,id_tex,verts = null):
	var offset = Vector3(int(x),int(y),int(z))
	if verts == null: verts = vertices
	var a = verts[i[0]] + offset
	var b = verts[i[1]] + offset
	var c = verts[i[2]] + offset
	var d = verts[i[3]] + offset
	
	# Texture size (px) : Always square
	var tex_px = Vector2(256.0, 256.0)
	# Atlas size (px)
	var atlas_size = Vector2(atlas.get_width(), atlas.get_height()) 
	# Atlas separation between textures (px)
	var sep_px = Vector2(0, 0)
	# Texture real size (px)
	var real_size = tex_px + sep_px * 2
	
	# Texture size (abs)
	var tex_abs = Vector2(real_size.x / atlas_size.x, real_size.y / atlas_size.y) 
	# Atlas separation between textures (abs)
	var sep_abs = Vector2(sep_px.x / atlas_size.x, sep_px.y / atlas_size.y)# + Vector2.ONE * 0.005
	
	
	var tex_coords = Vector2(real_size.x * id_tex / atlas_size.x, 0)
	
	
	var uv_a = tex_coords + Vector2(sep_abs.x, sep_abs.y)
	var uv_b = tex_coords + Vector2(sep_abs.x, tex_abs.y - sep_abs.y)
	var uv_c = tex_coords + Vector2(tex_abs.x - sep_abs.x, tex_abs.y - sep_abs.y)
	var uv_d = tex_coords + Vector2(tex_abs.x - sep_abs.x, sep_abs.y)
	
	st.add_triangle_fan([a,b,c],[uv_a,uv_b,uv_c])
	st.add_triangle_fan([a,c,d],[uv_a,uv_c,uv_d])
