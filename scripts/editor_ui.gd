extends CanvasLayer

signal achive_created(data: Dictionary)

func _on_add_button_pressed() -> void:
	print("Вызвать диалог создания достижения")
	var dialog = preload("res://ui/create_achive_ui.tscn").instantiate()
	get_tree().root.add_child(dialog)
	# Подключаем сигналы
	dialog.created.connect(_on_achive_created)
	dialog.canceled.connect(_on_achive_canceled)

func _on_achive_created(data: Dictionary):
	print("Данные получены:", data)
	achive_created.emit(data)
	# Здесь сохраняем данные или передаем дальше
	#save_achive(name, image_url, description)

func _on_achive_canceled():
	print("Создание отменено")
