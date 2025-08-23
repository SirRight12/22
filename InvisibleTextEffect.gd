@tool
extends RichTextEffect
class_name InvisibleTextEffect

var bbcode = 'invis'

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = Color(1.0,1.0,1.0,(sin(char_fx.elapsed_time * 4) * .25) + .75)
	return true
