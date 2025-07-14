extends Node

var connection_scene = preload("res://scenes/connection.tscn")
var active_connection: Node2D = null
var connection_from: Node2D = null
var connection_from_anchor: Vector2 = Vector2.ZERO

func start_connection(from: Node2D, from_anchor: Vector2):
	connection_from = from
	connection_from_anchor = from_anchor
	active_connection = connection_scene.instantiate()
	get_tree().current_scene.add_child(active_connection)
	
	# Инициализируем временную связь
	active_connection.setup(from, null, from_anchor, Vector2.ZERO)

func update_connection_to(position: Vector2):
	if active_connection:
		# Обновляем конечную точку
		active_connection.to_anchor = position - active_connection.from_achievement.global_position
		active_connection.update_connection()

func complete_connection(to: Node2D, to_anchor: Vector2):
	if active_connection and connection_from and to:
		# Завершаем связь
		active_connection.setup(connection_from, to, connection_from_anchor, to_anchor)
		
		# Регистрируем связь в достижениях
		connection_from.add_outgoing_connection(active_connection)
		to.add_incoming_connection(active_connection)
		
		# Сбрасываем состояние
		active_connection = null
		connection_from = null
		connection_from_anchor = Vector2.ZERO

func cancel_connection():
	if active_connection:
		active_connection.queue_free()
		active_connection = null
		connection_from = null
		connection_from_anchor = Vector2.ZERO
