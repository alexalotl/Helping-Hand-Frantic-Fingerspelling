extends Control

signal next_level_pressed()
signal restart_level_pressed()

var star_img = preload("res://textures/ui/game/star_full.png")

@onready var panel = $Panel
@onready var star1 = $Panel/VBoxContainer/Stars/Star1
@onready var star1label = $Panel/VBoxContainer/Stars/Star1/Label
@onready var star2 = $Panel/VBoxContainer/Stars/Star2
@onready var star2label = $Panel/VBoxContainer/Stars/Star2/Label
@onready var star3 = $Panel/VBoxContainer/Stars/Star3
@onready var star3label = $Panel/VBoxContainer/Stars/Star3/Label
@onready var score_label = $Panel/VBoxContainer/ScoreNum


func show_panel():
	panel.visible = true


func hide_panel():
	panel.visible = false


func set_stars(num: int):
	if num >= 1:
		star1.texture = star_img
	if num >= 2:
		star2.texture = star_img
	if num >= 3:
		star3.texture = star_img


func set_score(score: int):
	score_label.text = str(score)


func set_star_point_boundaries(star1boundary: int, star2boundary: int, star3boundary: int):
	star1label.text = str(star1boundary)
	star2label.text = str(star2boundary)
	star3label.text = str(star3boundary)


@rpc("any_peer", "call_local")
func quit_game():
	print("quit")
	get_tree().quit()


func _on_quit_button_pressed():
	print("quit")
	quit_game.rpc()


func _on_next_button_pressed():
	print("next")
	next_level_pressed.emit()


func _on_restart_button_pressed():
	print("restart")
	restart_level_pressed.emit()
