extends Node

@onready var connection: Node2D = $".."

func create_connection_on_server():
	var server = get_tree().get_first_node_in_group("server_request")
	server.create_connection(connection)
	
func update_connection_data():
	var server = get_tree().get_first_node_in_group("server_request")
	server.update_connection(connection)

func remove_connection_on_server():
	var server = get_tree().get_first_node_in_group("server_request")
	server.delete_connection(self)
	# и параллельно обновим локально
	if connection != null:
		DataStore.remove_connection(connection.map_id, connection.id)
