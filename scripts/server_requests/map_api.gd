extends Node
@onready var server_requests: Node = $".."
@onready var network_manager: Node = %NetworkManager

#Загрузка всей карты
func load_map_data(map_id: int):
	var url = "/maps/%d" % map_id
	network_manager.add_request(server_requests.RequestType.GET_MAP, HTTPClient.METHOD_GET, url)

func on_map_data_loaded(body):
	var map_res := MapData.new()
	map_res.id = body.id
	map_res.title = body.title
	map_res.width = body.width
	map_res.height = body.height
	map_res.background_image_url = body.background_image_url
	# achievements
	for a in body.achievements:
		var ach := AchievementData.new()
		ach.id = a.id
		ach.map_id = body.id
		ach.title = a.title
		ach.description = a.description
		ach.icon_url = a.icon_url
		ach.position = Vector2(a.x, a.y)
		map_res.achievements.append(ach)
	# connections
	for c in body.connections:
		var conn := ConnectionData.new()
		conn.id = c.id
		conn.map_id = body.id
		conn.from_achievement_id = c.from_achievement_id
		conn.to_achievement_id = c.to_achievement_id
		var pts: Array[Vector2] = []
		if c.points != null:
			for p in c.points:
				pts.append(Vector2(p.x, p.y))
		conn.points = pts
		map_res.connections.append(conn)
	DataStore.set_map(map_res) # сохранит в кеш и дернёт сигнал map_loaded

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
