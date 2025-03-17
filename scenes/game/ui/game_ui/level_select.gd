extends Control

signal level_selected(level: PackedScene)
signal host_pressed()
signal join_pressed(ip: String)

var player_count: int = 0

@onready var ip_edit = $MarginContainer/VBoxContainer/NetworkContainer/HBoxContainer/IPContainer/IPEdit
@onready var player_count_label = $MarginContainer/VBoxContainer/NetworkContainer/HBoxContainer/PlayerCountContainer/PlayerCount


func set_player_count(count):
	player_count_label.text = str(count) + "/2 Players"
	player_count = count


func _on_host_pressed():
	host_pressed.emit()


func _on_join_pressed():
	var ip = ip_edit.text
	join_pressed.emit(ip)


func _on_level_1_pressed():
	if player_count != 2:
		OS.alert("Ensure there are two players in the lobby before starting a level!")
	elif multiplayer.get_unique_id() != 1:
		OS.alert("Only the host can select levels.")
	else:
		level_selected.emit(load("res://scenes/game/levels/level_1.tscn"))


func _on_level_2_pressed():
	if player_count != 2:
		OS.alert("Ensure there are two players in the lobby before starting a level!")
	elif multiplayer.get_unique_id() != 1:
		OS.alert("Only the host can select levels.")
	else:
		level_selected.emit(load("res://scenes/game/levels/level_2.tscn"))


func _on_level_3_pressed():
	if player_count != 2:
		OS.alert("Ensure there are two players in the lobby before starting a level!")
	elif multiplayer.get_unique_id() != 1:
		OS.alert("Only the host can select levels.")
	else:
		level_selected.emit(load("res://scenes/game/levels/level_3.tscn"))


func _on_level_4_pressed():
	if player_count != 2:
		OS.alert("Ensure there are two players in the lobby before starting a level!")
	elif multiplayer.get_unique_id() != 1:
		OS.alert("Only the host can select levels.")
	else:
		level_selected.emit(load("res://scenes/game/levels/level_4.tscn"))


func _on_level_5_pressed():
	if player_count != 2:
		OS.alert("Ensure there are two players in the lobby before starting a level!")
	elif multiplayer.get_unique_id() != 1:
		OS.alert("Only the host can select levels.")
	else:
		level_selected.emit(load("res://scenes/game/levels/level_5.tscn"))


func _on_level_6_pressed():
	if player_count != 2:
		OS.alert("Ensure there are two players in the lobby before starting a level!")
	elif multiplayer.get_unique_id() != 1:
		OS.alert("Only the host can select levels.")
	else:
		level_selected.emit(load("res://scenes/game/levels/level_6.tscn"))
