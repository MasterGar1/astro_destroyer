extends Camera2D

@export var random_strength : float = 30.0
@export var shake_fade : float = 5.0
var shake_strength : float = 0.0

var rng := RandomNumberGenerator.new()

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		offset = random_offset()

func apply_shake(multiplier : float = 1.0) -> void:
	if Global.current_level >= 3:
		shake_strength = random_strength * multiplier
	
func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
