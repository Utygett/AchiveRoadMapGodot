# ConnectionAPI.gd
extends Node

const BASE_URL = "http://localhost:8000"
@onready var network_manager: Node = %NetworkManager

func update_connection(connection_id: int, data: Dictionary):
	var url = BASE_URL + "/connections/%d" % connection_id
	network_manager.send_request(HTTPClient.METHOD_PUT, url, data)

func delete_connection(connection_id: int):
	var url = BASE_URL + "/connections/%d" % connection_id
	network_manager.send_request(HTTPClient.METHOD_DELETE, url)

# Пример использования:
func update_connection_data(connection):
	var points_data = []
	for i in range(1, connection.line.get_point_count() - 1): #TODO Заменить на вызов функции у connection
		var point = connection.bones_container.get_child(i - 1)
		points_data.append({"x": int(point.x), "y": int(point.y)})
	
	update_connection(connection.connection_id, {"points": points_data})

func _delete_connection_from_server(connection_id: int):
	delete_connection(connection_id)
