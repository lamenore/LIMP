extends KinematicBody2D
class_name Enemy

signal got_hit

var player_id:KinematicBody2D

var entity_type:int
var health:int

var pHitBox = preload("res://scenes/building blocks/Hitbox.tscn")
var pProj = preload("res://scenes/building blocks/EnemyProjectile.tscn")

var PS:Dictionary
var AT:Dictionary
var AG:Dictionary
var HG:Dictionary

var attack_data

var prev_prev_state:int = 0
var prev_state:int = 0
var state:int = 0
var state_timer:int = 0
var hittable_hitpause_mult:float = 1
var histun_time := 0
var knockback_adj := 1

var can_move := true
export var speed := 100.0
export var can_accelerate := true
export var acceleration := 35.0
export var friction := 25.0
var has_armor := false

var attack:int = 0
var window:int = 0
var window_timer:int = 0

var velocity := Vector2.ZERO
var dir_input := Vector2.ZERO
var dir_facing := Vector2.DOWN

var hitstop:int = 0
var hitstop_full:int = 0
var hitstun_time:int = 0
var invincible := false
var dodge_invincibility_time := 25
var got_hit_invincible_counter := 0
var invinc_time_after_hit := 60

var can_attack:bool = true
var attack_pressed:bool = false
var attack_counter = 0
var attack_down:bool = false

var lunge_dist:float
var detection_dist:float

onready var sprite = $Sprite
onready var hitbox_parent = $HitboxParent
onready var pHurtBox = $HurtboxComponent
onready var lunge_player:AudioStreamPlayer2D = $LungePlayer
onready var lunge_sounds_ogg:Array = [preload("res://assets/sounds/enemies/slime/slime_lunge1.ogg"), 
									preload("res://assets/sounds/enemies/slime/slime_lunge2.ogg"), 
									preload("res://assets/sounds/enemies/slime/slime_lunge3.ogg")]

var idle_anim_speed:float
var run_anim_speed:float
var draw_pos := Vector2()

func _physics_process(delta: float) -> void:
	_friction(delta)
	update_inputs()
	ai_update()
	
	if(dir_input != Vector2.ZERO):
		
		var angle = round(rad2deg(dir_input.angle()))
		if(angle >= 45.0 and angle <= 135.0):
			dir_facing = Vector2.DOWN
		elif(angle <= -45.0 and angle >= -135.0):
			dir_facing = Vector2.UP
		elif(abs(angle) <= 45.0):
			dir_facing = Vector2.RIGHT
		else:
			dir_facing = Vector2.LEFT
	state_update()
	animation()
	sprite_update()
	velocity = move_and_slide(velocity)

func update_inputs():
	
	#Attack
	attack_pressed = attack_counter > 0
	attack_counter -= 1

func press_attack():
	attack_counter = 7
	attack_pressed = true

func move():
	velocity = dir_input * speed

func ai_update():
	pass

func _friction(delta) -> void:
	if can_accelerate and !hitstop:
		var _fric = friction
		if(state == PS.ATTACK and get_window_value(attack, window, AG.WINDOW_HAS_CUSTOM_FRICTION)):
			_fric *= get_window_value(attack, window, AG.WINDOW_CUSTOM_FRICTION)
		velocity = velocity.move_toward(Vector2.ZERO, _fric)

func get_state_name(state: int) -> String:
	match state:
		PS.ATTACK:
			return "Attack"
		PS.DEAD:
			return "Dead"
		PS.IDLE:
			return "Idle"
		PS.HIT:
			return "Hit"
		PS.WALK:
			return "Walk"
	return "Not found"


func set_state(new_state: int):
	prev_prev_state = prev_state
	prev_state = state
	state = new_state
	state_timer = 0
	
	#print(get_state_name(state))
	
	frame_0_set_state(state)
	
	if(prev_state == PS.ATTACK and entity_type != Globals.ET.EVIL_OAK):
		for hbox in hitbox_parent.get_children():
			hbox.queue_free()

func frame_0_set_state(new_state: int):
	match new_state:
		PS.HIT:
			pass
		_:
			pass
			

func set_attack(new_attack: int):
	attack = new_attack
	window = 1
	window_timer = 0
	
	window_speed()
	
	set_state(PS.ATTACK)
	
func state_update():
	invincible = false
	draw_pos = Vector2.ZERO
	
	if !hitstop:
		state_timer += 1
	
	if state == PS.ATTACK:
		can_attack = false
		can_move = false
		
	if state == PS.IDLE:
		can_attack = true
		if(dir_input != Vector2.ZERO):
			set_state(PS.WALK)
		
	if state == PS.WALK:
		can_attack = true
		if(dir_input == Vector2.ZERO):
			set_state(PS.IDLE)
		can_move = true
	
	if state == PS.HIT:
		can_attack = false
		if(state_timer >= hitstun_time):
			set_state(PS.IDLE)
		can_move = false
	
	if state == PS.DEAD:
		can_attack = false
		can_move = false
		queue_free()
	
	enemy_state_update()
			
	if state == PS.ATTACK:
		attack_update()

func enemy_state_update():
	pass

func attack_update():
	enemy_attack_update()
	
	if !hitstop:
		window_timer += 1
	
	
	var length := get_window_value(attack, window, AG.WINDOW_LENGTH)
	if(window_timer >= length):
		var old_window := window
		var wg := get_window_value(attack, window, AG.WINDOW_GOTO)
		if(wg > 0):
			window = wg
		elif(window < get_attack_value(attack, AG.NUM_WINDOWS)):
			window += 1
		window_timer = 0
		
		if(old_window == window and window >= get_attack_value(attack, AG.NUM_WINDOWS)):
			window = 0
			window_timer = 0
			set_state(PS.IDLE)
	
	if(!hitstop):
		window_speed()
		window_create_hitbox()
		window_sound()

func enemy_attack_update():
	pass

func window_speed():
	match int(get_window_value(attack, window, AG.WINDOW_SPEED_TYPE)):
		0:
			if(window_timer == 0):
				velocity += dir_input*get_window_value(attack, window, AG.WINDOW_SPEED)
		1:
			velocity = dir_input*get_window_value(attack, window, AG.WINDOW_SPEED)
		2:
			if(window_timer == 0):
				velocity = dir_input*get_window_value(attack, window, AG.WINDOW_SPEED)
				
func window_create_hitbox():
	var h_n := get_num_hitboxes(attack)
	if(h_n != 0):
		for i in range(h_n):
			var h_win := get_hitbox_value(attack, i+1, HG.WINDOW)
			if(h_win == window):
				var h_win_t := get_hitbox_value(attack, i+1, HG.WINDOW_CREATION_FRAME)
				if(h_win_t == window_timer):
					create_hitbox(attack, i+1, position.x, position.y)

func window_sound():
	pass

func create_hitbox(_attack, hbox_num, _x, _y):
	var hbox_type = get_hitbox_value(_attack, hbox_num, HG.HITBOX_TYPE)
	if hbox_type == 2:
		var new_hitbox = pHitBox.instance()
		new_hitbox.attack = _attack
		new_hitbox.hbox_num = hbox_num
		new_hitbox.parent_id = self
		new_hitbox.collision_layer = 64
		new_hitbox.collision_mask = 32
		new_hitbox.declare()
		
		var new_proj = pProj.instance()
		new_proj.entity_type = entity_type
		
		#Speed and direction
		new_proj.speed = get_hitbox_value(_attack, hbox_num, HG.SPEED)
		new_proj.dir_throw = dir_input if dir_input != Vector2.ZERO else dir_facing
		
		#Projectile global position
		new_proj.global_position = global_position
		
		new_hitbox.connect("hit_enemy", new_proj, "_on_Hitbox_hit_enemy")
		new_hitbox.connect("lifetime_ended", new_proj, "_on_Hitbox_lifetime_ended")
		new_proj.add_child(new_hitbox)
		get_parent().add_child(new_proj)
	else:	
		var new_hitbox = pHitBox.instance()
		new_hitbox.attack = attack
		new_hitbox.hbox_num = hbox_num
		new_hitbox.parent_id = self
		new_hitbox.collision_layer = 64
		new_hitbox.collision_mask = 32
		new_hitbox.declare()
		hitbox_parent.add_child(new_hitbox)
	pass

func enemy_hit(enemy_id:KinematicBody2D, area:int):
	#hit_sound.play()
	#var hfx := slash_hitfx.instance()
	#enemy_id.add_child(hfx)
	pass

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

func animation():
	match state:
		PS.IDLE, PS.HIT:
			sprite.animation = "all_walk"
			sprite.frame = 0
		PS.WALK:
			sprite.animation = "all_walk"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 6
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			sprite.animation = "all_attack"
			sprite.frame = int(frame_start + window_timer*frames/win_length)

func sprite_update():
	sprite.offset = draw_pos

func _on_HurtboxComponent_area_entered(area: Hitbox):
	take_hit(area)

func take_hit(area: Hitbox):
	if area.is_in_group("hitbox") and state != PS.DEAD:
		if(!has_armor):
			set_state(PS.HIT)
		$HealthComponent.take_damage(area.damage)
		var angle = area.parent_id.dir_facing.rotated(area.angle).angle()
		velocity = Vector2(cos(angle), sin(angle))*area.knockback*knockback_adj
		hitstun_time = area.hitstun
		area.parent_id.enemy_hit(self, area.type)
		area.emit_signal("hit_enemy")
	
func _on_HealthComponent_zero_health():
	print("!")
	set_state(PS.DEAD)
	pass
