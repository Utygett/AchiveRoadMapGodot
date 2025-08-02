class_name  Achievment
extends Node2D
# Настройки
@export var achievement_name: String = "Новое достижение"
@export var icon: Texture2D
@export var description: String = "Описание достижения"
@export var connection_manager: Node
@onready var name_label: Label = %NameLabel
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var area_2d: Area2D = %Area2D
enum MenuItems {
  INFO,
  DELETE,
  START_CONNECTION,
  END_CONNECTION
}
	
	
var is_dragging = false
var drag_offset = Vector2.ZERO
var mouse_over = false #Мышь над объектом?
var base_scale = Vector2.ONE  # Сохраняем базовый размер
var base_modulate = Color.WHITE  # Сохраняем базовый цвет
# Новые переменные для управления связями
var is_connection_started = false
var connections_from: Array = []  # Исходящие связи
var connections_to: Array = []  # Входящие связи
var achieve_id = 0
var map_id = 0

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
	
	

func _on_area_input_event(viewport,event, _shape_idx):
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
			viewport.set_input_as_handled()
			
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
			z_index = 75 if mouse_over else 50
			# Возвращаем к нормальному виду
			var drop_tween = create_tween()
			drop_tween.tween_property(self, "scale", base_scale * (Vector2(1.1, 1.1) if mouse_over else Vector2.ONE), 0.2)
			drop_tween.parallel().tween_property(self, "modulate", base_modulate, 0.2)
			send_update_position_to_server()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		show_context_menu()

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		update_connection()

func _on_area_mouse_entered():
	mouse_over = true
	# Анимация при наведении
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale * Vector2(1.1, 1.1), 0.2)
	z_index = 75  # Поднимаем на передний план

func _on_area_mouse_exited():
	mouse_over = false
	# Возвращаем к нормальному размеру
	var tween = create_tween()
	tween.tween_property(self, "scale", base_scale, 0.2)
	z_index = 50  # Возвращаем на обычный слой

func show_context_menu():
	var menu = PopupMenu.new()
	
	# Добавление пунктов меню
	menu.add_item("Просмотреть описание", MenuItems.INFO)
	if !connection_manager.is_connection_start():
		menu.add_item("Начать соединение", MenuItems.START_CONNECTION)
	else:
		menu.add_item("Завершить соединение", MenuItems.END_CONNECTION)
	menu.add_item("Удалить", MenuItems.DELETE)
	
	# Добавляем к корневому viewport
	get_viewport().add_child(menu)
	
	# Получаем позицию мыши с учетом камеры
	var mouse_pos = get_viewport().get_mouse_position()
	menu.popup(Rect2(mouse_pos, Vector2.ZERO))
	
	# Обработка выбора и автоматическое удаление
	menu.id_pressed.connect(_on_menu_item_selected)
	menu.popup_hide.connect(menu.queue_free)

func _on_menu_item_selected(id):
	match id:
		MenuItems.INFO:
			print("Описание: ", description)
		MenuItems.DELETE:
			queue_free()
		MenuItems.START_CONNECTION:  # Начать соединение
			connection_manager.start_connection(self)
		MenuItems.END_CONNECTION:  # Завершить соединение
			connection_manager.end_connection(self)
		#5:  # Добавить кость
			#add_bone_to_connection()
		#6:  # Удалить все соединения
			#delete_all_connections()

func add_outgoing_connection(start_connection:Node2D):
	connections_from.append(start_connection)

func add_incoming_connection(end_connection):
	connections_to.append(end_connection)

func remove_outgoing_connection(start_connection:Node2D):
	connections_from.erase(start_connection)

func remove_incoming_connection(end_connection):
	connections_to.erase(end_connection)

func update_connection():
	for conn in connections_from:
		conn.update_connection()
	for conn in connections_to:
		conn.update_connection()

func send_update_position_to_server():
	var server = get_tree().get_first_node_in_group("server_request")
	server.update_achievement(self)

func send_create_achievement():
	var server = get_tree().get_first_node_in_group("server_request")
	server.create_achievement(self)
