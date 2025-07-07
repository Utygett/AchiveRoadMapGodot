# scripts/achievement.gd
extends Area2D

@onready var name_label: Label = %NameLabel

@export var achievement_name = "Новое достижение"
var is_dragging = false
var drag_offset = Vector2.ZERO
var is_selected = false

func _ready():
	update_appearance()

func update_appearance():
	name_label.text = achievement_name
	if is_selected:
		name_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		name_label.add_theme_color_override("font_color", Color.WHITE)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Начали перетаскивание
			is_dragging = true
			drag_offset = position - get_global_mouse_position()
			is_selected = true
			update_appearance()
			# Поднимаем элемент наверх
			get_parent().move_child(self, get_parent().get_child_count())
		else:
			is_dragging = false

func _process(_delta):
	if is_dragging:
		position = get_global_mouse_position() + drag_offset

func _on_mouse_entered():
	name_label.visible = true

func _on_mouse_exited():
	if not is_selected:
		name_label.visible = false
