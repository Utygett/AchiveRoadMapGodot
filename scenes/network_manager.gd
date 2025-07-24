# NetworkManager.gd
extends Node

var http_request = HTTPRequest.new()

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func send_request(method: HTTPClient.Method, url: String, data: Variant = null) -> void:
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data) if data else ""
	
	var error = http_request.request(url, headers, method, body)
	if error != OK:
		push_error("HTTP request error: " + str(error))

func _on_request_completed(result, response_code, headers, body):
	print("Request completed. Code: ", response_code)
	
	if response_code == 200:
		var json = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK:
			print("Success:", json.data)
			emit_signal("request_success", json.data)
		else:
			push_error("Failed to parse JSON response")
			emit_signal("request_error", "Invalid JSON")
	else:
		var error_msg = "Error %d: %s" % [response_code, body.get_string_from_utf8()]
		push_error(error_msg)
		emit_signal("request_error", error_msg)
