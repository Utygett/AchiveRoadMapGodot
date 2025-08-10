extends Node

func _init():
	# Устанавливаем логическое разрешение
	ProjectSettings.set_setting("display/window/size/viewport_width", 540)
	ProjectSettings.set_setting("display/window/size/viewport_height", 1200)

	# Растягивание без полос
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "ignore")
