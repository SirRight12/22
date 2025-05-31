extends Object
class_name GenericPlayer

var id:int = -1

var icon_path:String = "res://icon.svg"

var is_host:bool = false

func to_dict():
	return {
		'id': id,
		'icon_path': icon_path,
		'is_host': is_host,
	}
