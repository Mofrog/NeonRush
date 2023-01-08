extends StaticBody

export (Material) var material
export (Material) var material2
export var block_size = Vector2(1,1)
export var block_size2 = Vector2(10,10)
export var grid_size = Vector2(80,80)
export var line_width = 0.02

var mesh = Mesh.new()
var mesh_instance = MeshInstance.new()
var st = SurfaceTool.new()

var mesh2 = Mesh.new()
var mesh_instance2 = MeshInstance.new()
var st2 = SurfaceTool.new()

var grid_axis = GRID_AXIS.X
enum GRID_AXIS {X, Y, Z}

func _process(_delta):
	var pos = Vector3()
	match grid_axis:
		GRID_AXIS.X:
			pos = -translation
			pos.y = 0
			pos.x += floor(translation.x / block_size2.x) * block_size2.x
		GRID_AXIS.Y:
			pos.x = -translation.x + floor(translation.x / block_size2.x) * block_size2.x
			pos.y = 0
			pos.z = translation.y + floor(translation.y / block_size2.y) * block_size2.y
		GRID_AXIS.Z:
			pos.x = -translation.y + floor(translation.y / block_size2.y) * block_size2.y
			pos.y = 0
			pos.z = -translation.z
	mesh_instance2.translation = pos


func _ready():
	st.begin(Mesh.PRIMITIVE_TRIANGLES) 
	var start_point = -grid_size.x/2
	for i in grid_size.x + 1:
		spawn_line(Vector3(start_point + i,0,0), block_size, st)
	for i in grid_size.y + 1:
		spawn_line_rot(Vector3(start_point,0,i), block_size, st)
	st.generate_normals()
	st.set_material(material)
	st.commit(mesh)
	mesh_instance.set_mesh(mesh)
	add_child(mesh_instance)
	
	st2.begin(Mesh.PRIMITIVE_TRIANGLES) 
	line_width *= 2
	for i in (grid_size.x / block_size2.x) + 1:
		spawn_line(Vector3(start_point + i * block_size2.x,0,0), block_size2, st2)
	for i in grid_size.y + 1:
		spawn_line_rot(Vector3(start_point,0,i * block_size2.y), block_size2, st2)
	st2.generate_normals()
	st2.set_material(material2)
	st2.commit(mesh2)
	mesh_instance2.set_mesh(mesh2)
	add_child(mesh_instance2)
	
	grid_size *= block_size / 2
	$CollisionShape.shape.extents = Vector3(grid_size.x,0.001,grid_size.y)


func spawn_line(basic_offset, local_block_size, local_st):
	var line_size = local_block_size.y * grid_size.y
	var offset = basic_offset - Vector3(line_width/2,0,line_size/2)
	var a = Vector3(0,0,0) + offset
	var b = Vector3(0,0,line_size) + offset
	var c = Vector3(line_width,0,line_size) + offset
	var d = Vector3(line_width,0,0) + offset
	local_st.add_triangle_fan([a,b,c])
	local_st.add_triangle_fan([a,c,d])


func spawn_line_rot(basic_offset, local_block_size, local_st):
	var line_size = local_block_size * grid_size
	var offset = basic_offset - Vector3(line_width/2,0,line_size.y/2)
	var a = Vector3(line_width,0,0) + offset
	var b = Vector3(line_size.x,0,0) + offset
	var c = Vector3(line_size.x,0,line_width) + offset
	var d = Vector3(0,0,line_width) + offset
	local_st.add_triangle_fan([a,b,c])
	local_st.add_triangle_fan([a,c,d])
