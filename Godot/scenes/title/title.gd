extends Control


signal change_scene(to)


func _ready() -> void:
	$VBoxContainer/Quit.visible = not OS.get_name() == "HTML5"
	var global_player = get_node("/root/FightMusic")
	global_player.change_music("res://assets/music/title_screen.ogg")

func _on_Start_pressed() -> void:
	emit_signal("change_scene", "res://scenes/Playground.tscn")

func _on_Load_pressed() -> void:
	SaveLoad.show_save_load(false)


func _on_Settings_pressed() -> void:
	Settings.show_settings(false)


func _on_Credits_pressed() -> void:
	emit_signal("change_scene", "res://scenes/title/credits.tscn")


func _on_Quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
