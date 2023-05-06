extends AcceptDialog



func _ready() -> void:
	get_child(1).align = Label.ALIGN_CENTER
	get_child(1).valign = Label.VALIGN_CENTER


func show_message(text: String) -> void:
	dialog_text = text
	popup_centered()


func _on_Message_popup_hide() -> void:
	queue_free()
