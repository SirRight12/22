extends Node2D
@export var words:String
@onready var sprite:Sprite2D = $Sprite2D
@onready var text = $SubViewport/Label
func _ready():
	text.text = words
func float_up():
	var _tween = create_tween().tween_property(sprite,'modulate',Color(1.0,1.0,1.0,0.0),.4)
	var tween2 = create_tween().tween_property(sprite,'position',Vector2(0,-30),.4)
	print('hello?')
	await tween2.finished
	self.hide()
func reset():
	sprite.position = Vector2(0,-20)
	sprite.modulate = Color(1.0,1.0,1.0)
