extends Node
class_name HTTPRequestQueue

signal request_completed(request_id, type, body)
signal request_failed(request_id, type, error)

@onready var server_requests: Node = $".."

var _queue = []  # Очередь запросов
var _current_request = null
var _http_request = HTTPRequest.new()
var _next_request_id = 1
var _is_processing = false

const BASE_URL = "http://127.0.0.1:8000"

func _ready():
	add_child(_http_request)
	_http_request.request_completed.connect(_on_HTTPRequest_request_completed)

# Добавление запроса в очередь
func add_request(type: int, method: HTTPClient.Method, url: String, data: Variant = null) -> int:
	var request_id = _next_request_id
	_next_request_id += 1
	var new_url = BASE_URL + url
	var request_data = { #TODO Добавить информацию в лог
		"id": request_id,
		"type": type,
		"method": method,
		"url": new_url,
		"data": data,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	_queue.push_back(request_data)
	
	
	# Если очередь не обрабатывается, запускаем обработку
	if not _is_processing:
		_process_next_request()
	
	return request_id


# Обработка следующего запроса в очереди
func _process_next_request():
	if _queue.size() == 0:
		_is_processing = false
		return
	
	_is_processing = true
	_current_request = _queue.pop_front()
	
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(_current_request.data) if _current_request.data != null else ""
	
	var error = _http_request.request(_current_request.url, headers, _current_request.method, body)
	if error != OK:
		var error_msg = "HTTP request error: " + str(error)
		emit_signal("request_failed", _current_request.id, _current_request.type, error_msg)
		# Продолжаем обработку очереди несмотря на ошибку
		_process_next_request()

# Обработчик завершения запроса
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if _current_request == null:
		return
	
	var request_id = _current_request.id
	var type = _current_request.type
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			emit_signal("request_completed", request_id, type, json.data)
		else:
			emit_signal("request_failed", request_id, type, "Failed to parse JSON response")
	else:
		var error_msg = "Error %d: %s" % [response_code, body.get_string_from_utf8()]
		emit_signal("request_failed", request_id, type, error_msg)
	
	# Обрабатываем следующий запрос
	_current_request = null
	_process_next_request()

# Очистка очереди
func clear_queue():
	_queue.clear()
	_current_request = null
	_is_processing = false

# Получение статуса очереди
func get_queue_status() -> Dictionary:
	return {
		"total": _queue.size(),
		"current": _current_request,
		"processing": _is_processing
	}
