extends Line2D

@export var collision_width: float = 10.0  # Ширина области коллизии
@onready var area: Area2D = %Area2D

func _ready() -> void:
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)

func _on_mouse_entered():
	print("Мышка на линии!")

func _on_mouse_exited():
	print("Мышка ушла с линии!")

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var click_position = to_local(event.global_position)
			add_point_at_position(click_position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Клик по линии ПРАВОЙ!")



func generate_collision():
	var points = get_points()
	if points.size() < 2:
		return
	
	# Удаляем старый полигон
	if area.get_child_count() > 0:
		area.get_child(0).queue_free()
	
	var collision = CollisionPolygon2D.new()
	area.add_child(collision)
	
	# Простой вариант для прямых линий
	if points.size() == 2:
		var dir = (points[1] - points[0]).normalized().orthogonal()
		collision.polygon = PackedVector2Array([
			points[0] + dir * collision_width,
			points[1] + dir * collision_width,
			points[1] - dir * collision_width,
			points[0] - dir * collision_width
		])
		return
	else:
		 # Создаем полигон
		var polygon = PackedVector2Array()
	# Верхняя часть полигона
		for i in range(points.size()):
			var dir: Vector2
			if i == 0:
				dir = (points[1] - points[0]).normalized().orthogonal()
			elif i == points.size() - 1:
				dir = (points[i] - points[i-1]).normalized().orthogonal()
			else:
				var prev_dir = (points[i] - points[i-1]).normalized()
				var next_dir = (points[i+1] - points[i]).normalized()
				dir = (prev_dir + next_dir).normalized().orthogonal()
			polygon.append(points[i] + dir * collision_width)
		# Нижняя часть полигона (в обратном порядке)
		for i in range(points.size() - 1, -1, -1):
			var dir: Vector2
			if i == 0:
				dir = (points[1] - points[0]).normalized().orthogonal()
			elif i == points.size() - 1:
				dir = (points[i] - points[i-1]).normalized().orthogonal()
			else:
				var prev_dir = (points[i] - points[i-1]).normalized()
				var next_dir = (points[i+1] - points[i]).normalized()
				dir = (prev_dir + next_dir).normalized().orthogonal()
			polygon.append(points[i] - dir * collision_width)
		collision.polygon = polygon

# Добавляем точку в ближайшем месте на линии
func add_point_at_position(position: Vector2):
	var points = get_points()
	
	# Если линия пустая - просто добавляем точку
	if points.size() == 0:
		add_point(position)
		return
	
	# Если только одна точка - добавляем вторую
	if points.size() == 1:
		add_point(position)
		return
	
	# Ищем ближайший сегмент для вставки новой точки
	var min_distance = INF
	var insert_index = -1
	
	for i in range(points.size() - 1):
		var segment_start = points[i]
		var segment_end = points[i + 1]
		
		# Находим ближайшую точку на сегменте
		var closest = Geometry2D.get_closest_point_to_segment(position, segment_start, segment_end)
		var distance = position.distance_to(closest)
		
		if distance < min_distance:
			min_distance = distance
			insert_index = i + 1
	
	# Проверяем, не слишком ли далеко клик
	if min_distance > collision_width * 2:
		return
	
	# Вставляем новую точку МЕЖДУ существующими точками
	# Это "сломает" линию
	if insert_index > 0 and insert_index < points.size():
		add_point(position, insert_index)
		print("Добавлена точка #", insert_index, " между точками ", insert_index-1, " и ", insert_index)
	else:
		# Если не удалось найти место для вставки, добавляем в конец
		add_point(position)
