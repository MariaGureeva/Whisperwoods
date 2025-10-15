# Owl_Interaction.gd
extends Area2D

@onready var controller = get_owner()

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player1":
		if not GameState.owl_quest_started:
			self.monitoring = false
			if is_instance_valid(controller) and controller.has_method("start_intro_dialogue"):
				controller.start_intro_dialogue()
