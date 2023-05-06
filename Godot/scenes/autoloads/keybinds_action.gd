extends VBoxContainer


signal rebind(this)

const KeybindsKey := preload("res://scenes/autoloads/keybinds_key.tscn")

var action: String


func init(a: String) -> void:
	action = a
	$HBoxContainer/Action.text = action.capitalize()
	for key in InputMap.get_action_list(action):
		add_key(key)


func add_key(key: InputEvent) -> void:
	var k := KeybindsKey.instance()
	k.init(action, key)
	$MarginContainer/Keys.add_child(k)


func _on_Add_pressed() -> void:
	emit_signal("rebind", self)
