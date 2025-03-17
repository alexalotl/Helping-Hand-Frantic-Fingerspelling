extends Node3D

signal load_level_pressed(level: String)

@export var player_1_spawn: Marker3D
@export var player_2_spawn: Marker3D
@export var next_level: String


func _ready():
	UIManager.next_level_pressed.connect(_on_next_level_pressed)
	UIManager.restart_level_pressed.connect(_on_restart_level_pressed)
	
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		print("ADDING PLAYER : ", id)
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)


func _exit_tree():
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	print("ADDING PLAYER TO LEVEL : ", id)
	
	var character = preload("res://scenes/game/characters/player/player_character.tscn").instantiate()
	# Set player id.
	character.player_id = id
	var pos: Vector3
	if id == 1:
		pos = player_1_spawn.global_position
	else:
		pos = player_2_spawn.global_position
	character.position = pos
	character.name = str(id)
	$Players.add_child(character, true)
	
	var camera = preload("res://scenes/game/cameras/player_cam_rig.tscn").instantiate()
	camera.camera_id = id
	camera.target = character
	$Cameras.add_child(camera, true)


func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()


func _on_next_level_pressed():
	load_level_pressed.emit(next_level)


func _on_restart_level_pressed():
	load_level_pressed.emit(load(scene_file_path))
