extends Camera2D

var drag_sensitivity = 1
var is_dragging = false
var last_mouse_position = Vector2.ZERO
var current_drag_offset = Vector2.ZERO
var can_drag_camera = true  # Флаг, разрешающий перемещение камеры

func _ready():
	# 1. Делаем камеру текущей
	make_current()
	# 2. Включаем обработку процесса
	set_process(true)
	var viewport_size = get_viewport_rect().size

func _input(event):
	# Пропускаем обработку, если перетаскивание камеры запрещено
	if !can_drag_camera:
		return
	if event is InputEventMouseButton:
		# Перетаскивание ЛКМ
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if is_dragging:
				last_mouse_position = get_viewport().get_mouse_position()
		
		# Зум колесиком
		if event.pressed:
			var prev_zoom = zoom
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom *= 0.9
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom *= 1.1
			
			# Ограничение зума
			zoom = zoom.clamp(Vector2(0.5, 0.5), Vector2(2.0, 2.0))
			
			# Корректируем позицию после зума
			if prev_zoom != zoom:
				enforce_camera_limits()

func _process(delta):
	if is_dragging && can_drag_camera:
		var current_mouse_position = get_viewport().get_mouse_position()
		
		# Рассчитываем смещение
		current_drag_offset = (last_mouse_position - current_mouse_position) * drag_sensitivity / zoom
		
		# Применяем смещение БЕЗ ОГРАНИЧЕНИЙ
		position += current_drag_offset
		
		# Обновляем позицию мыши
		last_mouse_position = current_mouse_position

# Добавляем методы для управления доступностью перетаскивания
func disable_camera_drag():
	can_drag_camera = false
	is_dragging = false  # Сбрасываем текущее перетаскивание

func enable_camera_drag():
	can_drag_camera = true

func enforce_camera_limits():
	# Важно: получаем актуальный размер вьюпорта
	var viewport = get_viewport()
	if not viewport:
		return
		
	var viewport_size = viewport.get_visible_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
		
	# Рассчитываем видимую область с учетом зума
	var visible_half = viewport_size * zoom / 2
	
	# Вычисляем допустимые границы
	var effective_left = limit_left + visible_half.x
	var effective_right = max(effective_left, limit_right - visible_half.x)
	var effective_top = limit_top + visible_half.y
	var effective_bottom = max(effective_top, limit_bottom - visible_half.y)
	
	# Применяем ограничения
	position.x = clamp(position.x, effective_left, effective_right)
	position.y = clamp(position.y, effective_top, effective_bottom)
	
	# Для отладки
	print("Limited position: ", position, " | Limits: ", 
		  Vector2(effective_left, effective_top), " - ", 
		  Vector2(effective_right, effective_bottom))
