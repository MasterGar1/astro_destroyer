extends CanvasLayer

@onready var health = $Health
@onready var kills = $Kills
@onready var animation_player = $AnimationPlayer
@onready var info = $Info

func _ready() -> void:
	get_tree().get_nodes_in_group("player")[0].connect("take_damage", _take_damage)
	Global.connect("score_update", _score_update)

func _unhandled_input(event):
	if event.is_action_pressed("info"):
		info.visible = not info.visible
		get_tree().paused = not get_tree().paused
		_setup_info()

func _take_damage():
	var player : Player = get_tree().get_nodes_in_group("player")[0]
	health.max_value = player.base_health
	health.value = player.current_health
	if player.current_health <= 0:
		animation_player.play("death")
		health.hide()
		return
	animation_player.play("chaos")

func _score_update() -> void:
	kills.text = "Score: %s" % Global.score
	if Global.score >= Global.WINNING_SCORE:
		health.hide()
		animation_player.play("win")
		get_tree().paused = true
	
func _setup_info() -> void:
	info.get_child(1).text = "[center]" + str(get_tree().get_nodes_in_group("player")[0])
