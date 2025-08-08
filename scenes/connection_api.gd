# ConnectionAPI.gd
extends Node
@onready var server_requests: Node = $".."
@onready var network_manager: Node = %NetworkManager

func update_connection(connection_id: int, data: Dictionary):
	var url = "/connections/%d" % connection_id
	network_manager.add_request(server_requests.RequestType.UPDATE_CONNECTION, HTTPClient.METHOD_PUT, url, data)

func delete_connection(connection_id: int):
	var url = "/connections/%d" % connection_id
	network_manager.add_request(server_requests.RequestType.DELETE_CONNECTION, HTTPClient.METHOD_DELETE, url)

# Пример использования:
func update_connection_data(connection):
	var points_data = []
	for i in range(1, connection.line.get_point_count() - 1): #TODO Заменить на вызов функции у connection
		var point = connection.bones_container.get_child(i - 1)
		points_data.append({"x": int(point.global_position.x), "y": int(point.global_position.y)})
	
	update_connection(connection.connection_id, {"points": points_data})

func delete_connection_from_server(connection):
	delete_connection(connection.connection_id)

# Добавление связи между достижениями
func create_connection(connection):
	var map_id = connection.map_id
	var from_id = connection.from_achievement.achieve_id
	var to_id = connection.to_achievement.achieve_id
	var uuid = connection.client_uuid
	var url = "/maps/%d/connections" % map_id
	
	var body = {
		"client_uid": uuid,
		"from_achievement_id": from_id,
		"to_achievement_id": to_id,
	}
	
	network_manager.add_request(server_requests.RequestType.CREATE_CONNECTION, HTTPClient.METHOD_POST, url, body)
