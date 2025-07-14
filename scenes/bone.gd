extends Node2D

@onready var sprite: Sprite2D = $Sprite
@onready var area: Area2D = $Area

var connection_ref: WeakRef = null
var is_dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	# Настройка внешнего вида
	#sprite.texture = preload("res://bone_icon.png")
	sprite.scale = Vector2(0.2, 0.2)
	
	# Подключение сигналов
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()
			# Поднимаем на верхний слой
			z_index = 100
			# Помечаем событие как обработанное
			get_viewport().set_input_as_handled()
		else:
			is_dragging = false
			# Возвращаем на обычный слой
			z_index = 0

func _on_mouse_entered():
	scale = Vector2(0.3, 0.3)

func _on_mouse_exited():
	scale = Vector2(0.2, 0.2)

func _physics_process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		# Обновляем родительскую связь
		if connection_ref and connection_ref.get_ref():
			connection_ref.get_ref().update_connection()
