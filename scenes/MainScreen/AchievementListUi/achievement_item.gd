extends PanelContainer

@onready var icon: TextureRect = %Icon
@onready var title_label: Label = %TitleLabel
@onready var status_label: Label = %StatusLabel
@onready var description_label: Label = %DescriptionLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var extra_label: Label = %ExtraLabel
@onready var desc_container: ScrollContainer = %DescContainer

func _ready():
	print("icon node:", get_node_or_null("AchievementItem/TopRow/Icon"))
	print("title node:", get_node_or_null("AchievementItem/TopRow/TitleLabel"))

func set_data(data: Dictionary) -> void:
	if data.has("icon") and data.icon != null:
		icon.texture = load(data.icon)
	title_label.text = data.title
	_set_status_label(data.status)
	
	
	_set_description(data.description)
	
	if data.status == "IN PROGRESS":
		progress_bar.value = data.progress
		extra_label.text = data.progress_text
	elif data.status == "COMPLETED":
		progress_bar.hide()
		extra_label.text = data.date


func _set_status_label(text):
	status_label.text = text
	match text:
		"COMPLETED":
			# зелёный (приятный, мягкий)
			status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		"LOCKED":
			var use_gray := false  # <-- поменяй на false, если хочешь красный вариант
			if use_gray:
				# серый (нейтральный)
				status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			else:
				# красный (акцентный)
				status_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))

func _set_description(description: String):
	description_label.text = description
	
	
