extends Node

var current_cam: Camera3D
var previous_cam: Camera3D


func _ready():
	current_cam = get_current_camera()


func set_current_camera(cam: Camera3D):
	previous_cam = current_cam
	current_cam = cam
	current_cam.current = true


func revert_camera():
	current_cam.current = false
	current_cam = previous_cam
	current_cam.current = true


func get_current_camera():
	return get_viewport().get_camera_3d()
