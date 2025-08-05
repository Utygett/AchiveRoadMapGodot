extends Node2D

@onready var grid_background: TileMapLayer = %GridBackground
@onready var achievement_container: Node2D = %AchievementContainer
@onready var main_camera: Camera2D = %MainCamera
@onready var connection_manager: Node = $ConnectionManager
@onready var editor_ui: CanvasLayer = %EditorUI

var tile_width = 20
var tile_height = 15
var dragged_achievement = null
var achievement_map_name = "Math beginner"
var map_id = -1

func _ready():
	editor_ui.connect("achive_created", create_achive_from_dictionary)
	
	# 1. Получаем данные из TileMapLayer
	var tile_set = grid_background.tile_set
	var source_id = tile_set.get_source_id(0)
	map_id = 1
	# 2. Размер карты в тайлах
	var map_size = Vector2i(tile_width, tile_height)
	
	# 3. Заполняем слой
	for x in range(map_size.x):
		for y in range(map_size.y):
			grid_background.set_cell(
				Vector2i(x, y),   # Позиция ячейки
				source_id,        # ID источника
				Vector2i(0, 0)    # Координаты в атласе
			)
	
	# 4. Рассчитываем размер карты в пикселях
	var tile_size = tile_set.tile_size
	var pixel_size = Vector2(
		map_size.x * tile_size.x,
		map_size.y * tile_size.y
	)
	
	# 5. Создаем границы карты
	create_map_borders(pixel_size)
	
	
		# Добавляем тестовые достижения
	#add_achievement(Vector2(500, 300), "Сумма до 10", "res://assets/Sum_to_10.png")
	#add_achievement(Vector2(700, 300), "Сравнение", "res://assets/comprassion.png")
	
	var server = get_tree().get_first_node_in_group("server_request")
	server.load_map_data(map_id)

func create_map_borders(size: Vector2):
	# Создаем 4 коллайдера по краям карты
	var border = StaticBody2D.new()
	add_child(border)
	
	# Верхняя граница
	var top = CollisionShape2D.new()
	top.shape = RectangleShape2D.new()
	top.shape.size = Vector2(size.x, 20)
	top.position = Vector2(size.x/2, -10)
	border.add_child(top)
	
	# Нижняя граница
	var bottom = CollisionShape2D.new()
	bottom.shape = RectangleShape2D.new()
	bottom.shape.size = Vector2(size.x, 20)
	bottom.position = Vector2(size.x/2, size.y + 10)
	border.add_child(bottom)
	
	# Левая граница
	var left = CollisionShape2D.new()
	left.shape = RectangleShape2D.new()
	left.shape.size = Vector2(20, size.y)
	left.position = Vector2(-10, size.y/2)
	border.add_child(left)
	
	# Правая граница
	var right = CollisionShape2D.new()
	right.shape = RectangleShape2D.new()
	right.shape.size = Vector2(20, size.y)
	right.position = Vector2(size.x + 10, size.y/2)
	border.add_child(right)
	
	# Визуализация границ
	var border_line = Line2D.new()
	border_line.width = 4
	border_line.default_color = Color.ANTIQUE_WHITE
	border_line.points = [
		Vector2(0, 0),
		Vector2(size.x, 0),
		Vector2(size.x, size.y),
		Vector2(0, size.y),
		Vector2(0, 0)
	]
	add_child(border_line)

# В основной скрипт карты (Map.gd)
func add_achievement(id:int, achieve_position: Vector2, achieve_name: String, icon_path: String):
	var achievement_scene = preload("res://scenes/achievement.tscn")
	var new_achievement = achievement_scene.instantiate()
	# Настройка достижения
	new_achievement.achieve_id = id
	new_achievement.map_id = map_id
	new_achievement.position = achieve_position
	new_achievement.achievement_name = achieve_name
	new_achievement.icon = load(icon_path)
	new_achievement.connection_manager = connection_manager
	# Добавляем в контейнер
	achievement_container.add_child(new_achievement)
	return new_achievement

func add_connection(id: int, from_id: int, to_id: int, points: Array):
	var achieve_from = get_achieve_from_id(from_id)
	var achieve_to = get_achieve_from_id(to_id)
	connection_manager.start_connection(achieve_from)
	var active_connection = connection_manager.end_connection(achieve_to, true)
	active_connection.connection_id = id
	active_connection.map_id = map_id
	for point in points:
		active_connection.add_point_at_position(Vector2(point.x,point.y), true)

func get_achieve_from_id(achieve_id: int):
	for i in range(achievement_container.get_child_count()):
		var achive = achievement_container.get_child(i) as Achievment
		if achive.achieve_id == achieve_id:
			return achive
	return null 

# Функция для обработки перетаскивания
func _on_achievement_dragging(is_dragging, achievement):
	dragged_achievement = achievement if is_dragging else null
	main_camera.is_dragging_object = is_dragging

func create_achive_from_dictionary(data: Dictionary):
	var name = data.name
	var img_url = data.image_url if data.image_url else "res://assets/no_image.png"
	var description = data.description
	var timestamp = data.timestamp
	var achive = add_achievement(0, main_camera.global_position, name, img_url)
	achive.description = description
	achive.send_create_achievement()
