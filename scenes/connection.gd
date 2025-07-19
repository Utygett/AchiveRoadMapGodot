extends Node2D

@onready var line: Line2D = %Line
@onready var arrow: Sprite2D = %Arrow
@onready var bones_container: Node2D = %Bones

var from_achievement: Node2D = null
var to_achievement: Node2D = null
var from_anchor: Vector2 = Vector2.ZERO
var to_anchor: Vector2 = Vector2.ZERO
var bone_scene = preload("res://scenes/bone.tscn")

func set_start_achievement(achievement: Node2D):
	from_achievement = achievement
	from_anchor = achievement.global_position

func set_end_achievement(achievement: Node2D):
	to_achievement = achievement
	to_anchor = achievement.global_position

func update_end_point(achievement: Node2D, position: Vector2):
	to_achievement = achievement
	to_anchor = position if !achievement else position - achievement.global_position
	#update_connection()

# Добавление опорной точки
func add_bone(position: Vector2):
	var bone = bone_scene.instantiate()
	bone.position = position
	bone.connection = weakref(self)
	bones_container.add_child(bone)
	update_connection()

# Обновление точек линии
func update_connection():
	line.clear_points()
	
	# Добавляем начальную точку
	var start_point = from_achievement.global_position
	line.add_point(start_point)
	
	# Добавляем все опорные точки
	for bone in bones_container.get_children():
		line.add_point(bone.global_position)
	
	# Добавляем конечную точку
	var end_point = to_achievement.global_position
	line.add_point(end_point)
	
	## Обновляем позицию и поворот стрелки
	if line.get_point_count() > 1:
		var last_segment_start = line.get_point_position(line.get_point_count()-2)
		var last_segment_end = line.get_point_position(line.get_point_count()-1)
		arrow.global_position = last_segment_end
		arrow.rotation = (last_segment_end - last_segment_start).angle()

# Сохранение данных связи
func save_data() -> Dictionary:
	var data = {
		"from": from_achievement.get_path(),
		"to": to_achievement.get_path(),
		"from_anchor": [from_anchor.x, from_anchor.y],
		"to_anchor": [to_anchor.x, to_anchor.y],
		"bones": []
	}
	
	for bone in bones_container.get_children():
		data["bones"].append({
			"position": [bone.position.x, bone.position.y],
			"global_position": [bone.global_position.x, bone.global_position.y]
		})
	
	return data

# Загрузка данных связи
func load_data(data: Dictionary):
	from_anchor = Vector2(data["from_anchor"][0], data["from_anchor"][1])
	to_anchor = Vector2(data["to_anchor"][0], data["to_anchor"][1])
	
	for bone_data in data["bones"]:
		var bone_position = Vector2(bone_data["position"][0], bone_data["position"][1])
		add_bone(bone_position)
