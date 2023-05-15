extends Enemy

func _ready():
	entity_type = Globals.ET.PUMPKIN
	
	health = 5

	PS = Globals.P_PS
	AT = Globals.P_AT
	AG = Globals.AG
	HG = Globals.HG

	attack_data = EnemiesVariables.pumpkin_attack_data
	
	lunge_dist = 80.0
	detection_dist = 400.0
	
	idle_anim_speed = .1
	run_anim_speed = .2
	
	speed = 100.0
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
			set_attack(AT.LUNGE)

func enemy_attack_update():
	match attack:
		AT.LUNGE:
			if window == 1:
				if player_id:
					var dist = global_position.distance_to(player_id.global_position)
					set_window_value(attack, 2, AG.WINDOW_SPEED, dist*4)
				
			var hover_distance := 30
			if(window == 2):
				if window_timer > 5:
					invincible = true
				if(window_timer == 1):
					lunge_player.stream = lunge_sounds_ogg[randi() % 3]
					lunge_player.play()
				var length = get_window_value(attack, window, AG.WINDOW_LENGTH)
				draw_pos.y = -window_timer * hover_distance / length
			if(window == 3):
				invincible = true
				draw_pos.y = -hover_distance
			if(window == 4):
				var length = get_window_value(attack, window, AG.WINDOW_LENGTH)
				draw_pos.y = -hover_distance + (window_timer * hover_distance / length)
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
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 4
		PS.WALK:
			sprite.animation = dir_string + "_Walk"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 4
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			var attack_string := ""

			attack_string = "Jump"
			
			sprite.animation = dir_string + "_" + attack_string
			sprite.frame = int(frame_start + window_timer*frames/win_length)
