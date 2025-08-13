@tool
extends Button

func _ready() -> void:
	var texture:ViewportTexture = icon
	texture.viewport_path = get_tree().root.get_path_to($HostViewport)
