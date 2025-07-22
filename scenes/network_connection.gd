extends Node

var http_request = HTTPRequest.new()
signal request_finished(result:bool)
var achievement_queue = []  # Очередь достижений для сохранения

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Пример вызова
	#save_map("Game Progress", 1920, 1080, "https://example.com/bg.jpg")

func save_map(title: String, width: int, height: int, bg_url: String):
	var url = "http://127.0.0.1:8000/maps/"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"title": title,
		"width": width,
		"height": height,
		"background_image_url": bg_url
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		print("Map created! ID: ", response.id)
		request_finished.emit(true)
	else:
		request_finished.emit(false)
		print("Error: ", response_code, " ", body.get_string_from_utf8())

#Добавление достижения на карту
func add_achievement(map_id: int, title: String, position: Vector2, rect: Rect2, icon_url: String):
	var x = position.x
	var y = position.y
	var width = rect.size.x
	var height = rect.size.y
	var url = "http://127.0.0.1:8000/maps/%d/achievements/" % map_id
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"title": title,
		"x": x,
		"y": y,
		"width": width,
		"height": height,
		"icon_url": icon_url
	})
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

# Добавление связи между достижениями
func add_connection(map_id: int, from_id: int, to_id: int, points: Array):
	var url = "http://127.0.0.1:8000/maps/%d/connections/" % map_id
	var headers = ["Content-Type: application/json"]
	
	# Преобразование точек в нужный формат
	var points_data = []
	for point in points:
		points_data.append({"x": point.x, "y": point.y})
	
	var body = JSON.stringify({
		"from_achievement_id": from_id,
		"to_achievement_id": to_id,
		"points": points_data
	})
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func release_achive_queue():
	if achievement_queue.size() == 0:
		print("Все достижения сохранены!")
		queue_free()  # Удаляем подключение
		return
	
	# Берем первое достижение из очереди
	var current_achievement = achievement_queue.pop_front()
	
	# Отправляем запрос
	add_achievement(
		current_achievement.player_id,
		current_achievement.name,
		current_achievement.position,
		current_achievement.rect,
		current_achievement.icon_path
	)
	
	# Ждем завершения запроса
	await(request_finished)  # Должен быть сигнал в connection
	
	# Сохраняем следующее достижение
	release_achive_queue()
		#var conn_instance = connection.instantiate()
	#add_child(conn_instance) 
	#for i in range(achievement_container.get_child_count()):
		#var achive = achievement_container.get_child(i) as Achievment
		#conn_instance.achievement_queue.push_back({
			#"player_id": 1,
			#"name": achive.achievement_name,
			#"position": achive.global_position,
			#"rect": achive.sprite_2d.get_rect(),
			#"icon_path": achive.icon.resource_path
		#})
	#conn_instance.release_achive_queue()
		##conn_instance.add_achievement(1, achive.achievement_name, achive.global_position, achive.sprite_2d.get_rect(), achive.icon.resource_path)
	
	
