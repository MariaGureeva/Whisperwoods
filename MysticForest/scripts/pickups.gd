extends Area2D

@onready var prompt = $Label 
var is_player_inside = false

func _ready():
	prompt.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player1":
		is_player_inside = true
		if GameState.talked_to_toadling_once:
			prompt.text = "PRESS E"
			prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player1":
		is_player_inside = false
		prompt.visible = false

func _process(delta: float) -> void:
	if is_player_inside and GameState.talked_to_toadling_once and Input.is_action_just_pressed("ui_interact"):
		pick_up()

func pick_up():
	print("✅ whisper_seeds are picked up!")
	
	GameState.add_item("whisper_seed", 3)
	
	GameState.seeds_found = true
	
	# Удаляем объект семян со сцены
	queue_free()
