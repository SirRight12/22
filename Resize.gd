@tool
extends SubViewport

@export var offset = Vector2(0,0)
func _process(_delta: float) -> void:
	size = ($Label.size * $Label.scale) #+ offset
	pass
