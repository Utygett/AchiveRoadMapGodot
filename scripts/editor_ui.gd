extends CanvasLayer


func _on_add_button_pressed() -> void:
	print("Вызвать диалог создания достижения")
	var dialog = preload("res://ui/create_achive_ui.tscn").instantiate()
	get_tree().root.add_child(dialog)
