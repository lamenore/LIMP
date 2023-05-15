extends Area2D
class_name Hitbox

signal lifetime_ended
signal hit_enemy

var parent_id:KinematicBody2D

var attack_data
var PS:Dictionary
var AT:Dictionary
var AG = Globals.AG
var HG = Globals.HG

var attack:int
var hbox_num:int

var damage:int
var lifetime:int
var hitbox_timer := 0
var knockback:int
var angle:int
var type:int = 1

var hitstun:int


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func declare():
	PS = parent_id.PS
	AT = parent_id.AT
	attack_data = parent_id.attack_data
	
	damage = get_hitbox_value(attack, hbox_num, HG.DAMAGE)
	lifetime = get_hitbox_value(attack, hbox_num, HG.LIFETIME)
	knockback = get_hitbox_value(attack, hbox_num, HG.KNOCKBACK)
	hitstun = get_hitbox_value(attack, hbox_num, HG.HITSTUN)
	type = get_hitbox_value(attack, hbox_num, HG.HITBOX_TYPE)
	var hbox_pos = Vector2(get_hitbox_value(attack, hbox_num, HG.HITBOX_FORW),
							get_hitbox_value(attack, hbox_num, HG.HITBOX_SIDE))
	position = hbox_pos.rotated(parent_id.dir_facing.angle())
	scale = Vector2(get_hitbox_value(attack, hbox_num, HG.WIDTH),
						get_hitbox_value(attack, hbox_num, HG.HEIGHT))
	rotation = parent_id.dir_facing.angle()
	angle = deg2rad(get_hitbox_value(attack, hbox_num, HG.ANGLE))
	
# Called every frame.
func _physics_process(delta):
	if(hitbox_timer >= lifetime):
		print("emmited")
		emit_signal("lifetime_ended")
		queue_free()
	hitbox_timer += 1

func set_attack_value(_attack: int, index: int, value: float):
	attack_data.set_attack_value(_attack, index, value)

func get_attack_value(_attack: int, index: int) -> float:
	return attack_data.get_attack_value(_attack, index)

func set_window_value(_attack: int, _window: int, index: int, value: float):
	attack_data.set_window_value(_attack, _window, index, value)

func get_window_value(_attack: int, _window: int, index: int) -> float:
	return attack_data.get_window_value(_attack, _window, index)

func set_num_hitboxes(_attack: int, value: float):
	attack_data.set_num_hitboxes(_attack, value)
	
func get_num_hitboxes(_attack: int) -> float:
	return attack_data.get_num_hitboxes(_attack)

func set_hitbox_value(_attack: int, _hbox_num: int, index: int, value: float):
	attack_data.set_hitbox_value(_attack, _hbox_num, index, value)

func get_hitbox_value(_attack: int, _hbox_num: int, index: int) -> float:
	return attack_data.get_hitbox_value(_attack, _hbox_num, index)
