extends Node
@onready var network_manager: Node = %NetworkManager
@onready var achievement_api: Node = %AchievementAPI
@onready var connection_api: Node = %ConnectionAPI

func _ready():
	network_manager.connect("request_success", _on_network_success)
	network_manager.connect("request_error", _on_network_error)

func _on_network_success(data):
	print("Operation successful:", data)
	
	# Обновляем UI или игровые объекты
	if data.has("id") and data.has("map_id"):
		# Обновление карты
		pass
	elif data.has("id") and data.has("achievement_id"):
		# Обновление соединения
		pass

func _on_network_error(error_msg):
	print("Network error:", error_msg)

func update_achievement(achievement):
	achievement_api.update_achievement_data(achievement)
	
func update_connection(connection):
	achievement_api.update_connection_data(connection)
