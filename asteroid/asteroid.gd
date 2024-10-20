extends RigidBody2D
class_name Asteroid

@export var size : float = 1
@export var vertex : int = 4
@export var health : int = 0
@export var min_speed : int = 10
@export var max_speed : int = 40
var speed : int = 0

@onready var hurtbox := $Hurtbox
@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D
@onready var poly := $Polygon2D
@export var death_explode : PackedScene = preload("res://components/asteroid_explode.tscn")

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	speed = randi_range(min_speed, max_speed)
	rotation = PI * 2 * randf()
	
	vertex = randi_range(5, 12)
	size = randf_range(0.5, 3)
	
	hurtbox.scale *= size
	sprite.scale *= size
	collision.scale *= size
	poly.scale *= size
	var polygon : Array[Vector2] = generate_polygon(vertex)
	poly.polygon = polygon
	collision.polygon = polygon
	
	health = ceil(size * 2)
	setup_world()

func setup_world() -> void:
	match Global.current_level:
		0:
			sprite.texture = load("res://textures/placeholder.png")
			poly.queue_free()
		1, 2:
			sprite.queue_free()
		3, 4:
			sprite.queue_free()
			poly.material.set_shader_parameter("progress", 1)

func _physics_process(delta : float) -> void:
	var direction = Vector2(cos(rotation), sin(rotation))
	position += direction * speed * delta

func _on_hurtbox_area_entered(bullet : Bullet) -> void:
	health -= bullet.damage
	bullet.queue_free()
	if health <= 0:
		if Global.current_level >= 3:
			var particle : CPUParticles2D = death_explode.instantiate()
			particle.position = position
			particle.resize(size)
			particle.emitting = true
			Global.asteroid_destroy(size)
			get_parent().add_child(particle)
			get_parent().explode_asteroid.play()
		queue_free()
	
func generate_polygon(num_vertices: int, spikiness: float = 0.7, avg_radius: float = 80, irregularity: float = 0, center: Vector2 = Vector2.ZERO) -> Array[Vector2]:
	irregularity *= 2 * PI / num_vertices
	spikiness *= avg_radius
	var angle_steps = random_angle_steps(num_vertices, irregularity)

	var points : Array[Vector2] = []
	var angle = rng.randf_range(0, 2 * PI)
	for i in range(num_vertices):
		var radius = clamp(rng.randf_range(spikiness, avg_radius), 0, 2 * avg_radius)
		var point = Vector2(center[0] + radius * cos(angle), center[1] + radius * sin(angle))
		points.append(point)
		angle += angle_steps[i]

	return points

func random_angle_steps(steps : int, irregularity : float) -> Array[float]:
	var angles : Array[float] = []
	var lower = (2 * PI / steps) - irregularity
	var upper = (2 * PI / steps) + irregularity
	var cumsum = 0
	for i in range(steps):
		var angle = rng.randf_range(lower, upper)
		angles.append(angle)
		cumsum += angle

	cumsum /= (2 * PI)
	for i in range(steps):
		angles[i] /= cumsum
	return angles
