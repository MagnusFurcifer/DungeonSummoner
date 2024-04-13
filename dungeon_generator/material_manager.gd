extends Node
class_name MaterialManager

var material_paths = [
	{"name" : "blank", "alb" : "res://assets/textures/floor/floor.png", "nrm" : null},
	{"name" : "blank_hall", "alb" : "res://assets/textures/floor/floor.png", "nrm" : null},
	{"name" : "blank_room", "alb" : "res://assets/textures/floor/floor.png", "nrm" : null},
	{"name" : "brick_wall", "alb" : "res://assets/textures/wall/brick_wall.png", "nrm" : null},
	{"name" : "door", "alb" : "res://assets/textures/wall/brick_wall.png", "nrm" : null},
]

var materials = []

func _init():
	for path in material_paths:
		materials.append(create_material_from_texture_path(path.alb, path.nrm))
		print(materials)
		
func create_material_from_texture_path(albedo, normal):
	var tex
	var nrm
	var mat = StandardMaterial3D.new()
	if albedo:
		tex = Image.load_from_file(albedo)
		if normal != null:
			nrm = Image.load_from_file(normal)
	if tex:
		mat.albedo_texture = ImageTexture.create_from_image(tex)
		if nrm:
			mat.normal_enabled = true
			mat.normal_texture = ImageTexture.create_from_image(nrm)
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS_ANISOTROPIC 
	else:
		mat.albedo_color = Color(randf(), randf(), randf(), 1.0)
	return mat
