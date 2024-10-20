extends CanvasLayer

@onready var health := $Health
@onready var kills := $Kills
@onready var animation_player := $AnimationPlayer
@onready var info := $Info
@export var health_point : PackedScene = preload("res://components/health_point.tscn")

func _ready() -> void:
	get_tree().get_nodes_in_group("player")[0].connect("take_damage", _take_damage)
	get_tree().get_nodes_in_group("player")[0].connect("powerup", _powerup)
	Global.connect("score_update", _score_update)
	
	_take_damage()

func _unhandled_input(event  : InputEvent) -> void:
	if event.is_action_pressed("info"):
		info.visible = not info.visible
		get_tree().paused = not get_tree().paused
		_setup_info()

func _take_damage() -> void:
	var player : Player = get_tree().get_nodes_in_group("player")[0]
	
	if player.base_health <= 0:
		animation_player.play("death")
		health.hide()
		return
	
	if health.get_children().size() > player.base_health:
		animation_player.play("chaos")
		while health.get_children().size() > player.base_health:
			health.remove_child(health.get_child(0))
	elif health.get_children().size() < player.base_health:
		while health.get_children().size() < player.base_health:
			health.add_child(health_point.instantiate())
		

func _powerup() -> void:
	animation_player.play("chaos")

func _score_update() -> void:
	kills.text = "Score: %s" % Global.score
	if Global.score >= Global.WINNING_SCORE:
		health.hide()
		animation_player.play("win")
		get_tree().paused = true
	
func _setup_info() -> void:
	info.get_child(1).text = "[center]" + str(get_tree().get_nodes_in_group("player")[0])
