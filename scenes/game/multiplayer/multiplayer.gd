extends Node

const PORT = 4433

@export var player_count = 0 :
	set(count):
		UIManager.set_player_count(count)
		player_count = count

var peer = ENetMultiplayerPeer.new()

@onready var player_scene: PackedScene = load("res://scenes/game/characters/player/player_character.tscn")


func _ready():
	InputManager.host_pressed.connect(_on_host_pressed)
	InputManager.join_pressed.connect(_on_join_pressed)
	InputManager.server_restart_pressed.connect(_on_server_restart_pressed)
	
	UIManager.level_selected.connect(_on_level_selected)
	UIManager.join_pressed.connect(_on_join_pressed)
	UIManager.host_pressed.connect(_on_host_pressed)
	
	InputManager.change_state("ui")
	
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_pressed.call_deferred()


func host():
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
		
	multiplayer.multiplayer_peer = peer
	
	add_player(1)
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)


func join(ip):
	# Start as client.w
	#var txt = "192.168.0.9"
	#var txt = "localhost"
	
	if ip == "":
		OS.alert("Need a remote to connect to. Enter an IP address.")
		return
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client. Ensure that you have entered the correct IP address.")
		return
		
	multiplayer.multiplayer_peer = peer

@rpc("authority", "call_local")
func start_game(level: String):
	get_tree().paused = false
	
	InputManager.change_state("player")
	UIManager.change_state("game")
	
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(load(level))


# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	var level_scene = scene.instantiate()
	level_scene.load_level_pressed.connect(_on_load_level_pressed)
	level.add_child(level_scene)
	


func add_player(id: int):
	player_count += 1


func del_player(id: int):
	player_count -= 1

func _on_host_pressed():
	host()


func _on_join_pressed(ip: String):
	join(ip)


func _on_server_restart_pressed():
	change_level.call_deferred(load("res://scenes/game/levels/test_level.tscn"))


func _on_level_selected(level: PackedScene):
	start_game.rpc(level.resource_path)


func _on_load_level_pressed(level: String):
	if multiplayer.get_unique_id() == 1:
		start_game.rpc(level)
