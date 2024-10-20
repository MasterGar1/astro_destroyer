extends CharacterBody2D
class_name Enemy

enum state {
	CHASE, ATTACK
}

@onready var sprite := $Sprite2D
@onready var attack_range := $AttackRange
@onready var timer := $Timer
@onready var particles := $CPUParticles2D

@export var bullet_scene : PackedScene = preload("res://components/bullet.tscn")
@export var death_explode : PackedScene = preload("res://components/death_particle.tscn")
@export var speed : int = 5000
@export var damage: int = 1
@export var bullet_speed : int = 300
@export var bullet_life : int = 600
@export var bullet_amount : int = 1
@export var avoid_range : int = 200
@export var attack_cooldown : float = 3
@export var health : int = 1
@export var is_boss : bool = false

var current_state : state = state.CHASE
var is_on_cooldown : bool = false

func _ready() -> void:
	timer.wait_time = attack_cooldown
	setup_world()

func _physics_process(delta : float) -> void:
	match current_state:
		state.CHASE:
			chase(delta)
			
			if can_attack():
				current_state = state.ATTACK
		state.ATTACK:
			attack(delta)
			
func chase(delta : float) -> void:
	if Global.is_player_dead:
		particles.emitting = false
		return
	
	var direction = position.direction_to(get_tree().get_nodes_in_group("player")[0].position)
	rotation = direction.angle() + PI / 2
	
	if position.distance_squared_to(get_tree().get_nodes_in_group("player")[0].position) > avoid_range ** 2:
		velocity = direction * speed * delta
	else:
		velocity = Vector2.ZERO
		
	if Global.current_level >= 3:
		particles.emitting = velocity.length() > 0
	move_and_slide()
	
func can_attack() -> bool:
	return attack_range.can_see_player and not is_on_cooldown

func attack(_delta : float) -> void:
	current_state = state.CHASE
	shoot()
	
func shoot() -> void:
	is_on_cooldown = true
	timer.start()
	var cone : float = PI / 36
	var aim_rot : float = rotation
	$Shoot.play()
	for i in range(bullet_amount):
		var bullet : Bullet = bullet_scene.instantiate()
		bullet.create(position, aim_rot - (float(bullet_amount) / 2 - i) * cone, damage, bullet_speed, bullet_life, false)
		get_parent().add_child(bullet)

func setup_world() -> void:
	match Global.current_level:
		3, 4:
			sprite.self_modulate = Color(1.7, 1.7, 1.7)

func _on_timer_timeout() -> void:
	is_on_cooldown = false

func _on_hurtbox_area_entered(bullet : Bullet) -> void:
	if not bullet.is_player_bullet:
		return
	
	health -= bullet.damage
	bullet.queue_free()
	$Hurt.play()
	if health <= 0:
		if Global.current_level >= 3:
			var particle : CPUParticles2D = death_explode.instantiate()
			particle.color = Color(1, 0, 0)
			particle.position = position
			particle.emitting = true
			if is_boss:
				Global.boss_death()
			else:
				Global.enemy_death()
			get_parent().add_child(particle)
			get_parent().explode_ship.play()
		queue_free()
