extends Node
@onready var network_manager: Node = %NetworkManager
@onready var achievement_api: Node = %AchievementAPI
@onready var connection_api: Node = %ConnectionAPI
@onready var map_api: Node = %MapAPI

# Добавляем перечисление типов запросов
enum RequestType {
	GET_MAP,
	CREATE_MAP,
	UPDATE_MAP,
	DELETE_MAP,
	CREATE_ACHIEVEMENT,
	UPDATE_ACHIEVEMENT,
	DELETE_ACHIEVEMENT,
	CREATE_CONNECTION,
	UPDATE_CONNECTION,
	DELETE_CONNECTION
}

func _ready():
	network_manager.connect("request_completed", _on_request_completed)
	network_manager.connect("request_failed", _on_request_failed)

func _on_request_completed(request_id, type, data):
	print("Request", request_id, "completed. type:", type)
	match type:
		RequestType.GET_MAP:
			map_api.on_map_data_loaded(data)

func _on_request_failed(request_id, type, error):
	print("Request: ", request_id, " Type: ", type, " failed:", error)

func create_achievement(achievement):
	achievement_api.create_achievement(achievement)

func update_achievement(achievement):
	achievement_api.update_achievement_data(achievement)
	
func delete_achievement(achievement):
	achievement_api.delete_achievement(achievement)

func create_connection(connection):
	connection_api.create_connection(connection)

func update_connection(connection):
	connection_api.update_connection_data(connection)

func remove_connection(connection):
	connection_api.delete_connection_from_server(connection)

func load_map_data(id:int):
	map_api.load_map_data(id)
	
