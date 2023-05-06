extends Control


signal change_scene(to)


func _ready() -> void:
	$VBoxContainer/Quit.visible = not OS.get_name() == "HTML5"


func _on_Start_pressed() -> void:
	pass # Replace with function body.


func _on_Load_pressed() -> void:
	SaveLoad.show_save_load(false)


func _on_Settings_pressed() -> void:
	Settings.show_settings(false)


func _on_Credits_pressed() -> void:
	emit_signal("change_scene", "res://scenes/title/credits.tscn")


func _on_Quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
