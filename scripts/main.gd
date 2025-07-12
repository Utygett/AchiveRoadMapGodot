extends Node2D

@onready var grid_background: TileMapLayer = %GridBackground

func _ready():
	# 1. Получаем данные из TileMapLayer
	var tile_set = grid_background.tile_set
	var source_id = tile_set.get_source_id(0)
	
	# 2. Размер карты в тайлах
	var map_size = Vector2i(20, 15)
	
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
	border_line.default_color = Color.RED
	border_line.points = [
		Vector2(0, 0),
		Vector2(size.x, 0),
		Vector2(size.x, size.y),
		Vector2(0, size.y),
		Vector2(0, 0)
	]
	add_child(border_line)

#func setup_camera(map_size: Vector2):
	#var camera = Camera2D.new()
	#add_child(camera)
	#camera.make_current()
	#
	## Настройка ограничений камеры
	#camera.limit_left = 0
	#camera.limit_top = 0
	#camera.limit_right = map_size.x
	#camera.limit_bottom = map_size.y
	#
	## Начальный зум
	#camera.zoom = Vector2(0.8, 0.8)
