extends SubViewportContainer

@onready var sub_viewport: SubViewport = %SubViewport

func _input(event):
	# Передаем события мыши в SubViewport
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		sub_viewport.push_input(event.duplicate())
