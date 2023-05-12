extends Enemy

func _ready():
	entity_type = Globals.ET.PUMPKIN
	
	health = 6 

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
	
func move():
	velocity = dir_input * speed

func ai_update():
	var scene_tree := get_tree()
	
	attack_pressed = attack_counter > 0
	attack_counter -= 1
	
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
			attack_counter = 7
			attack_pressed = true	

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
	var new_hitbox = pHitBox.instance()
	new_hitbox.attack = attack
	new_hitbox.hbox_num = hbox_num
	new_hitbox.parent_id = self
	new_hitbox.collision_layer = 64
	new_hitbox.collision_mask = 32
	new_hitbox.declare()
	hitbox_parent.add_child(new_hitbox)
	pass

func enemy_hit(enemy_id:KinematicBody2D):
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

func sprite_update():
	sprite.offset = draw_pos

func _on_HurtboxComponent_area_entered(area: Hitbox):
	take_hit(area)

func take_hit(area: Hitbox):
	if area.is_in_group("hitbox") and state != PS.DEAD:
		set_state(PS.HIT)
		$HealthComponent.take_damage(area.damage)
		var angle = area.parent_id.dir_facing.rotated(area.angle).angle()
		velocity = Vector2(cos(angle), sin(angle))*area.knockback
		hitstun_time = area.hitstun
		area.parent_id.enemy_hit(self, area.type)
		area.emit_signal("hit_enemy")
	
	
func _on_HealthComponent_zero_health():
	set_state(PS.DEAD)
	pass
