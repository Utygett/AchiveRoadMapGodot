extends Node2D

@onready var line: Line2D = %Line
@onready var arrow: Sprite2D = %Arrow
@onready var bones_container: Node2D = %Bones

var from_achievement: Node2D = null
var to_achievement: Node2D = null
var from_anchor: Vector2 = Vector2.ZERO
var to_anchor: Vector2 = Vector2.ZERO

var mouse_over = false
var base_scale = Vector2.ONE  # Сохраняем базовый размер
var base_modulate = Color.WHITE  # Сохраняем базовый цвет


func _ready() -> void:
	z_index = 15

func set_start_achievement(achievement: Node2D):
	from_achievement = achievement

func set_end_achievement(achievement: Node2D):
	to_achievement = achievement
	to_anchor = achievement.global_position

func update_end_point(achievement: Node2D, position: Vector2):
	to_achievement = achievement
	to_anchor = position if !achievement else position - achievement.global_position
	#update_connection()

func update_connection():
	# Сохраняем пользовательские точки (все кроме первой и последней)
	var user_points = []
	if line.get_point_count() > 2:
		for i in range(1, line.get_point_count() - 1):
			user_points.append(line.get_point_position(i))
	
	# Получаем спрайты достижений
	var start_sprite = from_achievement.get_node("Sprite2D")
	var end_sprite = to_achievement.get_node("Sprite2D")
	
	# Получаем глобальные прямоугольники спрайтов
	var start_rect = get_sprite_global_rect(start_sprite)
	var end_rect = get_sprite_global_rect(end_sprite)
	
	# Рассчитываем точки на границах прямоугольников
	var start_point = calculate_boundary_point(
		from_achievement.global_position,
		to_achievement.global_position,
		start_rect
	)
	
	var end_point = calculate_boundary_point(
		to_achievement.global_position,
		from_achievement.global_position,
		end_rect
	)
	
	# Обновляем линию, сохраняя пользовательские точки
	line.clear_points()
	line.add_point(start_point)  # Первая точка - всегда граница начального спрайта
	
	# Добавляем сохраненные пользовательские точки
	for point in user_points:
		line.add_point(point)
	
	# Добавляем опорные точки из контейнера (если они еще не добавлены)
	for bone in bones_container.get_children():
		if not user_points.has(bone.global_position):
			line.add_point(bone.global_position)
	
	line.add_point(end_point)  # Последняя точка - всегда граница конечного спрайта
	
	# Обновляем стрелку
	if line.get_point_count() > 1:
		var last_idx = line.get_point_count() - 1
		var segment_start = line.get_point_position(last_idx - 1)
		var segment_end = line.get_point_position(last_idx)
		arrow.global_position = segment_end
		arrow.rotation = (segment_end - segment_start).angle()
		
	line.generate_collision()

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

# Сохранение данных связи
func save_data() -> Dictionary:
	var data = {
		"from": from_achievement.get_path(),
		"to": to_achievement.get_path(),
		"from_anchor": [from_anchor.x, from_anchor.y],
		"to_anchor": [to_anchor.x, to_anchor.y],
		"bones": []
	}
	
	for bone in bones_container.get_children():
		data["bones"].append({
			"position": [bone.position.x, bone.position.y],
			"global_position": [bone.global_position.x, bone.global_position.y]
		})
	
	return data

# Загрузка данных связи
func load_data(data: Dictionary):
	from_anchor = Vector2(data["from_anchor"][0], data["from_anchor"][1])
	to_anchor = Vector2(data["to_anchor"][0], data["to_anchor"][1])
	
	for bone_data in data["bones"]:
		var bone_position = Vector2(bone_data["position"][0], bone_data["position"][1])
