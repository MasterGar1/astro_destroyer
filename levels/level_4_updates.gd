extends "res://levels/level_3_graphics.gd"

@export var powerup := preload("res://player/powerups/power_up.tscn")
@export var enemies : Array[PackedScene] = [
	preload("res://enemy/enemies/drone.tscn"),
	preload("res://enemy/enemies/railgun.tscn"),
	preload("res://enemy/enemies/destroyer.tscn"),
	preload("res://enemy/enemies/crusher.tscn")
] 

@onready var explode_asteroid := $ExplodeAsteroid
@onready var explode_ship := $ExplodeShip

func _ready() -> void:
	super()
	spawn_powerup()
	
func spawn_powerup() -> void:
	var inst : Powerup = powerup.instantiate()
	inst.position = pick_pos(float(SPAWN_DISTANCE_MIN) / 5, float(SPAWN_DISTANCE_MAX) / 3)
	add_child(inst)

func _on_powerup_spawn_timeout() -> void:
	spawn_powerup()

func get_enemy() -> PackedScene:
	return enemies.pick_random()
