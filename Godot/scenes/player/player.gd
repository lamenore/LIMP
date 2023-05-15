extends KinematicBody2D

signal life_changed

var entity_type = Globals.ET.PLAYER
export var health := 6.0

var pHitBox = preload("res://scenes/building blocks/Hitbox.tscn")
var pProj = preload("res://scenes/building blocks/Projectile.tscn")

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

var can_move := true
export var speed := 150.0
export var can_accelerate := true
export var acceleration := 35.0
export var ground_friction := 35.0

var attack:int = 0
var window:int = 0
var window_timer:int = 0

var velocity := Vector2.ZERO
var dir_input := Vector2.ZERO
var dir_facing := Vector2.DOWN

var hitstop:int = 0
var hitstop_full:int = 0
var hitstun_time:int = 0

var has_dodge:bool = true
var can_dodge:bool = true
var dodge_pressed:bool = false
var dodge_counter = 0
var dodge_down:bool = false
var dodge_timer := 30
var invincible := false
var dodge_invincibility_time := 25
var got_hit_invincible_counter := 0
var invinc_time_after_hit := 60

var can_attack:bool = true
var attack_pressed:bool = false
var attack_counter = 0
var attack_down:bool = false
var charge_time:int = 30
var charge_counter:int = 0
var can_let_out_charge:bool = true
var charge_lock:bool = false

var can_special:bool = true
var special_pressed:bool = false
var special_counter = 0
var special_down:bool = false

onready var camera = $PlayerCamera
onready var sprite = $JackSprite
onready var hitbox_parent = $HitboxParent
onready var pHurtBox:HurtboxComponent = $HurtboxComponent
onready var health_component = $HealthComponent
onready var dust_effect = $DustParticles
onready var slash_sound:AudioStreamPlayer2D = $SlashSound
onready var hit_sound:AudioStreamPlayer2D = $HitSound
onready var step_sound:AudioStreamPlayer2D = $StepSound
onready var step_sounds_ogg:Array = [preload("res://assets/sounds/player/step1.ogg"), 
									preload("res://assets/sounds/player/step2.ogg"), 
									preload("res://assets/sounds/player/step3.ogg")]
onready var slash_hitfx:PackedScene = preload("res://scenes/building blocks/SlashHitFX.tscn")
onready var proj_hitfx:PackedScene = preload("res://scenes/building blocks/ProjHitFX.tscn")

var idle_anim_speed := .1
var run_anim_speed := .2

func _ready():
	connect("life_changed", get_tree().current_scene.get_child(0).get_node("UI/Life"), "_on_Player_life_changed")
	emit_signal("life_changed", health)

func _physics_process(delta: float) -> void:
	_friction(delta)
	get_inputs()
	state_update()
	animation()
	
	velocity = move_and_slide(velocity)
	
func move():
	velocity = dir_input * speed

func turn_around():
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

func _friction(delta):
	if can_accelerate:
		var _fric = ground_friction
		if(state == PS.ATTACK and get_window_value(attack, window, AG.WINDOW_HAS_CUSTOM_FRICTION)):
			_fric *= get_window_value(attack, window, AG.WINDOW_CUSTOM_FRICTION)
		if(state == PS.DODGE and state_timer <= dodge_invincibility_time):
			_fric *= 0.3
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
	special_down = Input.is_action_pressed("special")
	special_pressed = special_counter > 0
	special_counter -= 1

func get_dir_input():
	return Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

func _input(event):
	if event.is_action_pressed("dodge"):
		dodge_counter = 15
		dodge_down = true
	if event.is_action_pressed("attack"):
		attack_counter = 7
		attack_down = true
	if event.is_action_pressed("special"):
		special_counter = 7
		special_down = true

func get_state_name(state: int) -> String:
	match state:
		PS.ATTACK:
			return "Attack"
		PS.DEAD:
			return "Dead"
	return "Not found"

func set_state(new_state: int):
	prev_prev_state = prev_state
	prev_state = state
	state = new_state
	state_timer = 0
	
	match new_state:
		PS.RUN:
			pass
		PS.IDLE:
			pass
		PS.HIT:
			$HurtSound.play()
		PS.FURY:
			pass
		PS.DODGE:
			invincible = true
			if dir_input != Vector2.ZERO:
				velocity = dir_input*300.0
			else:
				velocity = dir_facing*300.0
		PS.DEAD:
			pass
		PS.ATTACK:
			pass
			
	if(prev_state == PS.ATTACK):
		for hbox in hitbox_parent.get_children():
			hbox.queue_free()
	
	
func set_attack(new_attack: int):
	attack = new_attack
	window = 1
	window_timer = 0
	charge_counter = 0
	
	turn_around()
	window_speed()
	
	match attack:
		AT.CHARGE:
			charge_lock = true
	
	set_state(PS.ATTACK)
	
func state_update():
	invincible = false
	
	if !hitstop:
		state_timer += 1
	
	if state == PS.DODGE:
		can_attack = false
		can_dodge = false
		can_move = false
		can_special = false
		can_let_out_charge = false
		if(state_timer >= 12):
			can_let_out_charge = true
		if state_timer >= dodge_invincibility_time:
			invincible = false
		else:
			invincible = true
		if state_timer >= dodge_timer:
			set_state(PS.IDLE)
	
	if state == PS.ATTACK:
		can_attack = false
		can_move = false
		can_dodge = false
		can_special = false
		can_let_out_charge = true
		
	if state == PS.IDLE:
		can_attack = true
		can_special = true
		can_move = false
		can_dodge = true
		can_let_out_charge = true
		if(dir_input != Vector2.ZERO):
			set_state(PS.RUN)
		turn_around()
		
	if state == PS.RUN:
		can_attack = true
		can_special = true
		can_move = true
		can_dodge = true
		can_let_out_charge = true
		dust_effect.emitting = true
		if(state_timer % 16 == 6):
			step_sound.stream = step_sounds_ogg[randi() % 3]
			step_sound.play()
		if(dir_input == Vector2.ZERO):
			set_state(PS.IDLE)
		turn_around()
	else:
		dust_effect.emitting = false
	
	if state == PS.HIT:
		can_attack = false
		can_special = false
		can_move = false
		can_dodge = false
		can_let_out_charge = false
		if(state_timer >= hitstun_time):
			set_state(PS.IDLE)
	
	if(state == PS.DEAD):
		get_tree().current_scene.current_scene.emit_signal("change_scene", "res://scenes/title/YouDied.tscn")
	
	if attack_down:
		if(charge_counter < charge_time):
			charge_counter += 1
			if(charge_counter == charge_time):
				$ChargeSound.play()
	else:
		if charge_counter >= charge_time:
			if(can_let_out_charge):
				set_attack(AT.CHARGE)
				
	if state == PS.ATTACK:
		attack_update()
		
	if(can_move):
		move()
		
	if(can_dodge):
		if(dodge_pressed and has_dodge):
			set_state(PS.DODGE)
	
	if(can_attack):
		if(attack_pressed):
			attack_counter = 0
			set_attack(AT.SWING)
			
	if(can_special):
		if(special_pressed and health_component.health > 0):
			special_counter = 0
			set_attack(AT.PROJ)
			
		
	if(got_hit_invincible_counter > 0):
		invincible = true
		got_hit_invincible_counter -= 1
	#pHurtBox.set_deferred("collision_layer", set_mask)

func attack_update():
	if !hitstop:
		window_timer += 1
		
	match attack:
		AT.CHARGE:
			if(window == 1 and window_timer == get_window_value(attack, window, AG.WINDOW_LENGTH)):
				slash_sound.play()
			if(window == 3 and state_timer >= 5):
				can_dodge = true
		AT.SWING:
			if state_timer <= 12:
				turn_around()
			if(window == 1 and window_timer == get_window_value(attack, window, AG.WINDOW_LENGTH)):
				slash_sound.play()
		AT.PROJ:
			if(window <= 2):
				turn_around()
				can_dodge = true
			if(window == 2):
				if(!special_down):
					window += 1
					window_timer = 0
			if(window == 3):
				if(window_timer == 1):
					health_component.sacrifice_health(1)
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
		
		if(old_window == window and window >= get_attack_value(attack, AG.NUM_WINDOWS)):
			window = 0
			window_timer = 0
			set_state(PS.IDLE)
	
	if(!hitstop):
		window_speed()
		window_create_hitbox()
		window_sound()

func window_speed():
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
					create_hitbox(attack, i+1, global_position.x, global_position.y)

func window_sound():
	pass

func create_hitbox(_attack, hbox_num, _x, _y):
	var hbox_type = get_hitbox_value(_attack, hbox_num, HG.HITBOX_TYPE)
	if hbox_type == 2:
		var new_hitbox = pHitBox.instance()
		new_hitbox.attack = attack
		new_hitbox.hbox_num = hbox_num
		new_hitbox.parent_id = self
		new_hitbox.collision_layer = 16
		new_hitbox.collision_mask = 128
		new_hitbox.declare()
		var new_proj = pProj.instance()
		
		#Speed and direction
		new_proj.speed = get_hitbox_value(_attack, hbox_num, HG.SPEED)
		new_proj.dir_throw = dir_input if dir_input != Vector2.ZERO else dir_facing
		
		#Projectile global position
		new_proj.global_position = global_position
		
		new_hitbox.connect("hit_enemy", new_proj, "_on_Hitbox_hit_enemy")
		new_hitbox.connect("lifetime_ended", new_proj, "_on_Hitbox_lifetime_ended")
		new_proj.add_child(new_hitbox)
		get_tree().current_scene.get_node("Playground/YSort").add_child(new_proj)
	else:	
		var new_hitbox = pHitBox.instance()
		new_hitbox.attack = attack
		new_hitbox.hbox_num = hbox_num
		new_hitbox.parent_id = self
		new_hitbox.collision_layer = 16
		new_hitbox.collision_mask = 128
		new_hitbox.declare()
		hitbox_parent.add_child(new_hitbox)
	pass

func enemy_hit(enemy_id:KinematicBody2D, hbox_type:int):
	if hbox_type == 2:
		hit_sound.play()
		var hfx := proj_hitfx.instance()
		hfx.global_position = lerp(global_position, enemy_id.global_position, 1)
		get_tree().get_current_scene().add_child(hfx)
		camera.camera_shake(1, 5, 0.08)
	else:
		hit_sound.play()
		var hfx := slash_hitfx.instance()
		hfx.global_position = lerp(global_position, enemy_id.global_position, 1)
		get_tree().get_current_scene().add_child(hfx)
		camera.camera_shake(1, 5, 0.08)

func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	#hitstop = true
	#Engine.iterations_per_second = 60*timeScale
	yield(get_tree().create_timer(duration * timeScale), "timeout")
	#Engine.iterations_per_second = 60
	#hitstop = false
	Engine.time_scale = 1.0

#Attack grid
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
			sprite.animation = dir_string + "_Dodge"
			sprite.frame = state_timer * 7 / dodge_timer
		PS.FURY:
			sprite.animation = "D_Idle"
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 4
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			var attack_string := ""
			
			if(attack == AT.SWING):
				attack_string = "Swing"
			elif(attack == AT.CHARGE):
				attack_string = "Charge"
			elif(attack == AT.PROJ):
				attack_string = "Shoot"
			else:
				attack_string = "Swing"
			
			sprite.animation = dir_string + "_" + attack_string
			if win_length:
				sprite.frame = int(frame_start + window_timer*frames/win_length)


func _on_HurtboxComponent_area_entered(area):
	take_hit(area)
	
func take_hit(area:Area2D):
	if area.is_in_group("hitbox") and !invincible:
		health_component.take_damage(area.damage)
		var dir = Vector2.ZERO
		if area.parent_id:
			area.parent_id.enemy_hit(self, area.type)
			dir = area.parent_id.dir_facing.rotated(area.angle).normalized()
		velocity = dir*area.knockback
		hitstun_time = area.hitstun
		if(state != PS.DEAD):
			set_state(PS.HIT)
		$Blinker.start_blinking(self, invinc_time_after_hit)
		got_hit_invincible_counter = invinc_time_after_hit
	elif(area.is_in_group("collectable")):
		area.collect()
		health_component.gain_health(1)


func _on_HealthComponent_hp_changed(new_hp):
	var speed_modifier = clamp(new_hp/health, 0, 1)

	set_window_value(AT.SWING, 2, AG.WINDOW_SPEED, 50 + floor(speed_modifier*150))
	set_window_value(AT.SWING, 1, AG.WINDOW_LENGTH, max(floor(speed_modifier*15) , 7))
	set_window_value(AT.SWING, 3, AG.WINDOW_LENGTH, 10 + floor(speed_modifier*5))
	set_hitbox_value(AT.PROJ, 1, HG.DAMAGE, 1 + 3*(1 - speed_modifier) )
	emit_signal("life_changed", new_hp)


func _on_HealthComponent_zero_health():
	if(health_component.health <= -1):
		print("DEADEA")
		set_state(PS.DEAD)
