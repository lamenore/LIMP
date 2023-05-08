extends KinematicBody2D

var pHitBox = preload("res://scenes/building blocks/Hitbox.tscn")

var PS = Globals.PS
var AT = Globals.AT
var AG = Globals.AG
var HG = Globals.HG

var attack_data: PlayerVariables.AttackData = PlayerVariables.attack_data

var prev_prev_state:int = 0
var prev_state:int = 0
var state:int = PS.IDLE
var state_timer:int = 0
var hittable_hitpause_mult:float = 1

export var speed := 400.0
export var can_accelerate := true
export var acceleration := 70.0
export var friction := 70.0

var attack:int = 0
var window:int = 0
var window_timer:int = 0

var velocity := Vector2.ZERO
var dir_input := Vector2.ZERO
var dir_facing := Vector2.DOWN

var hitstop:int = 0
var hitstop_full:int = 0

var has_dodge:bool = true
var dodge_pressed:bool = false
var dodge_counter = 0
var dodge_down:bool = false
var dodge_timer = 15

var can_attack:bool = true
var attack_pressed:bool = false
var attack_counter = 0
var attack_down:bool = false

var can_special:bool = true
var special_pressed:bool = false
var special_counter = 0
var special_down:bool = false

onready var animation_player = get_node("AnimationPlayer")
onready var sprite = $JackSprite
onready var hitbox_parent = $HitboxParent

var idle_anim_speed := .1
var run_anim_speed := .2

func _physics_process(delta: float) -> void:
	friction(delta)
	get_inputs()
	
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
	
	#print(dir_facing)
	#print("state_timer: %s" % state_timer)
	#print("attack pressed %s" % attack_pressed)
	
	velocity = move_and_slide(velocity)
	
func move():
	
	velocity = dir_input * speed

func friction(delta):
	if can_accelerate:
		var _fric = friction
		if(state == PS.ATTACK and get_window_value(attack, window, AG.WINDOW_HAS_CUSTOM_FRICTION)):
			_fric *= get_window_value(attack, window, AG.WINDOW_CUSTOM_FRICTION)
		velocity = velocity.move_toward(Vector2.ZERO, _fric)

func shoot():
	pass

func get_inputs():
	dir_input = get_dir_input()
	
	#Dodge buffer
	dodge_down = Input.is_action_pressed("dodge")
	dodge_pressed = dodge_counter > 0
	dodge_counter -= 1
	
	#Attack buffer
	attack_down = Input.is_action_pressed("attack")
	attack_pressed = attack_counter > 0
	attack_counter -= 1
	
	#Special buffer
	special_down = Input.is_action_pressed("attack")
	special_pressed = special_counter > 0
	special_counter -= 1

func get_dir_input():
	return Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _input(event):
	if event.is_action_pressed("dodge"):
		dodge_counter = 7
		dodge_down = true
	if event.is_action_pressed("attack"):
		attack_counter = 7
		attack_down = true
	if event.is_action_pressed("special"):
		special_counter = 7
		special_down = true

func set_state(new_state: int):
	prev_prev_state = prev_state
	prev_state = state
	state = new_state
	state_timer = 0

	#print(player_id.game_time)
	#print(get_state_name(state))
	#print(get_state_name(prev_state))
	#print(get_state_name(prev_prev_state))

	match new_state:
		PS.RUN:
			pass
		PS.IDLE:
			pass
		PS.FURY:
			pass
		PS.DODGE:
			pass
		PS.DEAD:
			pass
		PS.ATTACK:
			pass
	
func set_attack(new_attack: int):
	attack = new_attack
	window = 1
	window_timer = 0
	
	window_speed()
	
	set_state(PS.ATTACK)
	
func state_update():
	if !hitstop:
		state_timer += 1
	
	if state == PS.DODGE:
		can_attack = false
		if state_timer >= dodge_timer:
			set_state(PS.IDLE)
	
	if state == PS.ATTACK:
		can_attack = false
		
	if state == PS.IDLE:
		can_attack = true
		if(dir_input != Vector2.ZERO):
			set_state(PS.RUN)
		if(dodge_pressed and has_dodge):
			set_state(PS.DODGE)
		
	if state == PS.RUN:
		can_attack = true
		if(dodge_pressed and has_dodge):
			set_state(PS.DODGE)
		if(dir_input == Vector2.ZERO):
			set_state(PS.IDLE)
		move()
		
	if(can_attack):
		if(attack_pressed):
			attack_counter = 0
			set_attack(AT.SWING)
			
	if(can_special):
		if(special_pressed):
			special_counter = 0
			set_attack(AT.PROJ)
			
	if state == PS.ATTACK:
		attack_update()

func attack_update():
	if !hitstop:
		window_timer += 1
		
	match attack:
		AT.PROJ:
			pass
		AT.SWING:
			pass
		_:
			pass
	
	var length := get_window_value(attack, window, AG.WINDOW_LENGTH)
	if(window_timer >= length):
		var old_window := window
		var wg := get_window_value(attack, window, AG.WINDOW_GOTO)
		if(wg > 0):
			window = wg
		elif(window < get_attack_value(attack, AG.NUM_WINDOWS)):
			window += 1
		window_timer = 0
		
		if(old_window == window):
			window = 0
			window_timer = 0
			set_state(PS.IDLE)
	
	if(!hitstop):
		window_speed()
		window_create_hitbox()
		window_sound()

func window_speed():
	print(get_window_value(attack, window, AG.WINDOW_SPEED_TYPE))
	match int(get_window_value(attack, window, AG.WINDOW_SPEED_TYPE)):
		0:
			if(window_timer == 0):
				velocity += dir_facing*get_window_value(attack, window, AG.WINDOW_SPEED)
		1:
			velocity = dir_facing*get_window_value(attack, window, AG.WINDOW_SPEED)
		2:
			if(window_timer == 0):
				velocity = dir_facing*get_window_value(attack, window, AG.WINDOW_SPEED)
				
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
	var new_hitbox = pHitBox.instance()
	new_hitbox.attack = attack
	new_hitbox.hbox_num = hbox_num
	new_hitbox.parent_id = self	
	new_hitbox.declare()
	hitbox_parent.add_child(new_hitbox)
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
	var dir_string := ""
	if(dir_facing == Vector2.LEFT):
		dir_string = "L"
	elif(dir_facing == Vector2.RIGHT):
		dir_string = "R"
	elif(dir_facing == Vector2.UP):
		dir_string = "U"
	else:
		dir_string = "D"
	
	match state:
		PS.IDLE:
			sprite.animation = dir_string + "_Idle"
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 4
		PS.RUN:
			sprite.animation = dir_string + "_Run"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 4
		PS.DODGE:
			sprite.animation = "D_Idle"
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 4
		PS.FURY:
			sprite.animation = "D_Idle"
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 4
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			sprite.animation = dir_string + "_Swing"
			sprite.frame = int(frame_start + window_timer*frames/win_length)
