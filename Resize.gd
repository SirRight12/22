@tool
extends SubViewport

@export var fixed_size:bool

@export var const_size:Vector2

@export var text:String = ""
func _process(_delta: float) -> void:
	if $Label is Label or $Label is RichTextLabel:
		$Label.text = text
	if fixed_size:
		size = const_size
		return
	size = ($Label.size * $Label.scale)
	pass
