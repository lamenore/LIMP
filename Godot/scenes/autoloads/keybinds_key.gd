extends HBoxContainer


var action: String
var key: InputEvent


func init(a: String, k: InputEvent) -> void:
	action = a
	key = k
	$Label.text = key.as_text().capitalize()


func _on_Delete_pressed() -> void:
	InputMap.action_erase_event(action, key)
	queue_free()
