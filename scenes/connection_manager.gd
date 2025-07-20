extends Node

var connection_scene = preload("res://scenes/connection.tscn")
var connection_from: Node2D = null
var connection_from_anchor: Vector2 = Vector2.ZERO

func start_connection(from: Node2D):
	connection_from = from

func end_connection(to: Node2D):
	if connection_from and to:
		#Создаем связь 
		var active_connection = connection_scene.instantiate()
		get_tree().current_scene.add_child(active_connection)
		
		# Регистрируем достижения в связи 
		active_connection.initialize(connection_from, to)
		# Регистрируем связь в достижениях
		connection_from.add_outgoing_connection(active_connection)
		to.add_incoming_connection(active_connection)
		# Сбрасываем состояние
		cancel_connection()
		
# Сбрасываем состояние
func cancel_connection():
		connection_from = null
		connection_from_anchor = Vector2.ZERO

func is_connection_start():
	if connection_from:
		return true
	return false
