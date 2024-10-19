extends CanvasLayer

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = not visible
		get_tree().paused = not get_tree().paused
