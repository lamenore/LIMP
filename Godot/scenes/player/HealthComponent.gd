extends Node2D
class_name HealthComponent

var MAX_HEALTH:int = 0
var health:int = 0 setget set_hp
signal hp_changed(new_hp)

signal zero_health
signal health_sacrifice(amount)

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent := get_parent()
	if parent:
		MAX_HEALTH = parent.health
		self.health = MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func take_damage(_damage: int):
	self.health -= _damage
	if self.health <= 0:
		print("emmited death")
		emit_signal("zero_health")

func gain_health(_heal: int):
	self.health += _heal

func sacrifice_health(_damage: int):
	self.health -= _damage
	emit_signal("health_sacrifice", _damage)

func set_hp(new_hp: int) -> void:
	health = new_hp
	emit_signal("hp_changed", new_hp)

func die():
	get_parent().queue_free()
