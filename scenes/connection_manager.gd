extends Node

var connection_scene = preload("res://scenes/connection.tscn")
var connection_from: Node2D = null
var connection_from_anchor: Vector2 = Vector2.ZERO

func start_connection(from: Node2D):
	connection_from = from

func end_connection(to: Node2D, from_data:bool = false):
	if connection_from and to:
		#Создаем связь 
		var active_connection = connection_scene.instantiate()
		active_connection.map_id = connection_from.map_id
		get_tree().current_scene.add_child(active_connection)
		
		# Регистрируем достижения в связи 
		if from_data:
			active_connection.initialize_from_data(connection_from, to)
		else :
			active_connection.initialize(connection_from, to)
		# Регистрируем связь в достижениях
		connection_from.add_outgoing_connection(active_connection)
		to.add_incoming_connection(active_connection)
		# Сбрасываем состояние
		cancel_connection()
		return active_connection
		
# Сбрасываем состояние
func cancel_connection():
		connection_from = null
		connection_from_anchor = Vector2.ZERO

func is_connection_start():
	if connection_from:
		return true
	return false
