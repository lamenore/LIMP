extends Enemy

var noise = OpenSimplexNoise.new()
var spawn_contact := true

var enemies_to_spawn := [preload("res://scenes/enemies/Cactus.tscn"), preload("res://scenes/enemies/MossSkeleton.tscn"), preload("res://scenes/enemies/Pumpkin.tscn")
						, preload("res://scenes/enemies/SapSlime.tscn"), preload("res://scenes/enemies/Skeleton.tscn")]

func _ready():
	entity_type = Globals.ET.EVIL_OAK
	
	PS = Globals.EO_PS
	AT = Globals.EO_AT
	AG = Globals.AG
	HG = Globals.HG
	
	attack_data = EnemiesVariables.evil_oak_attack_data
	
	health = 20
	
	lunge_dist = 50.0
	detection_dist = 240.0
	idle_anim_speed = .1
	run_anim_speed = .2
	
	speed = 30.0
	acceleration = 35.0
	friction = 25.0
	
	noise.octaves = 1
	noise.period = 128.0
	has_armor = true
	
	
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
			var new_dir := Vector2(noise.get_noise_3d(global_position.x, global_position.y, state_timer),
										noise.get_noise_3d(global_position.x, global_position.y, state_timer+200))
			dir_input = new_dir.normalized()
		else:
			dir_input = Vector2.ZERO
		if(dist < 300.0):
			if(randi()%1000 < 5):
				var ind = randi() % enemies_to_spawn.size()
				var rand_vec:Vector2 = global_position + Vector2(rand_range(-300, 300), rand_range(-300, 300))
				var e = enemies_to_spawn[ind].instance()
				e.global_position = rand_vec
				get_parent().add_child(e)
			if(randi()%1000 < 10):
				create_hitbox(AT.THROW, 1, global_position.x, global_position.y)
		
	if(spawn_contact):
		spawn_contact = false
		set_attack(AT.CONTACT)
		

func enemy_state_update():
	
	if(state == PS.DEAD):
		get_tree().current_scene.current_scene.emit_signal("change_scene", "res://scenes/title/credits.tscn")
	if(can_move):
		move()
	
	if(can_attack):
		if(attack_pressed):
			attack_counter = 0
			set_attack(AT.BEAM)

func enemy_attack_update():
	match attack:
		AT.BEAM:
			if(window == 2 and window_timer == 1):
				lunge_player.stream = lunge_sounds_ogg[randi() % 3]
				lunge_player.play()
			pass
		_:
			pass

func animation():
	match state:
		PS.IDLE:
			sprite.animation = "Idle"
			sprite.frame = int(float(state_timer)*idle_anim_speed) % 8
		PS.WALK:
			sprite.animation = "Walk"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 8
		PS.LAUGH:
			sprite.animation = "Laugh"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 10
		PS.STUN:
			sprite.animation = "Stun"
			sprite.frame = int(float(state_timer)*run_anim_speed) % 8
		PS.ATTACK:
			var frames = get_window_value(attack, window, AG.WINDOW_ANIM_FRAMES)
			var frame_start = get_window_value(attack, window, AG.WINDOW_ANIM_FRAME_START)
			var win_length = get_window_value(attack, window, AG.WINDOW_LENGTH)
			
			sprite.animation = "Beam"
			sprite.frame = int(frame_start + window_timer*frames/win_length)
