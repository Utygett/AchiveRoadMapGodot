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
	server.remove_connection(connection)
