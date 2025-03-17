extends Control

@onready var label = $ScoreContainer/ScoreLabel


func set_score(score):
	label.text = str(score)
