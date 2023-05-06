extends Node

class AttackData:
	var attack_data : Array
	var max_attacks = 10
	var max_attack_indexes = 10

	var window_data : Array
	var max_windows = 29
	
	func set_attack_value(attack: int, index: int, value: int):
		attack_data[attack*max_attacks + index] = value
	
	func set_window_value(attack: int, window: int, index: int, value: int):
		window_data[(attack*max_attacks + window)*max_windows + index] = value
	
	func get_window_value(attack: int, window: int, index: int):
		return window_data[(attack*max_attacks + window)*max_windows + index] = value
	
	func get_attack_value(attack: int, index: int):
		return attack_data[attack*max_attacks + index]
