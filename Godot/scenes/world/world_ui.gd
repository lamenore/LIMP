extends CanvasLayer

var show_settings := false

func _process(delta):
	if(show_settings and !get_tree().paused):
		show_settings = false
		Settings.show_settings()

func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		show_settings = true

func _on_Settings_pressed() -> void:
	print("test")
	Settings.show_settings()
	

func _on_SaveLoad_pressed() -> void:
	SaveLoad.show_save_load()
