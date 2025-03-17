extends Control

signal play_pressed()

func _ready():
	Input.set_mouse_mode(0)

func _on_play_pressed():
	play_pressed.emit()

func _on_quit_pressed():
	get_tree().quit()
