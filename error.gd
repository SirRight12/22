extends Control

@onready var label:Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(self,'modulate',Color(1.0,1.0,1.0,0.0),.4)
	await tween.finished
	queue_free()
