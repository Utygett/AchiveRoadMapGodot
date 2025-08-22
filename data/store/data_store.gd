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

func upsert_achievement(map_id: int, ach: AchievementData) -> void:
	if _maps.has(map_id):
		var m: MapData = _maps[map_id]
		var found := false
		for i in range(m.achievements.size()):
			if m.achievements[i].id == ach.id:
				# безопасный способ заменить
				m.achievements.remove_at(i)
				m.achievements.insert(i, ach)
				found = true
				break
		if not found:
			m.achievements.append(ach)
	save_map_to_cache(map_id)
	achievement_upserted.emit(map_id, ach)

func remove_achievement(map_id: int, ach_id: int) -> void:
	var m := get_map(map_id)
	if m == null: return
	m.achievements = m.achievements.filter(func(a): return a.id != ach_id)
	# грохнем связи, которые ссылались на удалённое достижение
	m.connections = m.connections.filter(func(c):
		return c.from_achievement_id != ach_id and c.to_achievement_id != ach_id)
	save_map_to_cache(map_id)
	achievement_removed.emit(map_id, ach_id)

func upsert_connection(map_id: int, conn: ConnectionData) -> void:
	if _maps.has(map_id):
		var m: MapData = _maps[map_id]
		var found := false
		for i in range(m.connections.size()):
			if m.connections[i].id == conn.id:
				m.connections.remove_at(i)
				m.connections.insert(i, conn)
				found = true
				break
		if not found:
			m.connections.append(conn)
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
