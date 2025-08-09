@tool
extends RichTextEffect
class_name WavyText


var bbcode = 'wave_effect'

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var speed = char_fx.env.get('speed',1)
	var amp = char_fx.env.get('amp',1)
	char_fx.offset.y = sin(char_fx.elapsed_time * speed + (char_fx.relative_index * (PI / 3.5))) * amp
	return true
