extends KinematicBody2D

var PS = Globals.PS
var AT = Globals.AT

var prev_prev_state = 0
var prev_state = 0
var state = PS.IDLE
var state_timer = 0
var hittable_hitpause_mult = 1

export var speed := 400.0
export var can_accelerate := false
export var acceleration := 800.0
export var friction := 1_000.0

var attack = 0
var window = 0
var window_timer = 0

var velocity := Vector2()
var dir_input := Vector2()

var hitstop = 0
var hitstop_full = 0

var has_dodge = true
var dodge_pressed = false
var dodge_counter = 0
var dodge_down = false

var can_attack = true
var attack_pressed = false
var attack_counter = 0
var attack_down = false

onready var animation_player = get_node("AnimationPlayer")

func _physics_process(delta: float) -> void:
	get_inputs()	
	state_update()
	var left_click := Input.is_action_just_pressed("left_click")
	if left_click:
		set_state(Globals.PS.ATTACK)
	
	if state == PS.ATTACK:
		attack_update()
	
	move(delta)
	
func move(delta):
	
	if can_accelerate:
		if dir_input == Vector2.ZERO:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		else:
			velocity = velocity.move_toward(dir_input * speed, acceleration * delta)
	else:
		velocity = dir_input * speed
	velocity = move_and_slide(velocity)

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

func get_dir_input():
	return Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _input(event):
	if event.is_action_pressed("dodge"):
		dodge_counter = 7
		dodge_down = true

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
	
	set_state(PS.ATTACK)
	
func state_update():
	if !hitstop:
		state_timer += 1
		
	if state == PS.IDLE:
		can_attack = true
		if(dir_input != Vector2.ZERO):
			set_state(PS.RUN)
		if(dodge_pressed and has_dodge):
			set_state(PS.DODGE)
	
	if(can_attack):
		if(attack_pressed):
			set_attack(AT.SWING)

func attack_update():
	match attack:
		AT.PROJ:
			pass
		AT.SWING:
			pass
		_:
			pass
