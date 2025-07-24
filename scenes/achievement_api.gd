extends Node

const BASE_URL = "http://127.0.0.1:8000"
@onready var network_manager: Node = %NetworkManager

func update_achievement(achievement_id: int, data: Dictionary):
	var url = BASE_URL + "/achievements/%d" % achievement_id
	network_manager.send_request(HTTPClient.METHOD_PUT, url, data)

func delete_achievement(achievement_id: int):
	var url = BASE_URL + "/achievements/%d" % achievement_id
	network_manager.send_request(HTTPClient.METHOD_DELETE, url)

# Пример использования:
func update_achievement_data(achievement):
	var data = {
		"x": int(achievement.global_position.x),
		"y": int(achievement.global_position.y)
	}
	update_achievement(achievement.achieve_id, data)

func _delete_achievement_from_server(achievement_id: int):
	delete_achievement(achievement_id)
