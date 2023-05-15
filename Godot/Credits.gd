extends Control

signal change_scene(to)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var global_player = get_node("/root/FightMusic")
	global_player.change_music("res://assets/music/title_screen.ogg")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	emit_signal("change_scene", "res://scenes/title/title.tscn")


func _on_Back_pressed():
	emit_signal("change_scene", "res://scenes/title/title.tscn")
