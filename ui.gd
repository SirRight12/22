@tool
extends Node


@onready var circle:ColorRect = $Texts/ColorRect

@onready var mouse_sprite:Sprite2D = $Node2D/Sprite2D

func ask_use():
	$Texts/Confirm.viewport_text.text = 'Use?'
	$Texts/Confirm.float_up()
	pass
func tell_use():
	$Texts/Confirm.reset()
	$Texts/Accept.viewport_text.text = 'USE!'
	$Texts/Confirm.float_up()
	
	
