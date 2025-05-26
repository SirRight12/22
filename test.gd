extends Node

func _ready():
	set_multiplayer_authority(int(str(name).replace('player-','')))
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return 
	if event.is_action_pressed("draw"):
		print('hello')
