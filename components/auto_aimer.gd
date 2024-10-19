extends Area2D

var entities_within : Array[Node2D]

func get_closest_pos() -> Vector2:
	var pos : Vector2 = get_parent().position
	if not entities_within.is_empty():
		var lowest_entity : Node2D = entities_within[0]
		for enemy in entities_within:
			if enemy.position.distance_squared_to(pos) <= lowest_entity.position.distance_squared_to(pos):
				lowest_entity = enemy
		return lowest_entity.position
	
	return Vector2.ZERO

func _on_body_entered(body : Node2D) -> void:
	entities_within.append(body)

func _on_body_exited(body : Node2D) -> void:
	entities_within.erase(body)
