
extends Node2D

@onready var line: Line2D = %Line
@onready var arrow: Sprite2D = %Arrow
@onready var bones_container: Node2D = %Bones
@onready var conn_server_api: Node = %ConnServerApi

var from_achievement: Node2D = null
var to_achievement: Node2D = null
var from_anchor: Vector2 = Vector2.ZERO
var to_anchor: Vector2 = Vector2.ZERO


var mouse_over = false
var base_scale = Vector2.ONE  # Сохраняем базовый размер
var base_modulate = Color.WHITE  # Сохраняем базовый цвет
var connection_id = 0
var map_id = -1

func _ready() -> void:
	z_index = 15
	line.connect("remove_connection", remove_connection)



# Инициализация соединения
func initialize(from: Node2D, to: Node2D):
	from_achievement = from
	to_achievement = to
	conn_server_api.create_connection_on_server()
	update_connection()

# Инициализация соединения
func initialize_from_data(from: Node2D, to: Node2D):
	from_achievement = from
	to_achievement = to
	update_connection()


func update_end_point(achievement: Node2D, end_position: Vector2):
	to_achievement = achievement
	to_anchor = end_position if !achievement else end_position - achievement.global_position
	#update_connection()

func update_connection():
	# Обновляем только первую и последнюю точки
	
	if line.get_point_count() == 0:
		create_start_points()
	
	
	update_boundary_points()
	
	# Обновляем позиции всех точек-костей
	for i in range(1, line.get_point_count() - 1):
		var point = bones_container.get_child(i - 1)
		line.set_point_position(i, point.global_position)
	
	# Обновляем стрелку
	if line.get_point_count() > 1:
		var last_idx = line.get_point_count() - 1
		var segment_start = line.get_point_position(last_idx - 1)
		var segment_end = line.get_point_position(last_idx)
		arrow.global_position = segment_end
		arrow.rotation = (segment_end - segment_start).angle()
	
	line.generate_collision()

func create_start_points():
	#var point_scene = preload("res://scenes/connection_point.tscn")
	#var point_start = point_scene.instantiate()
	#var point_end = point_scene.instantiate()
	#bones_container.add_child(point_start)
	#bones_container.add_child(point_end)
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

func update_boundary_points():
	# Получаем спрайты достижений
	var start_sprite = from_achievement.get_node("Sprite2D")
	var end_sprite = to_achievement.get_node("Sprite2D")
	
	# Получаем глобальные прямоугольники спрайтов
	var start_rect = get_sprite_global_rect(start_sprite)
	var end_rect = get_sprite_global_rect(end_sprite)
	
	
	var point_after_start = to_achievement.global_position
	var point_before_start = from_achievement.global_position
	
	if line.get_point_count() > 2:
		point_after_start = line.get_point_position(1)
		point_before_start = line.get_point_position(line.get_point_count() - 2)
	
	# Рассчитываем точки на границах прямоугольников
	var start_point = calculate_boundary_point(
		from_achievement.global_position,
		point_after_start,
		start_rect
	)
	
	var end_point = calculate_boundary_point(
		to_achievement.global_position,
		point_before_start,
		end_rect
	)
	
	#var start_bone = bones_container.get_child(0) as ConnectionPoint
	#var end_bone = bones_container.get_child(bones_container.get_child_count() - 1) as ConnectionPoint
	#
	#start_bone.global_position = start_point
	#end_bone.global_position = end_point
	
	# Обновляем граничные точки
	line.set_point_position(0, start_point)
	line.set_point_position(line.get_point_count() - 1, end_point)
	
	
	# Обновляем стрелку
	if line.get_point_count() > 1:
		var last_idx = line.get_point_count() - 1
		var segment_start = line.get_point_position(last_idx - 1)
		var segment_end = line.get_point_position(last_idx)
		arrow.global_position = segment_end
		arrow.rotation = (segment_end - segment_start).angle()
		
	line.generate_collision()

# Добавление новой точки
func add_point_at_position(point_position: Vector2, load_from_server:bool = false):
	# Создаем экземпляр точки
	var point_scene = preload("res://scenes/connection_point.tscn")
	var point = point_scene.instantiate()
	point.global_position = point_position
	point.connection = self
	point.position_changed_finished.connect(_on_point_position_changed_finished)
	
	# Добавляем в контейнер костей
	bones_container.add_child(point)
	
	# Определяем индекс для вставки в линию
	var insert_index = find_closest_segment_index(point_position)
	
	# Добавляем точку в линию
	bones_container.move_child(point, insert_index - 1)  # Затем перемещаем на нужную позицию
	line.add_point(point_position, insert_index)
	
	# Обновляем соединение
	update_connection()
	if load_from_server == false:
		conn_server_api.update_connection_data()

# Удаление точки
func remove_point(point: Node2D):
	# Находим индекс точки в линии
	var point_index = -1
	for i in range(1, line.get_point_count() - 1):
		if line.get_point_position(i) == point.global_position:
			point_index = i
			break
	if point_index != -1:
		# Удаляем точку из линии
		line.remove_point(point_index)
		
		# Удаляем точку из контейнера
		bones_container.remove_child(point)
		
		# Обновляем соединение
		update_connection()
	conn_server_api.update_connection_data()

# Поиск ближайшего сегмента для вставки
func find_closest_segment_index(point_position: Vector2) -> int:
	var points = line.get_points()
	if points.size() < 2:
		return 1
	
	var min_distance = INF
	var insert_index = -1
	
	for i in range(points.size() - 1):
		var segment_start = points[i]
		var segment_end = points[i + 1]
		
		var closest = Geometry2D.get_closest_point_to_segment(point_position, segment_start, segment_end)
		var distance = point_position.distance_to(closest)
		
		if distance < min_distance:
			min_distance = distance
			insert_index = i + 1
	
	return insert_index if insert_index != -1 else line.get_point_count()


# Получаем глобальный прямоугольник для Sprite2D
func get_sprite_global_rect(sprite: Sprite2D) -> Rect2:
	if sprite.texture:
		# Получаем размер текстуры с учетом масштаба
		var size = sprite.texture.get_size() * sprite.scale
		
		# Вычисляем глобальную позицию с учетом центра спрайта
		var pos = sprite.global_position - size / 2
		
		return Rect2(pos, size)
	
	# Если текстуры нет, используем позицию спрайта
	return Rect2(sprite.global_position, Vector2.ZERO)

# Вычисляет точку пересечения линии с прямоугольником
func calculate_boundary_point(from: Vector2, to: Vector2, rect: Rect2) -> Vector2:
	# Если прямоугольник нулевой, возвращаем центр
	if rect.size == Vector2.ZERO:
		return rect.position
	
	# Направление линии
	var direction = (to - from).normalized()
	
	# Рассчитываем параметры t для пересечения с сторонами
	var t_values = []
	
	# Проверяем пересечение с левой/правой сторонами
	if direction.x != 0:
		# Левая сторона (x = rect.position.x)
		var t_left = (rect.position.x - from.x) / direction.x
		var y_left = from.y + t_left * direction.y
		if y_left >= rect.position.y && y_left <= rect.end.y:
			t_values.append(t_left)
		
		# Правая сторона (x = rect.end.x)
		var t_right = (rect.end.x - from.x) / direction.x
		var y_right = from.y + t_right * direction.y
		if y_right >= rect.position.y && y_right <= rect.end.y:
			t_values.append(t_right)
	
	# Проверяем пересечение с верхней/нижней сторонами
	if direction.y != 0:
		# Верхняя сторона (y = rect.position.y)
		var t_top = (rect.position.y - from.y) / direction.y
		var x_top = from.x + t_top * direction.x
		if x_top >= rect.position.x && x_top <= rect.end.x:
			t_values.append(t_top)
		
		# Нижняя сторона (y = rect.end.y)
		var t_bottom = (rect.end.y - from.y) / direction.y
		var x_bottom = from.x + t_bottom * direction.x
		if x_bottom >= rect.position.x && x_bottom <= rect.end.x:
			t_values.append(t_bottom)
	
	# Находим минимальное положительное t (ближайшее пересечение)
	var min_t = INF
	for t in t_values:
		if t > 0 && t < min_t:
			min_t = t
	
	# Если нашли пересечение, возвращаем точку
	if min_t != INF:
		return from + direction * min_t
	
	# Fallback: если не нашли пересечений, возвращаем центр прямоугольника
	return rect.position + rect.size / 2

func is_mouse_over_point():
	for i in range(0, bones_container.get_child_count()):
		var bone = bones_container.get_child(i)
		if bone.is_mouse_over() == true:
			return true
	return false

# Обработчик изменения позиции точки
func _on_point_position_changed_finished():
	conn_server_api.update_connection_data()

func remove_connection():
	conn_server_api.remove_connection_on_server()
	from_achievement.remove_outgoing_connection(self)
	to_achievement.remove_incoming_connection(self)
	queue_free()
