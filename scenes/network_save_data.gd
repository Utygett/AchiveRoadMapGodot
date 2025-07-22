extends Node

var http_request = HTTPRequest.new()

var scene_to_load

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

#Загрузка всей карты
func load_map(map_id: int):
	var url = "http://127.0.0.1:8000/maps/%d" % map_id
	http_request.request(url, [], HTTPClient.METHOD_GET)

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Error loading map: ", response_code)
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var map_data = json.get_data()
	
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
		create_connection_line(
			connection.from_achievement_id,
			connection.to_achievement_id,
			connection.points
		)

# Пример создания визуальных элементов
func create_achievement_node(id: int, title: String, position: Vector2, size: Vector2, icon_url: String):
	get_parent().add_achievement(id, position, title, icon_url)

func create_connection_line(from_id: int, to_id: int, points: Array):
	get_parent().add_connection(from_id, to_id, points)
