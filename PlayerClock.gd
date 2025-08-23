extends Control

func set_time(text:String='0:30'):
	$TimeText.text = '[invis]' + text + '[/invis]'
func set_information(round_number,ante,player_hp):
	var rn = str(round_number)
	var a = str(ante)
	var p_hp = str(player_hp)
	$Information.text = 'R' + rn + " | [color='red'] ±" + a + ' | =' + p_hp

func _ready():
	set_information(1,2,3)
