extends CharacterBody2D
class_name Player
#Onready
@onready var shoot_timer = $Timer
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var auto_aimer = $AutoAimer
@onready var camera = $Camera2D
@onready var particles = $CPUParticles2D
#Speed
@export var max_speed : int = 400
@export var acceleration : int = 200
@export var deceleration : int = 150
#Rotation
@export var max_rotation_speed : int = 3
@export var rotation_acceleration : int = 2
@export var rotation_damping : int = 4
#Stats
@export var current_health : int  = 3
@export var base_health : int = 3
@export var base_damage : int = 1
@export var base_proj_speed : int = 500
@export var base_lifespan : int = 700
@export var base_attack_cooldown : float = 1.0
@export var base_proj_amount : int = 1
#Preloads
@export var bullet_scene = preload("res://components/bullet.tscn")
@export var death_explode = preload("res://components/death_particle.tscn")
#Reuseables
var current_speed : float = 0
var current_rotation_speed : float = 0
var can_shoot : bool = true

signal take_damage()

func _ready():
	setup_world()
	shoot_timer.wait_time = base_attack_cooldown

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()

func _physics_process(delta : float) -> void:
	#Rotation movement
	var side_input : float = Input.get_action_strength("right") - Input.get_action_strength("left")
	if side_input != 0:
		current_rotation_speed = min(current_rotation_speed + rotation_acceleration * side_input * delta, max_rotation_speed)
	else:
		if current_rotation_speed > 0:
			current_rotation_speed = max(current_rotation_speed - rotation_damping * delta, 0)
		elif current_rotation_speed < 0:
			current_rotation_speed = min(current_rotation_speed + rotation_damping * delta, 0)
	rotation += current_rotation_speed * delta
	#Forward movement
	var forward_direction : Vector2 = Vector2(cos(rotation), sin(rotation)).rotated(-PI / 2)
	if Input.is_action_pressed("up"):
		current_speed = min(current_speed + acceleration * delta, max_speed)
	elif Input.is_action_pressed("down"):
		current_speed = min(current_speed - float(acceleration) / 10 * delta, float(max_speed) / 10)
	else:
		current_speed = max(current_speed - deceleration * delta, 0)
	
	velocity = forward_direction * current_speed
	
	if Global.current_level >= 3:
		particles.emitting = Input.is_action_pressed("up") or side_input != 0
	
	move_and_slide()
	
func shoot() -> void:
	if can_shoot:
		can_shoot = false
		shoot_timer.start()
		camera.apply_shake(0.07)
		if Global.current_level >= 4:
			$Shoot.play()
		var auto_pos : Vector2 =  auto_aimer.get_closest_pos()
		var aim_rot : float = rotation
		var cone : float = PI / 36
		if auto_pos != Vector2.ZERO:
			aim_rot = auto_pos.angle_to_point(position) - PI / 2
		for i in range(base_proj_amount):
			var bullet : Bullet = bullet_scene.instantiate()
			bullet.create(position, aim_rot - (float(base_proj_amount) / 2 - i) * cone, base_damage, base_proj_speed, base_lifespan, true)
			get_parent().add_child(bullet)
			
func gain_powerup(id : int) -> void:
	match id:
		0: #HP
			base_health += 1
			current_health += 1
			take_damage.emit()
		1: #Damage
			base_damage += 1
		2: #ProjSpeed
			base_proj_speed += 100
			base_lifespan += 100
		3: #AtkCooldown
			base_attack_cooldown = max(base_attack_cooldown - 0.1, 0.1)
			shoot_timer.wait_time = base_attack_cooldown
		4: #ProjAmount
			base_proj_amount += 1
			auto_aimer.get_child(0).shape.radius += 5
			
	var tween : Tween = create_tween()
	tween.tween_property(sprite, "self_modulate", Global.powerup_colors[id], 0.5)
	tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.5)
	tween.play()
	$Powerup.play()
			
func setup_world() -> void:
	match Global.current_level:
		0:
			sprite.texture = load("res://textures/placeholder.png")
		1, 2:
			sprite.texture = load("res://textures/player_ship.png")
			sprite.scale = Vector2.ONE * 0.1
		3, 4:
			sprite.texture = load("res://textures/player_ship.png")
			sprite.scale = Vector2.ONE * 0.1
			sprite.self_modulate = Color(1.7, 1.7, 1.7)

func _on_timer_timeout() -> void:
	can_shoot = true

func _on_hurtbox_area_entered(bullet : Bullet) -> void:
	if bullet.is_player_bullet:
		return
	camera.apply_shake()
	velocity /= 2
	current_health -= bullet.damage
	animation_player.call_deferred("play", "take_damage")
	
	take_damage.emit()
	bullet.queue_free()
	if current_health <= 0:
		if Global.current_level >= 3:
			var particle : CPUParticles2D = death_explode.instantiate()
			particle.position = position
			particle.emitting = true
			get_parent().add_child(particle)
			if Global.current_level >= 4:
					get_parent().explode_ship.play()
		camera.reparent(get_tree().current_scene)
		camera.position = position
		Global.is_player_dead = true
		queue_free()
		
func _to_string() -> String:
	var d : Dictionary = {
		"[color=#2cff00]Health" : base_health,
		"[color=#24ce00]Current Health" : current_health,
		"[color=#ff4a4a]Damage" : base_damage,
		"[color=#26a9ff]Proj Speed" : base_proj_speed,
		"[color=#ffe727]Cooldown" : base_attack_cooldown,
		"[color=#9c30ff]Projectiles" : base_proj_amount
	}
	
	return str(d).replace('{', '').replace('}', '').replace('"', '').replace(',', '\n')
