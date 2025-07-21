extends Node

var http_request = HTTPRequest.new()

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

#Загрузка всей карты
func load_map(map_id: int):
	var url = "http://localhost:8000/maps/%d" % map_id
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
	var node = Sprite2D.new()
	node.name = "Achievement_%d" % id
	node.position = position
	node.scale = size / 64  # Предположим базовый размер текстуры 64x64
	add_child(node)
	
	# Асинхронная загрузка иконки
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(
		func(_result, _code, _headers, data):
			var image = Image.new()
			var error = image.load_png_from_buffer(data)
			if error == OK:
				var texture = ImageTexture.create_from_image(image)
				node.texture = texture
			http.queue_free()
	)
	http.request(icon_url)

func create_connection_line(from_id: int, to_id: int, points: Array):
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = Color.WHITE
	
	# Преобразование точек в Vector2
	for point in points:
		line.add_point(Vector2(point.x, point.y))
	
	add_child(line)
