extends Control


signal change_scene(to)


func _on_Text_meta_clicked(meta) -> void:
	OS.shell_open(meta)


func _on_Back_pressed() -> void:
	emit_signal("change_scene", "res://scenes/title/title.tscn")
