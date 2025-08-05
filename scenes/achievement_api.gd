extends Node

const BASE_URL = "http://127.0.0.1:8000"
@onready var network_manager: Node = %NetworkManager
@onready var server_requests: Node = $".."

func update_achievement(achievement_id: int, achievement_uid: String,data: Dictionary):
	var url = ""
	if achievement_id == 0:
		url = "/achievements/by-uuid/%s" % achievement_uid
	else:
		url = "/achievements/%d" % achievement_id
	network_manager.add_request(server_requests.RequestType.UPDATE_ACHIEVEMENT, HTTPClient.METHOD_PUT, url, data)

func delete_achievement_request(achievement_id: int, achievement_uid: String):
	var url = ""
	if achievement_id == 0:
		url = "/achievements/by-uuid/%s" % achievement_uid
	else:
		url = "/achievements/%d" % achievement_id
	network_manager.add_request(server_requests.RequestType.DELETE_ACHIEVEMENT, HTTPClient.METHOD_DELETE, url)


func delete_achievement(achievement):
	delete_achievement_request(achievement.achieve_id, achievement.client_uid)

func update_achievement_data(achievement):
	var data = {
		"x": int(achievement.global_position.x),
		"y": int(achievement.global_position.y),
		"description": achievement.description
	}
	update_achievement(achievement.achieve_id, achievement.client_uid, data)

#Добавление достижения на сервер
func create_achievement(achievement):
	#func create_achievement(map_id: int, title: String, position: Vector2, rect: Rect2, icon_url: String):
	var x = achievement.global_position.x
	var y = achievement.global_position.y
	var width = achievement.sprite_2d.texture.get_width()
	var height = achievement.sprite_2d.texture.get_height()
	var client_uid = achievement.client_uid
	var url = "/maps/%d/achievements/" % achievement.map_id
	var headers = ["Content-Type: application/json"]
	var body = {
		"title": achievement.achievement_name,
		"client_uid": client_uid,
		"x": x,
		"y": y,
		"width": width,
		"height": height,
		"description": achievement.description,
		"icon_url": achievement.icon.resource_path
	}
	
	network_manager.add_request(server_requests.RequestType.CREATE_ACHIEVEMENT, HTTPClient.METHOD_POST, url, body)
