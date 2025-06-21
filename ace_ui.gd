extends Control

@export var dictionary:Dictionary[String,Texture2D]
func set_ace_name(ace_name:String):
	$TextureRect.texture = dictionary[ace_name]
	$AutoSizeLabel.text = ace_name.replace('-',' ')
