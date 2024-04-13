####BOILER PLATE STUFF FOR GENERATING MESHES ON THE FLY WITH SURFACETOOL
####
####
####

extends Node
class_name MeshBuilder

const tileSize = 2
var surfaceTool : SurfaceTool


func _init():
	clear()
	
	
func generate_floors_and_roofs(size, material):
	#print("Genreating FLoors and Stuff: " + str(size))
	var mesh_array = []
	generate_floor(size)
	generate_ceiling(size)
	mesh_array.append(finalize_mesh(material, false))
	clear() 
	return mesh_array
	
func generate_object(cell_types_array, has_collision):
	var mesh_array = []
	#print(cell_types_array)
	for cell_type in cell_types_array:
		#print(cell_type)
		for cell in cell_types_array[cell_type].cells:
			#print("Generating Mesh at: " + str(cell))
			#print("Will start at: " + str((cell * tileSize)))
			generate_mesh_block(cell['x'], cell['y'])
		mesh_array.append(finalize_mesh(cell_types_array[cell_type].material, has_collision))
		clear() 
	return mesh_array
	
	
	
func generate_ceiling(size):
	var total_size = size * tileSize
	var x1 = 0
	var z1 = 0
	var x2 = x1 + total_size.x
	var z2 = z1 + total_size.y
	add_block(x1, 2, z1, x2, 2.5, z2, 2)
	
func generate_floor(size):
	var total_size = size * tileSize
	var x1 = 0
	var z1 = 0
	var x2 = x1 + total_size.x
	var z2 = z1 + total_size.y
	add_block(x1, -.05, z1, x2, 0, z2, 0)
	
	
func generate_mesh_block(x, z):
	var chunk_origin_x = 0
	var chunk_origin_z = 0
	var tile_x = (x * tileSize)
	var tile_z = (z * tileSize)
	var x1 = tile_x - 1
	var z1 = tile_z - 1
	var x2 = x1 + tileSize
	var z2 = z1 + tileSize
	add_block(x1, 0, z1, x2, tileSize, z2, 1)
	
	
func clear():
	surfaceTool = SurfaceTool.new()
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
func finalize_mesh(texture, create_collision):
	surfaceTool.generate_normals()
	var meshInstance : MeshInstance3D = MeshInstance3D.new()
	var mesh : Mesh = surfaceTool.commit()
	meshInstance.mesh = mesh
	if texture: meshInstance.material_override = texture
	if create_collision:
		meshInstance.create_trimesh_collision()
		
	return meshInstance
	
func add_block(x1, y1, z1, x2, y2, z2, smoothing_group):
	
	var verts = [
	Vector3(x1,y1,z1),
	Vector3(x2,y1,z1),
	Vector3(x2,y2,z1),
	Vector3(x1,y2,z1),
	Vector3(x1,y1,z2),
	Vector3(x2,y1,z2),
	Vector3(x2,y2,z2),
	Vector3(x1,y2,z2)
	]
	
	var faces = [
		[3, 0, 1, 1, 2, 3], # back face
		[6, 5, 4, 4, 7, 6], # front face
		[7, 3, 2, 2, 6, 7], # top face
		[0, 4, 5, 5, 1, 0], # bottom face
		[7, 4, 0, 0, 3, 7], # left face
		[2, 1, 5, 5, 6, 2] # right face
	]
	#var uvs = [
	#	Vector2(0,1),
	#	Vector2(0,0),
	#	Vector2(1,0),
	#	Vector2(1,0),
	#	Vector2(1,1),
	#	Vector2(0,1)
	#]
	
	var uvs = [
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,1),
		Vector2(0,1),
		Vector2(0,0),
		Vector2(1,0)
	]
	

	for i in  range(6):
		for j in range(6):
			surfaceTool.set_smooth_group(smoothing_group)
			surfaceTool.set_uv(uvs[j])
			#surfaceTool.set_uv2(uvs[j])
			surfaceTool.add_vertex(verts[faces[i][j]])
	surfaceTool.generate_normals()
	surfaceTool.generate_tangents()
