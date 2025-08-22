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
var client_uid = ""
var bg_url = ""

func _ready():
	# Создаём uuid
	client_uid = UuidManager.generate_uuid()
	# Соединяем диалог создания достижения с картой
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
	
	# 1) показать кеш оффлайн (мгновенно)
	var cached := DataStore.load_map_from_cache(map_id)
	if cached:
		_rebuild_from_models(map_id)
	# 2) подписка — когда придут данные с сервера или что-то изменится
	DataStore.map_loaded.connect(func(mid):
		if mid == map_id:
			_rebuild_from_models(map_id)
	)
	DataStore.achievement_upserted.connect(func(mid, _a):
		if mid == map_id:
			# точечное обновление можно позже, пока — полная перерисовка:
			_rebuild_from_models(map_id)
	)
	DataStore.connection_upserted.connect(func(mid, _c):
		if mid == map_id:
			_rebuild_from_models(map_id)
	)
	DataStore.achievement_removed.connect(func(mid, _id):
		if mid == map_id:
			_rebuild_from_models(map_id)
	)
	DataStore.connection_removed.connect(func(mid, _id):
		if mid == map_id:
			_rebuild_from_models(map_id)
	)
	# 3) Запрос к серверу как и раньше
	var server = get_tree().get_first_node_in_group("server_request")
	server.load_map_data(map_id)

func _rebuild_from_models(mid: int) -> void:
	if mid != map_id: return
	var m := DataStore.get_map(map_id)
	if m == null: return

	# очистим контейнеры
	achievement_container.queue_free()
	var new_container := Node2D.new()
	new_container.name = "AchievementContainer"
	add_child(new_container)
	achievement_container = new_container

	# спавн достижений
	for ach in m.achievements:
		var node := add_achievement(ach.id, ach.position, ach.title, ach.icon_url) as Achievement
		node.bind_model(ach)  # передаём модель
		# (шаг 5) — позже передадим node.model = ach
	# спавн связей
	for conn in m.connections:
		var node := add_connection(conn.id, conn.from_achievement_id, conn.to_achievement_id, conn.points) as AchieveConnection
		node.bind_model(conn)

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
	return active_connection

func get_achieve_from_id(achieve_id: int):
	for i in range(achievement_container.get_child_count()):
		var achive = achievement_container.get_child(i) as Achievement
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
