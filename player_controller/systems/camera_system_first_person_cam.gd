extends Camera3D

@export var maxYaw : float = 25.0
@export var maxPitch : float = 25.0
@export var maxRoll : float = 25.0
@export var shakeReduction : float = 1.0

var stress : float = 0.0
var shake : float = 0.0

var _camera_rotation_reset : Vector3 = Vector3()

# TODO: Add in some sort of rotation reset.
func _process(_delta):
	if stress == 0.0:
		_camera_rotation_reset = rotation_degrees
	
	rotation_degrees = _processshake(_camera_rotation_reset, _delta)


func _processshake(angle_center : Vector3, delta : float) -> Vector3:
	shake = stress * stress
	
	stress -= (shakeReduction / 100.0)
	stress = clamp(stress, 0.0, 1.0)
	
	var newRotate = Vector3()
	newRotate.x = maxYaw * shake * _get_noise(randi(), delta)
	newRotate.y = maxPitch * shake * _get_noise(randi(), delta + 1.0)
	newRotate.z = maxRoll * shake * _get_noise(randi(), delta + 2.0)
	
	return angle_center + newRotate
	
	
func _get_noise(noise_seed : float, time : float) -> float:
	var n = FastNoiseLite.new()
	n.seed = noise_seed
	return n.get_noise_1d(time)


func add_stress(amount : float) -> void:
	stress += amount
	stress = clamp(stress, 0.0, 1.0)
