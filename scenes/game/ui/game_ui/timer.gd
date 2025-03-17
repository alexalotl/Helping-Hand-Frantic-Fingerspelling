extends Control

@onready var label = $TimerContainer/TimerLabel


func set_time_left(time):
	label.text = convert_time(int(time))


func convert_time(time_in_sec):
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60

	return "%02d:%02d" % [minutes, seconds]
