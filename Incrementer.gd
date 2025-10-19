extends Control
@export var val:int = 0:
	set = value_changed
@export var min:int = 0
@export var max:int = 5
@onready var reset_val = val
@onready var up_button:Button = $Up
@onready var down_button:Button = $Down
@onready var reset_button:TextureButton = $Reset
@onready var display = $AmtDisplay
# Called when the node enters the scene tree for the first time.
func value_changed(thing:int):
	val = thing
	if !display: return
	display.text = str(val)
	if !reset_button:
		return
	if val != reset_val:
		reset_button.show()
	else:
		reset_button.hide()
func _ready() -> void:
	up_button.pressed.connect(increment)
	down_button.pressed.connect(decrement)
	reset_button.pressed.connect(reset)
	display.text = str(val)
func increment():
	var adding = 0
	# 5 for shift
	if Input.is_action_pressed('shift'):
		adding += 4
	# 10 for ctrl
	if Input.is_action_pressed('control'):
		adding += 9
	#15 for ctrl + shift
	if Input.is_action_pressed('shift') and Input.is_action_pressed('control'):
		adding += 1
	val += 1 + adding
	val = clampi(val,min,max)
func decrement():
	var adding = 0
	# 5 for shift
	if Input.is_action_pressed('shift'):
		adding += 4
	# 10 for ctrl
	if Input.is_action_pressed('control'):
		adding += 9
	#15 for ctrl + shift
	if Input.is_action_pressed('shift') and Input.is_action_pressed('control'):
		adding += 1
	val -= 1 + adding
	val = clampi(val,min,max)
func reset():
	val = reset_val
