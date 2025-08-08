extends Node
@onready var server_requests: Node = $".."
@onready var network_manager: Node = %NetworkManager

#Загрузка всей карты
func load_map_data(map_id: int):
	var url = "/maps/%d" % map_id
	network_manager.add_request(server_requests.RequestType.GET_MAP, HTTPClient.METHOD_GET, url)

func on_map_data_loaded(body):
	var map_data = body
	# Обработка данных карты
	print("Loaded map: ", map_data.title)
	# Обработка достижений
	for achievement in map_data.achievements:
		create_achievement_node(
			achievement.id,
			achievement.title,
			Vector2(achievement.x, achievement.y),
			Vector2(achievement.width, achievement.height),
			achievement.icon_url
		)
	
	# Обработка связей
	for connection in map_data.connections:
		var points = connection.points
		if points == null:
			points = Array()
		create_connection_line(
			connection.id,
			connection.from_achievement_id,
			connection.to_achievement_id,
			points
		)

# Пример создания визуальных элементов
func create_achievement_node(id: int, title: String, position: Vector2, _size: Vector2, icon_url: String):
	get_parent().get_parent().add_achievement(id, position, title, icon_url)

func create_connection_line(id: int, from_id: int, to_id: int, points: Array):
	get_parent().get_parent().add_connection(id, from_id, to_id, points)

func create_map(map):
	var title = map.achievement_map_name
	var width = map.tile_width
	var height = map.tile_height 
	var bg_url = map.bg_url
	var uuid = map.client_uid
	var url = "/maps/"
	var body = {
		"client_uid": uuid,
		"title": title,
		"width": width,
		"height": height,
		"background_image_url": bg_url
	}
	network_manager.add_request(server_requests.RequestType.CREATE_MAP, HTTPClient.METHOD_POST, url, body)
