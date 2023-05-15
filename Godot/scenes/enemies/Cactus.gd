extends Enemy


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var wake_time = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	entity_type = Globals.ET.CACTUS
	
	PS = Globals.C_PS
	AT = Globals.C_AT
	AG = Globals.AG
	HG = Globals.HG
	
	attack_data = EnemiesVariables.cactus_attack_data
	
	health = 2
	knockback_adj = 1.3
	
	lunge_dist = 20.0
	detection_dist = 100.0
	idle_anim_speed = .1
	run_anim_speed = .2
	
	speed = 180.0
	acceleration = 35.0
	friction = 25.0

	$HealthComponent.set_health()
	

func ai_update():
	var scene_tree := get_tree()
	
	if scene_tree.has_group("player"):
		player_id = scene_tree.get_nodes_in_group("player")[0]
	else:
		player_id = null
		
	if player_id:
		var dist := player_id.global_position.distance_to(global_position)
		if dist < detection_dist:
			if(state == PS.IDLE):
				set_state(PS.WAKE)
			elif(state == PS.WALK):
				var angle = get_angle_to(player_id.global_position)
				dir_input = Vector2(cos(angle), sin(angle))
		if dist < lunge_dist:
			press_attack()

func enemy_state_update():
	if(state == PS.WAKE):
		if(state_timer >= wake_time):
			set_state(PS.WALK)
	
	if(can_move):
		move()
	
	if(can_attack):
		if(attack_pressed):
			attack_counter = 0
			set_attack(AT.LUNGE)

func frame_0_set_state(new_state: int):
	match new_state:
		PS.HIT:
			set_attack(AT.LUNGE)
		PS.DEAD:
			queue_free()
		_:
			pass
			

func enemy_attack_update():
	match attack:
		AT.LUNGE:
			if(window == 3 and window_timer == get_window_value(attack, window, AG.WINDOW_LENGTH) - 1):
				set_state(PS.DEAD)
			pass
		_:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func animation():
	match state:
		PS.IDLE:
			sprite.animation = "Idle"
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 9
		PS.WAKE:
			sprite.animation = "Wake"
			sprite.frame = state_timer * 7 / wake_time
		PS.WALK:
			sprite.animation = "Run"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 3
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			
			sprite.animation = "Death"
			sprite.frame = int(frame_start + window_timer*frames/win_length)
