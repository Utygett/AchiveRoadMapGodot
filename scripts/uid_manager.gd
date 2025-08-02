extends Node

var _next_temp_id = 0
var _temp_to_real_map = {}  # {temp_id: real_id}

func generate_temp_id() -> int:
	_next_temp_id += 1
	return -_next_temp_id  # Используем отрицательные значения для временных ID

func map_temp_to_real(temp_id: int, real_id: int):
	_temp_to_real_map[temp_id] = real_id

func get_real_id(temp_id: int) -> int:
	return _temp_to_real_map.get(temp_id, temp_id)
