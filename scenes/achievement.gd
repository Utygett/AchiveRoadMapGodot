# achievement.gd
extends Node2D

signal is_dragging_changed(drag :bool)
# Настройки
@export var achievement_name: String = "Новое достижение"
@export var icon: Texture2D
@export var description: String = "Описание достижения"
@onready var name_label: Label = %NameLabel
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var area_2d: Area2D = %Area2D


var is_dragging = false
var drag_offset = Vector2.ZERO
var mouse_over = false
var base_scale = Vector2.ONE  # Сохраняем базовый размер
var base_modulate = Color.WHITE  # Сохраняем базовый цвет
# Новые переменные для управления связями
var is_connection_started = false
var current_connection: Node2D = null
var connections: Array = []  # Все связанные связи

func _ready():
	# Устанавливаем иконку
	sprite_2d.texture = icon
	base_scale = scale
	base_modulate = modulate
	# Настраиваем текст (если есть Label)
	name_label.text = achievement_name
	
	# Настраиваем область взаимодействия
	area_2d.input_event.connect(_on_area_input_event)
	area_2d.mouse_entered.connect(_on_area_mouse_entered)
	area_2d.mouse_exited.connect(_on_area_mouse_exited)

func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Начало перетаскивания
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()
			
			# Поднимаем на самый верхний слой
			z_index = 100
			
			# Отключаем перетаскивание камеры
			var camera = get_tree().get_first_node_in_group("main_camera")
			if camera:
				camera.disable_camera_drag()
			
			# Помечаем событие как обработанное
			get_viewport().set_input_as_handled()
			
			# Эффект "поднятия"
			var lift_tween = create_tween()
			lift_tween.tween_property(self, "scale", base_scale * Vector2(1.05, 1.05), 0.1)
			lift_tween.parallel().tween_property(self, "modulate", Color(1.2, 1.2, 1.2), 0.1)
		else:
			# Конец перетаскивания
			is_dragging = false
			
			# Включаем перетаскивание камеры
			var camera = get_tree().get_first_node_in_group("main_camera")
			if camera:
				camera.enable_camera_drag()
			
			
			# Возвращаем на обычный слой
			z_index = 10 if mouse_over else 0
			
			# Возвращаем к нормальному виду
			var drop_tween = create_tween()
			drop_tween.tween_property(self, "scale", base_scale * (Vector2(1.1, 1.1) if mouse_over else Vector2.ONE), 0.2)
			drop_tween.parallel().tween_property(self, "modulate", base_modulate, 0.2)
	
	
	
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:
			## Начало перетаскивания
			#is_dragging = true
			#is_dragging_changed.emit(true)
			#drag_offset = global_position - get_global_mouse_position()
		#else:
			## Конец перетаскивания
			#is_dragging = false
			#is_dragging_changed.emit(false)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		show_context_menu()

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
	# Обновляем временное соединение
	if is_connection_started:
		update_connection_to(get_global_mouse_position())

func _on_area_mouse_entered():
	mouse_over = true
	# Анимация при наведении
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale * Vector2(1.1, 1.1), 0.2)
	z_index = 10  # Поднимаем на передний план

func _on_area_mouse_exited():
	mouse_over = false
	# Возвращаем к нормальному размеру
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale, 0.2)
	z_index = 0  # Возвращаем на обычный слой

func show_context_menu():
	# Создаем простое контекстное меню
	var menu = PopupMenu.new()
	menu.add_item("Просмотреть описание", 1)
	menu.add_item("Удалить", 2)
	menu.add_item("Начать соединение", 3)
	menu.add_item("Завершить соединение", 4)
	menu.add_item("Добавить кость в соединение", 5)
	menu.add_item("Удалить все соединения", 6)
	
	# Обновляем состояние пунктов меню
	menu.set_item_disabled(3, is_dragging || is_connection_started)  # Начать соединение
	menu.set_item_disabled(4, !is_connection_started)  # Завершить соединение
	menu.set_item_disabled(5, !is_connection_started)  # Добавить кость
	
	add_child(menu)
	
	
	
	menu.popup(Rect2(get_global_mouse_position(), Vector2(150, 80)))
	menu.id_pressed.connect(_on_menu_item_selected)

func _on_menu_item_selected(id):
	match id:
		1:
			print("Описание: ", description)
		2:
			queue_free()
		3:  # Начать соединение
			start_connection()
		4:  # Завершить соединение
			complete_connection(self)
		5:  # Добавить кость
			add_bone_to_connection()
		6:  # Удалить все соединения
			delete_all_connections()


func start_connection():
	if is_connection_started:
		return
	
	is_connection_started = true
	
	# Создаем новое соединение
	current_connection = preload("res://scenes/connection.tscn").instantiate()
	get_parent().add_child(current_connection)  # Добавляем на уровень карты
	
	# Настраиваем начальную точку соединения
	var mouse_pos = get_global_mouse_position()
	var anchor = get_connection_anchor(mouse_pos)
	current_connection.set_start_point(self, anchor)
	
	# Обновляем соединение в реальном времени
	update_connection_to(get_global_mouse_position())
	
	# Визуальная обратная связь
	modulate = Color(0.8, 1.0, 0.8)  # Легкая подсветка

func complete_connection(start_connection: Node2D):
	if !is_connection_started && start_connection:
		return
	
	# Настраиваем конечную точку соединения
	var mouse_pos = get_global_mouse_position()
	var anchor = get_connection_anchor(mouse_pos)
	current_connection.set_end_point(self, anchor)
	
	# Регистрируем связь в обоих достижениях
	connections.append(current_connection)
	start_connection.connections.append(current_connection)
	
	# Сбрасываем состояние
	reset_connection_state()
	
	# Визуальная обратная связь
	modulate = base_modulate
	start_connection.modulate = start_connection.base_modulate

func add_bone_to_connection():
	if is_connection_started && current_connection:
		current_connection.add_bone(get_global_mouse_position())

func delete_all_connections():
	for connection in connections:
		# Удаляем связь из связанного достижения
		if connection.to_achievement != self:
			connection.to_achievement.connections.erase(connection)
		connection.queue_free()
	
	connections.clear()

func update_connection_to(position: Vector2):
	if !is_connection_started:
		return
	
	current_connection.update_end_point(self, position)

func reset_connection_state():
	is_connection_started = false
	current_connection = null
	if modulate != base_modulate:
		modulate = base_modulate
	
# Функция для получения точки привязки на краю
func get_connection_anchor(target_position: Vector2) -> Vector2:
	var direction = (target_position - global_position).normalized()
	# Предположим, что спрайт имеет размер 64x64
	var sprite_size = $Sprite2D.texture.get_size() * scale
	var max_dim = max(sprite_size.x, sprite_size.y) / 2
	return direction * max_dim
