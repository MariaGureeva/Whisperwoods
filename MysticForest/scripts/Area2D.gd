extends Area2D

@onready var label = $Text
var player_inside = false

func _ready():
	label.visible = false

func _on_body_entered(body):
	if body.name == "Player1":
		player_inside = true

func _on_body_exited(body):
	if body.name == "Player1":
		player_inside = false

func _process(_delta):
	if player_inside and Input.is_action_just_pressed("ui_accept"):
		print("Pressed!")
		get_tree().change_scene_to_file("res://scenes/CabinInside.tscn")
