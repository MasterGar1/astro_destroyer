extends Node2D
class_name Powerup

@onready var sprite := $Sprite2D

@export var powerup_id : int

func _ready() -> void:
	powerup_id = randi_range(0, 4)
	rotation = 2 * PI * randf()
	sprite.modulate = Global.powerup_colors[powerup_id]

func _on_area_2d_body_entered(body : Player) -> void:
	body.gain_powerup(powerup_id)
	queue_free()
