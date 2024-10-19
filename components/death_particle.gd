extends CPUParticles2D

func _on_finished() -> void:
	queue_free()
	
func resize(size : float) -> void:
	emission_sphere_radius = 128 * size
	scale_amount_min = 10 * size
	scale_amount_max = 20 * size
