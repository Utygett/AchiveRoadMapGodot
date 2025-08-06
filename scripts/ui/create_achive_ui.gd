extends CanvasLayer

# Сигналы для передачи данных
signal created(data: Dictionary)
signal canceled()

@onready var le_name: LineEdit = %LEName
@onready var le_image_url: LineEdit = %LEImageUrl
@onready var te_description: TextEdit = %TEDescription
@onready var bt_create: Button = %BTCreate

func _ready() -> void:
	get_tree().paused = true

func _on_bt_cancel_pressed() -> void:
	emit_signal("canceled")
	close_dialog()

func initFromAchive(achive):
	le_name.text = achive.achievement_name
	le_image_url.text = achive.icon.resource_path
	te_description.text = achive.description
	bt_create.text = "Обновить"

func _on_bt_create_pressed() -> void:
	# Передаем данные через сигнал
	var achive_data = {
		"name": le_name.text,
		"image_url": le_image_url.text,
		"description": te_description.text,
		"timestamp": Time.get_unix_time_from_system()
	}
	emit_signal("created", achive_data)
	close_dialog()


func close_dialog() -> void:
	get_tree().paused = false
	queue_free()
