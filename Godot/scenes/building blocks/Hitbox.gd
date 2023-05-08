extends Area2D
class_name Hitbox

var attack_data: PlayerVariables.AttackData = PlayerVariables.attack_data
var PS = Globals.PS
var AT = Globals.AT
var AG = Globals.AG
var HG = Globals.HG

var attack:int
var hbox_num:int

var damage:int
var lifetime:int
var knockback:int

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func declare():
	damage = get_hitbox_value(attack, hbox_num, HG.DAMAGE)
	lifetime = get_hitbox_value(attack, hbox_num, HG.LIFETIME)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
