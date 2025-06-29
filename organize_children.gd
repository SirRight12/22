@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	child_entered_tree.connect(organize_tree)
func remove(child):
	var tween1 = create_tween().tween_property(child,'anchor_top',-.33,.2)
	create_tween().tween_property(child,'anchor_bottom',0,.2)
	await tween1.finished
	remove_child(child)
func organize_tree(_child):
	if get_child_count() > 3:
		remove(get_children()[0])
		print('remove')
	var x = 0
	_child.anchor_top = 1.0
	_child.anchor_bottom = 1.33
	for p:AdjustableText in get_children():
		if x == 0:
			print('hello?')
			x += 1
			continue
		var child = get_children()[x]
		var top = ((x-1) * .33)
		var bottom = ((x-1) * .33) + .33
		print(x-1,' top: ',top,' bottom: ',bottom)
		create_tween().tween_property(child,'anchor_top',top,.2)
		create_tween().tween_property(child,'anchor_bottom',bottom,.2)
		x += 1
