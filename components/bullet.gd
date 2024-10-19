extends Area2D
class_name Bullet

@onready var sprite = $Sprite2D
@onready var particles = $CPUParticles2D
@export var speed : int = 500
@export var lifespan : int = 700
@export var is_player_bullet : bool = true
@export var damage : int = 0
var direction : Vector2 =  Vector2.ZERO
var start_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	direction = Vector2(cos(rotation), sin(rotation)).rotated(-PI/2)
	start_pos = global_position
	if not is_player_bullet:
		modulate = Color(1, 0.36, 0.36)
	setup_world()
	
func create(pos : Vector2, rot : float, dmg : int, spd : int = 500, span : int = 700, is_player : bool = true) -> void:
	position = pos
	rotation = rot
	damage = dmg
	speed = spd
	lifespan = span
	is_player_bullet = is_player
	
func setup_world() -> void:
	match Global.current_level:
		0:
			sprite.texture = load("res://textures/placeholder.png")
		1, 2:
			sprite.texture = load("res://textures/bullet.png")
			sprite.scale = Vector2(0.7, 1) * 0.1
		3, 4:
			sprite.texture = load("res://textures/bullet.png")
			sprite.scale = Vector2(0.7, 1) * 0.1
			particles.emitting = true

func _process(delta : float) -> void:
	position += direction * speed * delta
	
	if position.distance_squared_to(start_pos) > lifespan ** 2:
		queue_free()
