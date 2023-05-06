extends Area2D
class_name HurtboxComponent

onready var health_component = $HealthComponent

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func take_damage(attack: Attack):
	if health_component:
		health_component.take_damage(attack)
