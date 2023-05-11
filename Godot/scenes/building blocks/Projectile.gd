extends KinematicBody2D

# Declare member variables here. Examples:
var speed := 0.0
var velocity := Vector2.ZERO
var dir_throw := Vector2.ZERO
var health := 1
onready var hitbox = $Hitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = dir_throw*speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = move_and_slide(velocity)

func drop_heart_on_ground():
	var heart = preload("res://scenes/building blocks/Heart.tscn").instance()
	heart.global_position = global_position
	var cur_scene := get_tree().current_scene
	var ysort = cur_scene.get_node("YSort")
	ysort.call_deferred("add_child", heart)
	queue_free()

func _on_HurtboxComponent_area_entered(area):
	pass # Replace with function body.


func _on_HealthComponent_zero_health():
	pass # Replace with function body.


func _on_Hitbox_lifetime_ended():
	drop_heart_on_ground()


func _on_Hitbox_hit_enemy():
	drop_heart_on_ground()
