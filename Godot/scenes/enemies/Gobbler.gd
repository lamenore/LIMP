extends Enemy

var noise = OpenSimplexNoise.new()

func _ready():
	
	entity_type = Globals.ET.GOBBLER
	health = 4 
	
	PS = Globals.G_PS
	AT = Globals.G_AT
	AG = Globals.AG
	HG = Globals.HG
	
	attack_data = EnemiesVariables.gobbler_attack_data
	
	speed = 50.0
	acceleration = 35.0
	friction = 25.0
	
	lunge_dist = 0.0
	detection_dist = 0.0
	
	idle_anim_speed = .1
	run_anim_speed = .2
	
	noise.octaves = 1
	noise.period = 128.0
	
	$HealthComponent.set_health()
	
func move():
	velocity = dir_input * speed

func ai_update():
	var scene_tree := get_tree()
	
	if scene_tree.has_group("player"):
		player_id = scene_tree.get_nodes_in_group("player")[0]
	else:
		player_id = null
	
	#if scene_tree.has_group("floating_heart"):
		#player_id = scene_tree.get_nodes_in_group("floating_heart")[0]
		
	if player_id:
		
		var dist := player_id.global_position.distance_to(global_position)
		
		if dist < lunge_dist:
			press_attack()
		elif dist < detection_dist:
			var angle = get_angle_to(player_id.global_position)
			dir_input = Vector2(cos(angle), sin(angle))
		else:
			var new_dir := Vector2(noise.get_noise_3d(global_position.x, global_position.y, state_timer),
									noise.get_noise_3d(global_position.x, global_position.y, state_timer+200))
			dir_input = new_dir.normalized()

func enemy_state_update():
	if(can_move):
		move()
	
	if(can_attack):
		if(attack_pressed):
			attack_counter = 0
			set_attack(AT.LUNGE)

func enemy_attack_update():
	match attack:
		AT.LUNGE:
			if window == 1:
				pass
			if(window == 2):
				if(window_timer == 1):
					lunge_player.stream = lunge_sounds_ogg[randi() % 3]
					lunge_player.play()
			pass
		_:
			pass
	
func animation():
	match state:
		PS.IDLE:
			sprite.animation = "all_idle"
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 4
		PS.WALK:
			sprite.animation = "all_run"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 4
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			var attack_string := ""

			attack_string = "Attack"
			
			sprite.animation = "R_" + attack_string
			sprite.frame = int(frame_start + window_timer*frames/win_length)
