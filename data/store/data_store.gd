extends Node

signal map_loaded(map_id: int)             # когда карта загружена (из кеша/сервера)
signal achievement_upserted(map_id: int, ach: AchievementData)
signal achievement_removed(map_id: int, ach_id: int)
signal connection_upserted(map_id: int, conn: ConnectionData)
signal connection_removed(map_id: int, conn_id: int)

var _maps: Dictionary = {}  # map_id -> MapData

func get_map(map_id: int) -> MapData:
	return _maps.get(map_id)
	
func set_map(map_data: MapData) -> void:
	_maps[map_data.id] = map_data
	save_map_to_cache(map_data.id)
	map_loaded.emit(map_data.id)

func upsert_connection(map_id: int, conn: ConnectionData) -> void:
	var m := get_map(map_id)
	if m == null: return
	var idx = null
	for connection in m.connections:
		if connection.id == conn.id:  # Replace with your condition
			idx = conn.id
			break
	if idx == -1:
		m.connections.append(conn)
	else:
		m.connections[idx] = conn
	save_map_to_cache(map_id)
	connection_upserted.emit(map_id, conn)

func remove_connection(map_id: int, conn_id: int) -> void:
	var m := get_map(map_id)
	if m == null: return
	m.connections = m.connections.filter(func(c): return c.id != conn_id)
	save_map_to_cache(map_id)
	connection_removed.emit(map_id, conn_id)

# ------------ offline cache ------------
func _map_cache_path(map_id: int) -> String:
	return "user://maps/%d.tres" % map_id

func save_map_to_cache(map_id: int) -> void:
	var m := get_map(map_id)
	if m == null: return
	DirAccess.make_dir_recursive_absolute("user://maps")
	ResourceSaver.save(m, _map_cache_path(map_id))
	
func load_map_from_cache(map_id: int) -> MapData:
	var path := _map_cache_path(map_id)
	if not FileAccess.file_exists(path):
		return null
	var res := ResourceLoader.load(path)
	if res is MapData:
		_maps[map_id] = res
		map_loaded.emit(map_id)
		return res
	return null
