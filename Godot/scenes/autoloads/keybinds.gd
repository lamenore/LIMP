extends CanvasLayer


const KeybindsAction := preload("res://scenes/autoloads/keybinds_action.tscn")

export var show_ui_actions := false
export var ui_actions_order: PoolStringArray
export var actions_order: PoolStringArray

var current_action: VBoxContainer


func _ready() -> void:
	set_process_input(false)
	if show_ui_actions:
		for action in ui_actions_order:
			add_action(action)
	for action in actions_order:
		add_action(action)
	if $PopupPanel/ScrollContainer/Actions.get_child_count() != 0:
		$PopupPanel/ScrollContainer/Actions.get_child($PopupPanel/ScrollContainer/Actions.get_child_count() - 1).queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		get_tree().set_input_as_handled()
		if not InputMap.action_has_event(current_action.action, event):
			InputMap.action_add_event(current_action.action, event)
			current_action.add_key(event)
		$Wait.hide()


func add_action(action: String) -> void:
	var a := KeybindsAction.instance()
	a.init(action)
	$PopupPanel/ScrollContainer/Actions.add_child(a)
	a.connect("rebind", self, "on_rebind")
	$PopupPanel/ScrollContainer/Actions.add_child(HSeparator.new())


func show_keybinds() -> void:
	$PopupPanel.popup_centered()


func on_rebind(a: VBoxContainer) -> void:
	set_process_input(true)
	current_action = a
	$Wait.popup_centered()


func _on_Wait_popup_hide() -> void:
	set_process_input(false)
	current_action = null
