extends Node

var attack_data : AttackData

class AttackData:
	var max_attacks = 10
	var max_indexes = 30
	var max_windows = 29
	
	var PS = Globals.PS
	var AT = Globals.AT
	var AG = Globals.AG
	var HG = Globals.HG
	
	var attack_data := []
	
	var window_data := []
	
	var hitbox_data := []
	var hitbox_amount := []
	
	func set_attack_value(attack: int, index: int, value: float):
		attack_data[index + attack*max_indexes] = value
	
	func get_attack_value(attack: int, index: int) -> float:
		return attack_data[index + attack*max_indexes]
	
	func set_window_value(attack: int, window: int, index: int, value: float):
		window_data[index + window*max_indexes + attack*max_indexes*max_windows] = value
	
	func get_window_value(attack: int, window: int, index: int) -> float:
		return window_data[index + window*max_indexes + attack*max_indexes*max_windows]
	
	func set_num_hitboxes(attack: int, value: float):
		hitbox_amount[attack] = value

	func get_num_hitboxes(attack: int) -> float:
		return hitbox_amount[attack]

	func set_hitbox_value(attack: int, window: int, index: int, value: float):
		hitbox_data[index + window*max_indexes + attack*max_indexes*max_windows] = value
	
	func get_hitbox_value(attack: int, window: int, index: int) -> float:
		return hitbox_data[index + window*max_indexes + attack*max_indexes*max_windows]
	
	func _init():
		attack_data.resize(max_indexes*max_attacks)
		attack_data.fill(0)
		window_data.resize(max_indexes*max_attacks*max_windows)
		window_data.fill(0)
		hitbox_data.resize(max_indexes*max_attacks*max_windows)
		hitbox_data.fill(0)
		hitbox_amount.resize(max_attacks)
		hitbox_amount.fill(0)
		load_proj_attack()
		load_swing_attack()
		
	
	func load_swing_attack():
		set_attack_value(AT.SWING, AG.NUM_WINDOWS, 3);
		
		set_window_value(AT.SWING, 1, AG.WINDOW_TYPE, 1);
		set_window_value(AT.SWING, 1, AG.WINDOW_HAS_CUSTOM_FRICTION, 1);
		set_window_value(AT.SWING, 1, AG.WINDOW_CUSTOM_FRICTION, .85);
		set_window_value(AT.SWING, 1, AG.WINDOW_LENGTH, 10);
		set_window_value(AT.SWING, 1, AG.WINDOW_ANIM_FRAMES, 3);
		set_window_value(AT.SWING, 1, AG.WINDOW_HAS_SFX, 1);
		set_window_value(AT.SWING, 1, AG.WINDOW_SFX, 0);
		set_window_value(AT.SWING, 1, AG.WINDOW_SFX_FRAME, 2);

		set_window_value(AT.SWING, 2, AG.WINDOW_TYPE, 1);
		set_window_value(AT.SWING, 2, AG.WINDOW_HAS_CUSTOM_FRICTION, 1);
		set_window_value(AT.SWING, 2, AG.WINDOW_CUSTOM_FRICTION, .1);
		set_window_value(AT.SWING, 2, AG.WINDOW_LENGTH, 3);
		set_window_value(AT.SWING, 2, AG.WINDOW_SPEED_TYPE, 0);
		set_window_value(AT.SWING, 2, AG.WINDOW_SPEED, 400.0);
		set_window_value(AT.SWING, 2, AG.WINDOW_ANIM_FRAMES, 1);
		set_window_value(AT.SWING, 2, AG.WINDOW_ANIM_FRAME_START, 3);

		set_window_value(AT.SWING, 3, AG.WINDOW_TYPE, 1);
		set_window_value(AT.SWING, 3, AG.WINDOW_HAS_CUSTOM_FRICTION, 1);
		set_window_value(AT.SWING, 3, AG.WINDOW_CUSTOM_FRICTION, 1);
		set_window_value(AT.SWING, 3, AG.WINDOW_LENGTH, 50);
		set_window_value(AT.SWING, 3, AG.WINDOW_ANIM_FRAMES, 4);
		set_window_value(AT.SWING, 3, AG.WINDOW_ANIM_FRAME_START, 4);
		
		set_num_hitboxes(AT.SWING, 1)
		
		set_hitbox_value(AT.SWING, 1, HG.WINDOW, 2);
		set_hitbox_value(AT.SWING, 1, HG.LIFETIME, 3);
		set_hitbox_value(AT.SWING, 1, HG.HITBOX_FORW, 50);
		set_hitbox_value(AT.SWING, 1, HG.HITBOX_SIDE, 0);
		set_hitbox_value(AT.SWING, 1, HG.WIDTH, 80);
		set_hitbox_value(AT.SWING, 1, HG.HEIGHT, 23);
		set_hitbox_value(AT.SWING, 1, HG.DAMAGE, 7);
		
	func load_proj_attack():
		set_attack_value(AT.PROJ, AG.NUM_WINDOWS, 3);
		
		set_window_value(AT.PROJ, 1, AG.WINDOW_TYPE, 1);
		set_window_value(AT.PROJ, 1, AG.WINDOW_LENGTH, 5);
		set_window_value(AT.PROJ, 1, AG.WINDOW_ANIM_FRAMES, 3);
		set_window_value(AT.PROJ, 1, AG.WINDOW_HAS_SFX, 1);
		set_window_value(AT.PROJ, 1, AG.WINDOW_SFX, 0);
		set_window_value(AT.PROJ, 1, AG.WINDOW_SFX_FRAME, 2);

		set_window_value(AT.PROJ, 2, AG.WINDOW_TYPE, 1);
		set_window_value(AT.PROJ, 2, AG.WINDOW_LENGTH, 3);
		set_window_value(AT.PROJ, 2, AG.WINDOW_ANIM_FRAMES, 1);
		set_window_value(AT.PROJ, 2, AG.WINDOW_ANIM_FRAME_START, 3);

		set_window_value(AT.PROJ, 3, AG.WINDOW_TYPE, 1);
		set_window_value(AT.PROJ, 3, AG.WINDOW_LENGTH, 13);
		set_window_value(AT.PROJ, 3, AG.WINDOW_ANIM_FRAMES, 4);
		set_window_value(AT.PROJ, 3, AG.WINDOW_ANIM_FRAME_START, 4);

func _init():
	attack_data = AttackData.new()
	
