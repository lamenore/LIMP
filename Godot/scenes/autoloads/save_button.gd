extends MenuButton

signal load_requested()
signal overwrite_requested()
signal delete_requested()


func _ready() -> void:
	get_popup().connect("id_pressed", self, "on_popup_menu_id_pressed")
	

func on_popup_menu_id_pressed(id: int) -> void:
	match id:
		0:
			emit_signal("load_requested")
		1:
			emit_signal("overwrite_requested")
		2:
			emit_signal("delete_requested")
