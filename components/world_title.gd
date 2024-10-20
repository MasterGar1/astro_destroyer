extends CanvasLayer

@onready var backgorund := $ColorRect
@onready var level := $Label
@onready var level_name := $Label2

func _ready() -> void:
	get_tree().paused = true

func setup(lvl : int, l_name : String) -> void:
	level.text = "Level " + str(lvl)
	level_name.text = l_name

func _on_animation_player_animation_finished(_anim_name : String) -> void:
	get_tree().paused = false
	queue_free()
