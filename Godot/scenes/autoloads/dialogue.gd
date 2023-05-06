extends CanvasLayer


var lines := []
var current := -1

onready var title := $UI/Text/Title
onready var speech := $UI/Text/Speech


func _ready() -> void:
	$UI.hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") or event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		if $Timer.is_stopped():
			advance()
		else:
			$Timer.stop()
			speech.percent_visible = 1.0


func show_dialogue(l: Array) -> void:
	lines = l
	current = -1
	speech.show()
	set_process_input(true)
	advance()


func advance() -> void:
	current += 1
	if current >= lines.size():
		$UI.hide()
		set_process_input(false)
		return
	var line: Array = lines[current].split("|", true, 1)
	if line.size() == 0:
		advance()
		return
	if line.size() == 1:
		speech.bbcode_text = line[0]
	else:
		title.bbcode_text = line[0]
		speech.bbcode_text = line[1]
	speech.percent_visible = 0
	$Timer.start()


func _on_Timer_timeout() -> void:
	if not speech.percent_visible == 1.0:
		speech.visible_characters += 1
		$Timer.start()
