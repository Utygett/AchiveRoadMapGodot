extends Node2D

@onready var camera = $Camera2D
const MAP_SIZE = Vector2(2000, 2000)
const ZOOM_SPEED = 0.1
const ZOOM_MIN = 0.5
const ZOOM_MAX = 2.0

var zoom_factor = 1.0
var drag_start_position = Vector2.ZERO
var camera_start_position = Vector2.ZERO
var last_touch_distance = 0.0

func _ready():
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_SIZE.x
	camera.limit_bottom = MAP_SIZE.y
	camera.zoom = Vector2(zoom_factor, zoom_factor)
	
	# Создаем сетку и границы
	create_grid()
	create_borders()
	
	# Оптимизации для мобильных
	if OS.has_feature("mobile"):
		get_viewport().msaa_2d = Viewport.MSAA_4X
		get_viewport().canvas_item_default_texture_filter = Viewport.CANVAS_ITEM_TEXTURE_FILTER_NEAREST

func create_grid():
	# Используйте либо шейдерный вариант, либо код выше
	# ...

func create_borders():
	var border = Line2D.new()
	border.width = 10.0
	border.default_color = Color(0.9, 0.2, 0.1)
	border.closed = true
	
	var points = [
		Vector2(0, 0),
		Vector2(MAP_SIZE.x, 0),
		Vector2(MAP_SIZE.x, MAP_SIZE.y),
		Vector2(0, MAP_SIZE.y)
	]
	
	border.points = points
	add_child(border)

func _input(event):
	# Перемещение ЛКМ
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_start_position = event.position
				camera_start_position = camera.position
			else:
				camera.position = camera_start_position - (event.position - drag_start_position) * zoom_factor
	
	# Зум колесиком
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_factor = clamp(zoom_factor - ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_factor = clamp(zoom_factor + ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
		camera.zoom = Vector2(zoom_factor, zoom_factor)
	
	# Перемещение пальцем
	if event is InputEventScreenDrag:
		if event.index == 0:  # Главный палец
			camera.position -= event.relative * zoom_factor
	
	# Зум двумя пальцами
	if event is InputEventScreenTouch:
		if get_viewport().get_touches().size() == 2:
			var touches = get_viewport().get_touches()
			var touch1 = touches[0].position
			var touch2 = touches[1].position
			
			if !event.pressed:
				last_touch_distance = touch1.distance_to(touch2)
			else:
				var new_distance = touch1.distance_to(touch2)
				if last_touch_distance > 0:
					zoom_factor = clamp(zoom_factor * (last_touch_distance / new_distance), ZOOM_MIN, ZOOM_MAX)
					camera.zoom = Vector2(zoom_factor, zoom_factor)
