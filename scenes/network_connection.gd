extends Node

var http_request = HTTPRequest.new()

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

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		print("Map created! ID: ", response.id)
	else:
		print("Error: ", response_code, " ", body.get_string_from_utf8())

#Добавление достижения на карту
func add_achievement(map_id: int, title: String, x: int, y: int, width: int, height: int, icon_url: String):
	var url = "http://localhost:8000/maps/%d/achievements/" % map_id
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
	var url = "http://localhost:8000/maps/%d/connections/" % map_id
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
