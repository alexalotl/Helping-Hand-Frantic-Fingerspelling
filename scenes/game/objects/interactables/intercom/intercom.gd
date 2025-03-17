class_name IntercomInteractable
extends Interactable

@export var text : Array[String]


func _ready():
	super()
	
func interact(_player_id):
	super(_player_id)
	setup_text.rpc_id(player_id)
	for line in text:
		queue_text.rpc_id(player_id, line)


@rpc("authority", "call_local")
func set_text(new_text: Array[String]):
	text = new_text


# TODO Handled by textbox UI instead. Maybe better to handle with InputManager?
@rpc("authority", "call_local")
func setup_text():
	UIManager.text_finished.connect(_on_text_finished)


@rpc("authority", "call_local")
func queue_text(txt):
	UIManager.queue_text(txt)


@rpc("any_peer", "call_local")
func end_text():
	interact_end()


func _on_input_interacted(_input_id):
	# OVERRIDE
	pass


func _on_text_finished():
	UIManager.text_finished.disconnect(_on_text_finished)
	end_text.rpc_id(1)
