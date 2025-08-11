extends CanvasLayer
@onready var list_v_box: VBoxContainer = %ListVBox

func _ready():
	var items_data = [
		{
			"icon": "res://assets/comprassion.png",
			"title": "Code Master",
			"status": "IN PROGRESS",
			"description": "Complete 5 programming challenges in different languages",
			"progress": 60,
			"progress_text": "3/5 completed"
		},
		{
			"icon": "res://assets/count_to_20.png",
			"title": "Peak Performance",
			"status": "COMPLETED",
			"description": "Reach the top of your local leaderboard",
			"date": "May 15, 2023"
		},
		{
			"icon": "res://assets/Sum_to_10.png",
			"title": "Team Player",
			"status": "IN PROGRESS",
			"description": "Collaborate with 10 different users on projects",
			"progress": 40,
			"progress_text": "4/10 collaborations"
		}
	]
	var item_scene = preload("res://scenes/MainScreen/AchievementListUi/AchievementItem.tscn")
	for data in items_data:
		var item = item_scene.instantiate()
		item.set_data(data)
		list_v_box.add_child(item)
