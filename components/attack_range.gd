extends Area2D

var can_see_player : bool = false

func _on_body_entered(_body):
	can_see_player = true

func _on_body_exited(_body):
	can_see_player = false
