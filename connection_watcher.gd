extends Node

func _ready():
	if !Client.connected:
		swap_to_menu()
	Client.on_connection_lost.connect(swap_to_menu)
func swap_to_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var packed_scene = load("res://test_multiplayer.tscn")
	Client.poll_packets = false
	
	get_tree().change_scene_to_packed(packed_scene)
