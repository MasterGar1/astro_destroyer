extends World

const SPAWN_DISTANCE_MAX : int = 2000
const SPAWN_DISTANCE_MIN : int = 1000
const MAX_SPAWN : int = 6
const ASTEROID_MAX_SPAWN : int = 3

@export var enemy : PackedScene = preload("res://enemy/enemies/drone.tscn")
@export var asteroid : PackedScene= preload("res://asteroid/asteroid.tscn")

func _ready() -> void:
	super()
	for i in range(3):
		spawn()
		
	for i in range(10):
		create_asteroid()

func create_asteroid() -> void:
	var inst : Asteroid = asteroid.instantiate()
	inst.position = pick_pos(float(SPAWN_DISTANCE_MIN) / 2)
	add_child(inst)

func spawn() -> void:
	if Global.spawing_enabled:
		var inst : Enemy = get_enemy().instantiate()
		inst.position = pick_pos()
		add_child(inst)
	
func pick_pos(min_dist : float = SPAWN_DISTANCE_MIN, max_dist : float = SPAWN_DISTANCE_MAX) -> Vector2:
	if Global.is_player_dead:
		return Vector2.ZERO
	var angle : float = randf() * PI * 2
	var radius : float = randf_range(min_dist, max_dist)
	return Vector2.from_angle(angle) * radius + get_tree().get_nodes_in_group("player")[0].position
	
func get_enemy() -> PackedScene:
	return enemy

func _spawn_periodic() -> void:
	var spawn_amount : int = randi_range(1, MAX_SPAWN)
	for i in range(spawn_amount):
		spawn()
	
func _asteroid_create_periodic() -> void:
	var asteroid_amount : int = randi_range(1, ASTEROID_MAX_SPAWN)
	for i in range(asteroid_amount):
		create_asteroid()
