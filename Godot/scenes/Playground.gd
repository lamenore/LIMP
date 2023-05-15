extends Node

signal change_scene(to)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var global_player = get_node("/root/FightMusic")
	var music_area = get_node("BossMusicArea")
	music_area.connect("area_entered", global_player, "_on_MusicArea_entered")
	global_player.change_music("res://assets/music/vae_dungeon.ogg")

func _exit_tree():
	var global_player = get_node("/root/FightMusic")
	var music_area = get_node("BossMusicArea")
	music_area.disconnect("area_entered", global_player, "_on_MusicArea_entered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BossMusicArea_area_entered(area):
	pass


func _on_BossMusicArea_body_entered(body):
	if body.is_in_group("player"):
		get_node("/root/FightMusic").change_music("res://assets/music/confrontation.ogg")
