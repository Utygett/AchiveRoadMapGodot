extends VBoxContainer

func set_data(data: Dictionary) -> void:
	if data.has("icon") and data.icon != null:
		$TopRow/Icon.texture = load(data.icon)
	$TopRow/TitleLabel.text = data.title
	$TopRow/StatusLabel.text = data.status
	$DescriptionLabel.text = data.description
	
	if data.status == "IN PROGRESS":
		$BottomRow/ProgressBar.value = data.progress
		$BottomRow/ExtraLabel.text = data.progress_text
	elif data.status == "COMPLETED":
		$BottomRow/ProgressBar.hide()
		$BottomRow/ExtraLabel.text = data.date
