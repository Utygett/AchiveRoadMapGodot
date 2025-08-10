extends Node2D

@onready var map_container: Node2D = %MapContainer

func _ready() -> void:
	_load_scene("res://scenes/main.tscn") # начальная сцена
	print("Window size:", get_window().size)
	print("Viewport size:", get_viewport().size)
	var screen_size = get_window().size
	get_viewport().size = screen_size
	print("Screen size detected:", screen_size)

func _load_scene(path: String):
	#map_container.free_children()
	var scene = load(path).instantiate()
	map_container.add_child(scene)

func free_children():
	for c in map_container.get_children():
		c.queue_free()


func _on_home_button_pressed() -> void:
	var screen_size = get_window().size
	get_viewport().size = screen_size
	print("Screen size detected:", screen_size)
	print("Window size:", get_window().size)
	print("Viewport size:", get_viewport().size)


func _on_editor_button_pressed() -> void:
	free_children()
	_load_scene("res://scenes/main.tscn") # начальная сцена


func _on_achieve_button_pressed() -> void:
	free_children()
	_load_scene("res://scenes/MainScreen/AchievementListUi/AchievementUI.tscn")


func _on_progress_button_pressed() -> void:
	pass # Replace with function body.


func _on_profile_button_pressed() -> void:
	pass # Replace with function body.
