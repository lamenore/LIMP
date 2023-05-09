extends Node2D
class_name HealthComponent

export var MAX_HEALTH := 10
var health = MAX_HEALTH

signal zero_health

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func take_damage(_damage: int):
	health -= _damage
	if health <= 0:
		emit_signal("zero_health")
