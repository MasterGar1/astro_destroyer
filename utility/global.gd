extends Node

var scenes : Array[PackedScene] = [
	preload("res://levels/level0prototype.tscn"),
	preload("res://levels/level1environment.tscn"),
	preload("res://levels/level2ai.tscn"),
	preload("res://levels/level3graphics.tscn"),
	preload("res://levels/level4updates.tscn")
]

const DEBUG : bool = false
const WINNING_SCORE : int = 1000
const spawing_enabled : bool = true

var current_level : int = -1
var is_player_dead : bool = false
var score : int = 0

var powerup_colors : Array[Color] = [
	Color(0.172, 1, 0), Color(1, 0.289, 0.289), Color(0.148, 0.661, 1), Color(1, 0.907, 0.152), Color(0.611, 0.184, 1)
]

signal score_update()

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("next_level"):
		advance_level()
	elif event.is_action_pressed("refresh"):
		refresh_level()

func advance_level() -> void:
	if scenes.size() > current_level + 1:
		current_level += 1
		get_tree().change_scene_to_packed(scenes[current_level])
		
func refresh_level() -> void:
	get_tree().reload_current_scene()
		
func enemy_death() -> void:
	score += 150
	score_update.emit()
	
func boss_death() -> void:
	score += 1000
	score_update.emit()
	
func asteroid_destroy(size : float) -> void:
	score += floor(20 * size)
	score_update.emit()
