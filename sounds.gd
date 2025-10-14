extends Node

@onready var tap_sound = $Hit
@onready var draw = $Draw
@onready var pass_sounds = $Pass
@onready var win_sound = $Win
@onready var lose_sound = $Lose
@onready var bg_music = $BGMusic
@onready var water = $Water
func mouse_tap():
	tap_sound.pitch_scale = randf_range(2.4,2.6)
	tap_sound.play()
func draw_card(is_self):
	var sound:AudioStreamPlayer = draw.get_children().pick_random()
	if is_self:
		sound.bus = 'Voice2'
	else:
		sound.bus = 'Voice1'
	sound.play()
func pass_turn(is_self):
	var sound:AudioStreamPlayer = pass_sounds.get_children().pick_random()
	if is_self:
		sound.bus = 'Voice2'
	else:
		sound.bus = 'Voice1'
	sound.play()
func win():
	win_sound.play()
func lose():
	lose_sound.play()
func trump_sound():
	print('trump_sounds')
	print('nothing yet lol')
var elapsed_time = 0
func _process(delta: float) -> void:
	if not bg_music.playing:
		return
	elapsed_time += delta
	if floori(elapsed_time + 1) % 50 == 0:
		print('water',floori(elapsed_time + 1) % 50)
		elapsed_time = 0
		water.pitch_scale = randf_range(.21,.25)
		water.play()
