extends KinematicBody2D

# Declare member variables here. Examples:
var speed := 0.0
var velocity := Vector2.ZERO
var dir_throw := Vector2.ZERO
var health := 1
var entity_type: int = Globals.ET.SKELETON
var proj_hitfx = preload("res://scenes/building blocks/EnemyProjHitFX.tscn")
onready var hitbox = $Hitbox

# Called when the node enters the scene tree for the first time.
func _ready():
	match entity_type:
		Globals.ET.SKELETON:
			$AnimatedSprite.animation = "Bone"
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

func die():
	queue_free()

func _on_HurtboxComponent_area_entered(area):
	pass # Replace with function body.


func _on_HealthComponent_zero_health():
	pass # Replace with function body.


func _on_Hitbox_lifetime_ended():
	die()


func _on_Hitbox_hit_enemy():
	var hfx = proj_hitfx.instance()
	hfx.global_position = global_position
	get_tree().get_current_scene().add_child(hfx)
	die()
