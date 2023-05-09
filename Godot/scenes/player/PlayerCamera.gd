extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var shake_it := false
var shake_amount:float = 0
var shake_distance:float = 0
var shake_duration:float = 0
var shake_counter:float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shake_counter > 0:
		shake_counter -= delta
	shake_it = shake_counter > 0
	if(shake_it):
		_shake()
	else:
		_reset()

func camera_shake(amount, distance, duration):
	shake_it = true
	shake_distance = distance
	shake_counter = duration

func _reset():
	offset.x = 0
	offset.y = 0

func _shake():
	print("trying to shake")
	offset.x = rand_range(-shake_distance/2, shake_distance/2)
	offset.y = rand_range(-shake_distance/2, shake_distance/2)
