# uuid_manager.gd
extends Node

func generate_uuid() -> String:
	var uuid = ""
	var chars = "0123456789abcdef"
	
	for i in range(32):
		if i in [8, 12, 16, 20]:
			uuid += "-"
		uuid += chars[randi() % chars.length()]
	
	return uuid

# Пример использования:
func _ready():
	print(generate_uuid())  # Вывод: "a3e4f5g6-h7i8-j9k0-l1m2-n3o4p5q6r7s8"
