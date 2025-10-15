extends Area2D

@export var telescope_ui: CanvasLayer
var player_in_area := false

func _ready():
	body_entered.connect(func(body): player_in_area = (body.name == "Player1"))
	body_exited.connect(func(body): if body.name == "Player1": player_in_area = false)

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("ui_interact"):
		if is_instance_valid(telescope_ui):
			telescope_ui.show_minigame()
