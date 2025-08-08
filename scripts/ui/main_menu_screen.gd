extends Control
# Скрипт управляет подгрузкой сцен в верхнюю часть (Content) и переключением по кнопкам.
# Привязывай узлы в сцене именно с такими именами (VBoxContainer/Panel/Content, BottomMenu, FadeRect).

@onready var sub_viewport: SubViewport = %SubViewport
@onready var panel: Panel = %Panel
@onready var sub_viewport_container: SubViewportContainer = %SubViewportContainer

# --- Вызов при старте: загружаем страницу по умолчанию
func _ready() -> void:
	# Можно вызвать асинхронно, но не блокируем _ready
	_load_to_subviewport("res://scenes/main.tscn")
	 # При старте задаём размер
	_update_viewport_size()
	# Если панель меняет размер, обновляем
	sub_viewport_container.connect("resized", Callable(self, "_update_viewport_size"))

func _update_viewport_size():
	sub_viewport.size = panel.size

func _load_to_subviewport(scene_path: String) -> void:
	# Очищаем предыдущие узлы внутри вьюпорта
	for child in sub_viewport.get_children():
		child.queue_free()

	# Загружаем сцену
	var packed_scene = load(scene_path)
	if packed_scene is PackedScene:
		var instance = packed_scene.instantiate()
		sub_viewport.add_child(instance)
	else:
		push_error("Не удалось загрузить сцену: " + scene_path)
		

func _on_home_button_pressed() -> void:
	pass # Replace with function body.


func _on_editor_button_pressed() -> void:
	pass # Replace with function body.


func _on_achiev_button_pressed() -> void:
	pass # Replace with function body.


func _on_progress_button_pressed() -> void:
	pass # Replace with function body.


func _on_profile_button_pressed() -> void:
	pass # Replace with function body.
