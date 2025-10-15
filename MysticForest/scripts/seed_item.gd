extends Area2D

@onready var prompt = $Label
var is_player_inside = false

func _ready():
	if prompt:
		prompt.visible = false
	else:
		print("⚠️ Label not found!")

func _on_body_entered(body):
	if body.name == "Player1":
		is_player_inside = true
		prompt.visible = true

func _on_body_exited(body):
	if body.name == "Player1":
		is_player_inside = false
		prompt.visible = false

func _process(delta):
	if is_player_inside and Input.is_action_just_pressed("ui_interact"):
		var player = get_tree().current_scene.get_node("Player1")
		if player and player.has_method("add_to_inventory"):
			player.add_to_inventory("seeds")  # 👈 маленькими!
			GameState.seeds_found = true
			queue_free()
