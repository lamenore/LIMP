extends CanvasLayer


signal change_scene(to)

const PATH := "user://settings.ini"

var config: ConfigFile


func _ready() -> void:
	$PopupPanel/VBoxContainer/HBoxContainer4.visible = not OS.get_name() == "HTML5"
	$PopupPanel/VBoxContainer/HBoxContainer6.visible = not OS.get_name() == "HTML5"
	config = ConfigFile.new()
	if config.load(PATH) == OK:
		var fullscreen = config.get_value("display", "fullscreen", false)
		if fullscreen is bool:
			OS.window_fullscreen = fullscreen
			$PopupPanel/VBoxContainer/HBoxContainer/Fullscreen.pressed = fullscreen
		else:
			config.set_value("display", "fullscreen", false)
		var borderless = config.get_value("display", "borderless", false)
		if borderless is bool:
			OS.window_borderless = borderless
			$PopupPanel/VBoxContainer/HBoxContainer4/Borderless.pressed = borderless
		else:
			config.set_value("display", "borderless", false)
		var vsync = config.get_value("display", "vsync", true)
		if vsync is bool:
			OS.vsync_enabled = vsync
			$PopupPanel/VBoxContainer/HBoxContainer6/VSync.pressed = vsync
		else:
			config.set_value("display", "vsync", true)
		var brightness = config.get_value("display", "brightness", 1.0)
		if brightness is float:
			GlobalEnvironment.environment.adjustment_brightness = brightness
			$PopupPanel/VBoxContainer/HBoxContainer5/Brightness.value = brightness
		else:
			config.set_value("display", "brightness", 1.0)
		var sound = config.get_value("audio", "sound", 1.0)
		if sound is float:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(sound))
			$PopupPanel/VBoxContainer/HBoxContainer2/Sound.value = sound
		else:
			config.set_value("audio", "sound", 1.0)
		var music = config.get_value("audio", "music", 1.0)
		if music is float:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music))
			$PopupPanel/VBoxContainer/HBoxContainer3/Music.value = music
		else:
			config.set_value("audio", "music", 1.0)
		config.save(PATH)


func show_settings(can_quit := true) -> void:
	get_tree().paused = true
	$PopupPanel/VBoxContainer/Quit.visible = can_quit
	$PopupPanel.popup_centered()


func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed
	config.set_value("display", "fullscreen", button_pressed)
	config.save(PATH)


func _on_PopupPanel_popup_hide() -> void:
	get_tree().paused = false


func _on_Sound_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(value))
	config.set_value("audio", "sound", value)
	config.save(PATH)


func _on_Music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))
	config.set_value("audio", "music", value)
	config.save(PATH)


func _on_Keybinds_pressed() -> void:
	Keybinds.show_keybinds()


func _on_Borderless_toggled(button_pressed: bool) -> void:
	OS.window_borderless = button_pressed
	config.set_value("display", "borderless", button_pressed)
	config.save(PATH)


func _on_Brightness_value_changed(value: float) -> void:
	GlobalEnvironment.environment.adjustment_brightness = value
	config.set_value("display", "brightness", value)
	config.save(PATH)


func _on_BrightnessReset_pressed() -> void:
	$PopupPanel/VBoxContainer/HBoxContainer5/Brightness.value = 1.0
	_on_Brightness_value_changed(1.0)


func _on_VSync_toggled(button_pressed: bool) -> void:
	OS.vsync_enabled = button_pressed
	config.set_value("display", "vsync", button_pressed)
	config.save(PATH)


func _on_Quit_pressed() -> void:
	emit_signal("change_scene", "res://scenes/title/title.tscn")
