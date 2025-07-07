# scripts/main.gd
extends Node2D

# @onready - переменная инициализируется при готовности сцены
@onready var camera = $MainCamera
@onready var bg = $Background
@onready var container = $AchievementContainer
@onready var editor_ui: CanvasLayer = %EditorUI

var map_size = Vector2(2000, 2000)  # Начальный размер карты
var current_achievement = null  # Для отслеживания выбранного достижения

func _ready():
	# Настраиваем фон
	bg.size = map_size
	bg.color = Color.WHITE
	
	# Центрируем камеру
	camera.position = map_size / 2
	camera.zoom = Vector2(1, 1)  # Масштаб 100%
	
	editor_ui.connect("add_image_requested", _on_add_image_requested)
	editor_ui.connect("bg_color_changed", _on_bg_color_changed)
	editor_ui.connect("map_size_changed", _on_map_size_changed)
	editor_ui.connect("zoom_level_changed", _on_zoom_level_changed)
	editor_ui.connect("create_achievement_requested", _on_create_achievement_requested)

func _on_create_achievement_requested():
	create_new_achievement()

func create_new_achievement():
	# Создаем экземпляр сцены достижения
	var new_ach = preload("res://scenes/achievement.tscn").instantiate()
	
	# Начальные настройки
	new_ach.position = camera.position  # По центру камеры
	new_ach.scale = Vector2(0.5, 0.5)   # Начальный масштаб
	
	# Добавляем в контейнер
	container.add_child(new_ach)
	
	# Выбираем это достижение
	select_achievement(new_ach)
	
	return new_ach

func select_achievement(achievement):
	# Снимаем выделение с предыдущего
	if current_achievement:
		current_achievement.is_selected = false
		current_achievement.update_appearance()
	
	# Выбираем новое
	current_achievement = achievement
	if current_achievement:
		current_achievement.is_selected = true
		current_achievement.update_appearance()
	# Показываем свойства в UI
	editor_ui.show_properties_for(current_achievement)

func _on_add_image_requested():
	# Покажем диалог выбора файла
	$FileDialog.popup_centered()

func _on_bg_color_changed(color):
	bg.color = color

func _on_map_size_changed(new_size):
	map_size = new_size
	bg.size = new_size

func _on_zoom_level_changed(zoom_value):
	camera.zoom = Vector2(zoom_value, zoom_value)

# Добавляем FileDialog
func _on_file_dialog_file_selected(path):
	var texture = load(path)
	if texture:
		var new_ach = preload("res://scenes/achievement.tscn").instantiate()
		new_ach.get_node("Icon").texture = texture
		new_ach.position = camera.position  # По центру камеры
		container.add_child(new_ach)

func _input(event):
	# Перемещение камеры правой кнопкой мыши
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		camera.position -= event.relative * camera.zoom
	
	# Масштабирование колесом
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
			editor_ui.update_zoom_slider(camera.zoom.x)  # Обновим UI
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 0.9
			editor_ui.update_zoom_slider(camera.zoom.x)
