extends Node3D

func show_all():
	for child in get_children():
		child.true_num()
func hide_all():
	for child in get_children():
		child.hidden_num()
func hide_cards():
	for child in get_children():
		child.hide_num()
