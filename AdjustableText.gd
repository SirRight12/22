@tool
extends TextureRect
class_name AdjustableText

@export var text:String:
	set = set_text
func set_text(val:String):
	$SubViewport/Label.text = val
	text = val
	print('hello?',val)
var messages = ['You drew a perfect draw ACE','You drew a draw 5 ACE','You suck at this game loser']
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_text(messages.pick_random())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
