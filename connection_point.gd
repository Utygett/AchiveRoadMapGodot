extends Node2D

var drag = false
var drag_offset = Vector2.ZERO
var connection: Node # Ссылка на родительское соединение

func _ready():
	# Настраиваем коллизию
	$Area2D.input_event.connect(_on_area_input_event)
	$Area2D.mouse_entered.connect(_on_mouse_entered)
	$Area2D.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	scale = Vector2(1.2, 1.2) # Увеличиваем при наведении

func _on_mouse_exited():
	scale = Vector2(1.0, 1.0) # Возвращаем нормальный размер

func _on_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Начало перетаскивания
				drag = true
				drag_offset = global_position - get_global_mouse_position()
				get_tree().set_input_as_handled()
				# Поднимаем точку наверх
				z_index = 1
			else:
				# Конец перетаскивания
				drag = false
				z_index = 0
				# Сообщаем соединению об обновлении
				if connection:
					connection.update_connection()
		
		# Удаление по правому клику
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if connection:
				connection.remove_point(self)
			queue_free()

func _process(_delta):
	if drag:
		global_position = get_global_mouse_position() + drag_offset
