extends Control


# Declare member variables here. Examples:
var heart_size: int = 13


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Player_life_changed(player_hearts: float) -> void:
	print(player_hearts)
	$Hearts.rect_size.x = player_hearts * heart_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
