extends Node2D
class_name World

@export var level : int = 0
@export var level_name : String = ""
var world_title : CanvasLayer
var pause_screen : CanvasLayer

func _ready() -> void:
	Global.score = 0
	Global.is_player_dead = false
	pause_screen = preload("res://components/pause_screen.tscn").instantiate()
	pause_screen.hide()
	add_child(pause_screen)
	
	if not Global.DEBUG:
		world_title = preload("res://components/world_title.tscn").instantiate()
		Global.current_level = level
		add_child(world_title)
		world_title.setup(level, level_name)
	else:
		print("Level: ", level)
		print(level_name)
