@tool
extends Control

@export_tool_button('test_thing') var function = display_text
@onready var label:RichTextLabel = $Label
@onready var text_length = len(label.get_parsed_text())
signal fade_in()
func display_text():
	label.visible_characters = 0
	fade()
	await fade_in
	var x = 0;
	while x < text_length:
		label.visible_characters += 1
		x += 1
		if x < 3:
			await get_tree().create_timer(.05).timeout
		#space after "you", builds suspense or smth
		elif x == 4:
			await get_tree().create_timer(1).timeout
		else:
			await get_tree().create_timer(.15).timeout
	await get_tree().create_timer(3).timeout
	create_tween().tween_property($Leave,'self_modulate',Color('a5a5a5c1'),1)
func fade():
	modulate = Color(Color.WHITE,0.0)
	var tween = create_tween().tween_property(self,'modulate',Color.WHITE,.2)
	await tween.finished
	fade_in.emit()
