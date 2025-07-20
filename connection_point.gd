class_name  ConnectionPoint
extends Node2D

signal position_changed()

var drag = false
var drag_offset = Vector2.ZERO
var connection: Node # Ссылка на родительское соединение
var mouse_over = false

func _ready():
	# Настраиваем коллизию
	$Area2D.input_event.connect(_on_area_input_event)
	$Area2D.mouse_entered.connect(_on_mouse_entered)
	$Area2D.mouse_exited.connect(_on_mouse_exited)
	z_index = 15
	#$Area2D.top_level = true

func _on_mouse_entered():
	mouse_over = true
	scale = Vector2(1.2, 1.2) # Увеличиваем при наведении

func _on_mouse_exited():
	mouse_over = false
	scale = Vector2(1.0, 1.0) # Возвращаем нормальный размер

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Клик по точке ЛЕВОЙ!")
				# Помечаем событие как обработанное
				get_viewport().set_input_as_handled()
				print("Клик по точке Перехвачен")
				# Начало перетаскивания
				drag = true
				drag_offset = global_position - get_global_mouse_position()
				# Отключаем перетаскивание камеры
				var camera = get_tree().get_first_node_in_group("main_camera")
				if camera:
					camera.disable_camera_drag()
				# Поднимаем точку наверх
			else:
				# Конец перетаскивания
				drag = false
				# Сообщаем соединению об обновлении
				if connection:
					connection.update_connection()
		# Удаление по правому клику
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if connection:
				connection.remove_point(self)
			queue_free()

func is_mouse_over():
	return mouse_over

func _process(_delta):
	if drag:
		global_position = get_global_mouse_position() + drag_offset
		position_changed.emit()
