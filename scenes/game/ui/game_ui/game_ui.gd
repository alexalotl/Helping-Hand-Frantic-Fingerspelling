extends MarginContainer


func _ready():
	start()

func start():
	$Score/ScoreContainer.visible = true
	$Timer/TimerContainer.visible = true
	$SignMenu/MarginContainer.visible = false
	$EndMenu/Panel.visible = false
