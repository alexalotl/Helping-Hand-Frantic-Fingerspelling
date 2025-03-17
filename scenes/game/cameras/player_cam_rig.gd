extends Marker3D

@export var target: Node3D :
	set(_target):
		if _target.has_method("get_focus"):
			target = _target.get_focus()
		else:
			target = _target

@export var acceleration = 30.0
@export var rotation_sensitivity = 0.01
@export var max_distance = 10.0
# TODO Clamp these values in the inspector for safety
@export var zoom_level = 0.4 :
	set(value):
		zoom_level = clampf(value, 0.0, 1.0)
@export var zoom_step = 0.1 :
	set(value):
		zoom_step = clampf(value, 0.0, 0.2)
@export var zoom_acceleration = 4.0
@export var collision_acceleration = 30.0
@export var camera_id : int = 1

var rot_x = 0.0
var rot_y = 0.0

@onready var camera = $PlayerCam


func _ready():
	InputManager.cam_rotated.connect(_on_input_cam_rotated)
	InputManager.zoomed_in.connect(_on_input_zoom_in)
	InputManager.zoomed_out.connect(_on_input_zoom_out)
	
	if target and target.has_method("get_focus"):
		target = target.get_focus()
	
	# Process camera movement only on host machine, which is then synced
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	
	if camera_id == multiplayer.get_unique_id():
		CameraManager.set_current_camera(camera)


func _physics_process(delta):
	# Move entire rig with target.
	var target_position = target.global_position
	position = lerp(self.position, target_position, acceleration * delta)
	
	# Move camera away from center based on zoom.
	var zoom_target = zoom_level * max_distance
	camera.position.z = lerp(camera.position.z, zoom_target, zoom_acceleration * delta)
	
	# Boundary detection using a ray between the camera and target.
	var target_cam_position = Vector3(0, 0 , zoom_level * max_distance)
	
	var space_state = get_world_3d().direct_space_state
	var origin = camera.global_position
	var end = target.global_position
	var query = PhysicsRayQueryParameters3D.create(end, origin, 4)
	
	# TODO Add some sort of offset from the wall so it doesn't clip through as easily, possibly
	# needs code to edit the target position of the camera so it doesn't oscillate when at a wall
	var result = space_state.intersect_ray(query)
	if result:
		var dist_to_boundary = (result.position - end).length() / (origin - end).length()
		var boundary_target = camera.position * dist_to_boundary
		camera.position = lerp(camera.position, boundary_target, collision_acceleration * delta)


func _on_input_cam_rotated(rot_event_x, rot_event_y, input_id):
	if input_id == camera_id:
		rot_x += rot_event_x * rotation_sensitivity
		rot_y += rot_event_y * rotation_sensitivity
		
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, -1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(-1, 0, 0), rot_y) # then rotate in X
		
		InputManager.cam_rot = rotation


func _on_input_zoom_in(input_id):
	if input_id == camera_id:
		zoom_level += zoom_step


func _on_input_zoom_out(input_id):
	if input_id == camera_id:
		zoom_level -= zoom_step
