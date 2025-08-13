extends Node2D
@onready var sprite:Sprite2D = $Sprite2D
@onready var viewport_text = $SubViewport
var _tween1:Tween
var _tween2:Tween

func float_up():
	self.show()
	if _tween1:
		_tween1.kill()
		_tween1.pause()
		_tween1 = null
	if _tween2:
		_tween2.pause()
		_tween2.kill()
		_tween2 = null
	print(sprite.modulate)
	reset()
	_tween1 = create_tween()
	_tween1.tween_property(sprite,'modulate',Color(1.0,1.0,1.0,0.0),.4)
	_tween2 = create_tween()
	_tween2.tween_property(sprite,'position',Vector2(0,-30),.4)
	print('hello?')
func reset():
	#viewport_text.text = ' '
	sprite.position = Vector2(0,-20)
	sprite.modulate = Color(1.0,1.0,1.0,1.0)
