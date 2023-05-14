extends Enemy

func _ready():
	entity_type = Globals.ET.SKELETON
	
	PS = Globals.S_PS
	AT = Globals.S_AT
	AG = Globals.AG
	HG = Globals.HG
	
	attack_data = EnemiesVariables.skeleton_attack_data
	
	health = 4
	
	lunge_dist = 100.0
	detection_dist = 200.0
	idle_anim_speed = .1
	run_anim_speed = .2
	
	speed = 100.0
	acceleration = 35.0
	friction = 25.0

func ai_update():
	var scene_tree := get_tree()
	
	if scene_tree.has_group("player"):
		player_id = scene_tree.get_nodes_in_group("player")[0]
	else:
		player_id = null
		
	if player_id:
		var dist := player_id.global_position.distance_to(global_position)
		if dist < detection_dist:
			var angle = get_angle_to(player_id.global_position)
			dir_input = Vector2(cos(angle), sin(angle))
		if dist < lunge_dist:
			press_attack()

func enemy_state_update():
	if(can_move):
		move()
	
	if(can_attack):
		if(attack_pressed):
			attack_counter = 0
			set_attack(AT.THROW)

func enemy_attack_update():
	match attack:
		AT.THROW:
			if(window == 2 and window_timer == 1):
				lunge_player.stream = lunge_sounds_ogg[randi() % 3]
				lunge_player.play()
			pass
		_:
			pass

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
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 3
		PS.WALK:
			sprite.animation = dir_string + "_Run"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 4
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			var attack_string := ""

			attack_string = "Attack"
			
			sprite.animation = dir_string + "_" + attack_string
			sprite.frame = int(frame_start + window_timer*frames/win_length)
