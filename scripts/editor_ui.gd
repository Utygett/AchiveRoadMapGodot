# scripts/ui_controller.gd
extends CanvasLayer

# Связываем элементы с переменными

@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
@onready var zoom_slider: HSlider = %ZoomSlider
@onready var width_spin: SpinBox = %WidthSpin
@onready var height_spin: SpinBox = %HeightSpin
@onready var create_achive: Button = %CreateAchive

func _ready():
	# Начальные значения
	width_spin.value = 2000
	height_spin.value = 2000
	zoom_slider.value = 1.0









# Сигналы для кнопок (подключаем в редакторе!)
func _on_add_image_button_pressed():
	print("Добавить изображение")
	# Здесь будет вызов функции добавления

func _on_color_picker_button_color_changed(color: Color) -> void:
	print("Новый цвет фона:", color)
	# Здесь будет изменение фона

func _on_width_spin_value_changed(value):
	#print("Ширина:", value)
	pass

func _on_height_spin_value_changed(value):
	#print("Высота:", value)
	pass

func _on_zoom_slider_value_changed(value):
	print("Масштаб:", value)

func update_zoom_slider(value):
	zoom_slider.value = value

func _on_create_achive_pressed() -> void:
	emit_signal("create_achievement_requested")

# Добавьте эту функцию для отображения свойств
func show_properties_for(achievement):
	# Сначала скроем все свойства
	$PropertyPanel.hide()
	
	if achievement:
		# Настройка панели свойств
		$PropertyPanel/AchievementName.text = achievement.achievement_name
		$PropertyPanel/ScaleSlider.value = achievement.scale.x
		$PropertyPanel.show()
