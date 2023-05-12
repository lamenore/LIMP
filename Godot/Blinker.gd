extends Node


onready var blink_timer = $BlinkTimer
onready var duration_timer = $DurationTimer
var blink_object: Node2D

func start_blinking(object, duration_frames):
	blink_object = object
	duration_timer.wait_time = duration_frames/60
	duration_timer.start()
	blink_timer.start()
	



func _on_BlinkTimer_timeout():
	blink_object.visible = !blink_object.visible


func _on_DurationTimer_timeout():
	blink_timer.stop()
	blink_object.visible = true
