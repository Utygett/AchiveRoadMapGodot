extends HBoxContainer

# Сигнал для отправки текста активной кнопки
signal filter_changed(active_filter)

# Текущая активная кнопка
var active_button: Button = null



func _ready():
	# Находим все кнопки в контейнере
	for child in get_children():
		if child is Button:
			# Настраиваем кнопку
			child.custom_minimum_size = child.size
			child.focus_mode = Control.FOCUS_NONE
			child.pressed.connect(_on_button_pressed.bind(child))
			# Инициализируем стиль
			#_update_button_style(child, child == active_button)
	init_current_buuton("All")

func init_current_buuton(button_type:String):
	# Находим все кнопки в контейнере
	for child in get_children():
		if child is Button:
			if button_type == child.text:
				_on_button_pressed(child)

# Обработчик нажатия кнопки
func _on_button_pressed(button: Button):
	# Если нажата уже активная кнопка - ничего не делаем
	if button == active_button:
		return
	
	# Снимаем выделение с предыдущей активной кнопки
	#if active_button:
		#_update_button_style(active_button, false)
	# Устанавливаем новую активную кнопку
	active_button = button
	#_update_button_style(active_button, true)
	# Отправляем сигнал с текстом кнопки
	emit_signal("filter_changed", button.text)

# Обновляем стиль кнопки
#func _update_button_style(button: Button, is_active: bool):
	#if is_active:
		# Создаем стиль для активной кнопки
		#var active_style = StyleBoxFlat.new()
		#active_style.bg_color = Color.from_rgba8(112 , 111 , 211)  # Синий фон
		#active_style.border_width_bottom = 1
		#active_style.border_color = Color(0.1, 0.3, 0.6)
		#active_style.corner_radius_top_left = 8
		#active_style.corner_radius_top_right = 8
		#active_style.corner_radius_bottom_right = 8
		#active_style.corner_radius_bottom_left = 8
		
		#button.add_theme_stylebox_override("normal", active_style)
		#button.add_theme_stylebox_override("hover", active_style)
	#else:
		# Возвращаем стандартный стиль
		#button.remove_theme_stylebox_override("normal")
		#button.remove_theme_stylebox_override("hover")
