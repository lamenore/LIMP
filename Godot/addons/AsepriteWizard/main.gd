extends Node


const Message := preload("res://scenes/main/message.tscn")

var current_scene: Node


func _ready() -> void:
	Settings.connect("change_scene", self, "change_scene", [], CONNECT_DEFERRED)
	call_deferred("change_scene", "res://scenes/title/title.tscn")


func change_scene(to: String) -> void:
	if current_scene:
		current_scene.free()
	current_scene = load(to).instance()
	add_child(current_scene)
	move_child(current_scene, 0)
	if current_scene.has_signal("change_scene"):
		current_scene.connect("change_scene", self, "change_scene", [], CONNECT_DEFERRED)


func get_save_data() -> Dictionary:
	return {}


func load_save_data(_data: Dictionary) -> void:
	pass


func show_message(text: String) -> void:
	var m := Message.instance()
	add_child(m)
	m.show_message(text)
