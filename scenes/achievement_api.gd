extends Node

const BASE_URL = "http://127.0.0.1:8000"
@onready var network_manager: Node = %NetworkManager
@onready var server_requests: Node = $".."

func update_achievement(achievement_id: int, data: Dictionary):
	var url = "/achievements/%d" % achievement_id
	network_manager.add_request(server_requests.RequestType.UPDATE_ACHIEVEMENT, HTTPClient.METHOD_PUT, url, data)

func delete_achievement(achievement_id: int):
	var url = "/achievements/%d" % achievement_id
	network_manager.add_request(server_requests.RequestType.DELETE_ACHIEVEMENT, HTTPClient.METHOD_DELETE, url)

# Пример использования:
func update_achievement_data(achievement):
	var data = {
		"x": int(achievement.global_position.x),
		"y": int(achievement.global_position.y)
	}
	update_achievement(achievement.achieve_id, data)

func _delete_achievement_from_server(achievement_id: int):
	delete_achievement(achievement_id)

#Добавление достижения на карту
func create_achievement(map_id: int, title: String, position: Vector2, rect: Rect2, icon_url: String):
	var x = position.x
	var y = position.y
	var width = rect.size.x
	var height = rect.size.y
	var url = "/maps/%d/achievements/" % map_id
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"title": title,
		"x": x,
		"y": y,
		"width": width,
		"height": height,
		"icon_url": icon_url
	})
	
	network_manager.add_request(server_requests.RequestType.CREATE_ACHIEVEMENT, HTTPClient.METHOD_POST, url, body)
