extends Node

var sap_slime_attack_data : SapSlimeAttackData

class SapSlimeAttackData:
	var max_attacks = 1
	var max_indexes = 30
	var max_windows = 10
	
	var PS = Globals.SS_PS
	var AT = Globals.SS_AT
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
		load_lunge_attack()
		
	
	func load_lunge_attack():
		set_attack_value(AT.LUNGE, AG.NUM_WINDOWS, 3);
		
		set_window_value(AT.LUNGE, 1, AG.WINDOW_TYPE, 1);
		set_window_value(AT.LUNGE, 1, AG.WINDOW_HAS_CUSTOM_FRICTION, 1);
		set_window_value(AT.LUNGE, 1, AG.WINDOW_CUSTOM_FRICTION, .85);
		set_window_value(AT.LUNGE, 1, AG.WINDOW_LENGTH, 30);
		set_window_value(AT.LUNGE, 1, AG.WINDOW_ANIM_FRAMES, 3);
		set_window_value(AT.LUNGE, 1, AG.WINDOW_HAS_SFX, 1);
		set_window_value(AT.LUNGE, 1, AG.WINDOW_SFX, 0);
		set_window_value(AT.LUNGE, 1, AG.WINDOW_SFX_FRAME, 2);

		set_window_value(AT.LUNGE, 2, AG.WINDOW_TYPE, 1);
		set_window_value(AT.LUNGE, 2, AG.WINDOW_HAS_CUSTOM_FRICTION, 1);
		set_window_value(AT.LUNGE, 2, AG.WINDOW_CUSTOM_FRICTION, .7);
		set_window_value(AT.LUNGE, 2, AG.WINDOW_LENGTH, 12);
		set_window_value(AT.LUNGE, 2, AG.WINDOW_SPEED_TYPE, 0);
		set_window_value(AT.LUNGE, 2, AG.WINDOW_SPEED, 400.0);
		set_window_value(AT.LUNGE, 2, AG.WINDOW_ANIM_FRAMES, 3);
		set_window_value(AT.LUNGE, 2, AG.WINDOW_ANIM_FRAME_START, 3);

		set_window_value(AT.LUNGE, 3, AG.WINDOW_TYPE, 1);
		set_window_value(AT.LUNGE, 3, AG.WINDOW_HAS_CUSTOM_FRICTION, 1);
		set_window_value(AT.LUNGE, 3, AG.WINDOW_CUSTOM_FRICTION, 1);
		set_window_value(AT.LUNGE, 3, AG.WINDOW_LENGTH, 15);
		set_window_value(AT.LUNGE, 3, AG.WINDOW_ANIM_FRAMES, 4);
		set_window_value(AT.LUNGE, 3, AG.WINDOW_ANIM_FRAME_START, 6);
		
		set_num_hitboxes(AT.LUNGE, 1)
		
		set_hitbox_value(AT.LUNGE, 1, HG.WINDOW, 2);
		set_hitbox_value(AT.LUNGE, 1, HG.LIFETIME, 12);
		set_hitbox_value(AT.LUNGE, 1, HG.HITBOX_FORW, 0);
		set_hitbox_value(AT.LUNGE, 1, HG.HITBOX_SIDE, 0);
		set_hitbox_value(AT.LUNGE, 1, HG.WIDTH, 12);
		set_hitbox_value(AT.LUNGE, 1, HG.HEIGHT, 12);
		set_hitbox_value(AT.LUNGE, 1, HG.DAMAGE, 7);

func _init():
	sap_slime_attack_data = SapSlimeAttackData.new()
	
