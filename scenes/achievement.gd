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
	add_child(menu)
	
	menu.popup(Rect2(get_global_mouse_position(), Vector2(150, 80)))
	menu.id_pressed.connect(_on_menu_item_selected)

func _on_menu_item_selected(id):
	match id:
		1:
			print("Описание: ", description)
		2:
			queue_free()
